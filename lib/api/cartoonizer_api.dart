import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/enums/discovery_sort.dart';
import 'package:cartoonizer/models/online_model.dart';
import 'package:cartoonizer/models/page_entity.dart';
import 'package:cartoonizer/models/social_user_info.dart';
import 'package:cartoonizer/network/base_requester.dart';

class CartoonizerApi extends BaseRequester {
  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    var userManager = AppDelegate.instance.getManager<UserManager>();
    Map<String, String> headers = {};
    if (!userManager.isNeedLogin) {
      headers['cookie'] = "sb.connect.sid=${userManager.sid}";
    }
    return ApiOptions(baseUrl: Config.instance.apiHost, headers: headers);
  }

  /// login normal
  Future<BaseEntity?> login(Map<String, dynamic> params) => post('/user/login', params: params);

  /// get current user info
  Future<OnlineModel> getCurrentUser() async {
    var baseEntity = await get('/user/get_login');
    if (baseEntity != null) {
      if (baseEntity.data != null) {
        Map<String, dynamic> data = baseEntity.data;
        bool login = data['login'] ?? false;
        SocialUserInfo? user;
        if (login) {
          user = SocialUserInfo.fromJson(data['data']);
        }
        return OnlineModel(user: user, loginSuccess: login, aiServers: data['ai_servers']);
      }
    }
    return OnlineModel(user: null, loginSuccess: false, aiServers: {});
  }

  /// get discovery list data
  Future<PageEntity?> listDiscovery({
    required int page,
    required int pageSize,
    DiscoverySort sort = DiscoverySort.likes,
    bool isMyPost = false,
  }) async {
    var map = {
      'from': page,
      'size': pageSize,
      'sidx': sort.apiValue(),
    };
    if (isMyPost) {
      map['is_my_post'] = 1;
    }
    var baseEntity = await get('/social_post/all', params: map);
    return jsonConvert.convert<PageEntity>(baseEntity?.data['data']);
  }

  /// share effect to discovery
  Future<BaseEntity?> startSocialPost({
    required String description,
    required String imageUrl,
    required String originalImageUrl,
  }) async {
    return post('/social_post/create', params: {
      'images': '$imageUrl,$originalImageUrl',
      'text': description,
    });
  }

  /// get discovery effect's comments
  Future<PageEntity?> listDiscoveryComments({
    required int page,
    required int pageSize,
    required int socialPostId,
    int? replySocialPostCommentId,
  }) async {
    var map = {
      'from': page,
      'size': pageSize,
      'social_post_id': socialPostId,
    };
    if (replySocialPostCommentId != null) {
      map['reply_social_post_comment_id'] = replySocialPostCommentId;
    }
    var baseEntity = await get('/social_post_comment/all', params: map);
    return jsonConvert.convert<PageEntity>(baseEntity?.data['data']);
  }

  /// create a comment of discovery
  Future<BaseEntity?> createDiscoveryComment({
    required String comment,
    required int socialPostId,
    int? replySocialPostCommentId,
  }) async {
    var map = {
      'text': comment,
      'social_post_id': socialPostId,
    };
    if (replySocialPostCommentId != null) {
      map['reply_social_post_comment_id'] = replySocialPostCommentId;
    }
    return post('/social_post_comment/create', params: map);
  }
}
