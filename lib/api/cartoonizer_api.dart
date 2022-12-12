import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/events.dart';
import 'package:cartoonizer/api/uploader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/models/enums/discovery_sort.dart';
import 'package:cartoonizer/models/online_model.dart';
import 'package:cartoonizer/models/page_entity.dart';
import 'package:cartoonizer/models/pay_plan_entity.dart';
import 'package:cartoonizer/models/social_user_info.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CartoonizerApi extends BaseRequester {
  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    var userManager = AppDelegate.instance.getManager<UserManager>();
    Map<String, String> headers = {};
    headers['cookie'] = "sb.connect.sid=${userManager.sid}";
    return ApiOptions(baseUrl: Config.instance.apiHost, headers: headers);
  }

  /// login normal
  Future<BaseEntity?> login(Map<String, dynamic> params) async => await post('/user/login', params: params);

  Future<BaseEntity?> signUp({
    required String name,
    required String email,
    required String password,
  }) =>
      post('/user/signup/simple', params: {
        'name': name,
        "email": email,
        "password": password,
        "type": 'email',
      });

  /// get current user info
  Future<OnlineModel> getCurrentUser() async {
    String? token = AppDelegate.instance.getManager<CacheManager>().getString(CacheManager.pushToken);
    var baseEntity = await get('/user/get_login', params: {
      'device_id': token,
    });
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

  Future<BaseEntity?> deleteAccount() async {
    return post("/user/delete_account");
  }

  /// get discovery list data
  Future<PageEntity?> listDiscovery({
    required int from,
    required int pageSize,
    DiscoverySort sort = DiscoverySort.likes,
    bool isMyPost = false,
    int? userId,
  }) async {
    var map = {
      'from': from,
      'size': pageSize,
      'sidx': sort.apiValue(),
    };
    if (isMyPost) {
      map['is_my_post'] = 1;
    }
    if (userId != null) {
      map['user_id'] = userId;
    }
    var baseEntity = await get('/social_post/all', params: map);
    return jsonConvert.convert<PageEntity>(baseEntity?.data['data']);
  }

  Future<DiscoveryListEntity?> getDiscoveryDetail(int id) async {
    var baseEntity = await get('/social_post/get/$id');
    return jsonConvert.convert(baseEntity?.data['data']);
  }

  /// share effect to discovery
  Future<BaseEntity?> startSocialPost({
    required String description,
    required List<DiscoveryResource> resources,
    required String effectKey,
    required Function onUserExpired,
  }) async {
    var encode = jsonEncode(resources.map((e) => e.toJson()).toList());
    logEvent(Events.create_discovery_share);
    return post('/social_post/create', params: {
      'resources': encode,
      'text': description,
      'cartoonize_key': effectKey,
    }, onFailed: (response) {
      if (response.statusCode == 401) {
        onUserExpired.call();
      }
    });
  }

  /// get discovery effect's comments
  Future<PageEntity?> listDiscoveryComments({
    required int from,
    required int pageSize,
    required int socialPostId,
    int? replySocialPostCommentId,
  }) async {
    var map = <String, dynamic>{
      'from': from,
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
    Function? onUserExpired,
  }) async {
    var map = {
      'text': comment,
      'social_post_id': socialPostId,
    };
    if (replySocialPostCommentId != null) {
      map['reply_social_post_comment_id'] = replySocialPostCommentId;
    }
    var baseEntity = await post('/social_post_comment/create', params: map, onFailed: (response) {
      if (response.statusCode == 401) {
        onUserExpired?.call();
      }
    });
    if (baseEntity != null) {
      var data = [socialPostId];
      if (replySocialPostCommentId != null) {
        data.add(replySocialPostCommentId);
      }
      EventBusHelper().eventBus.fire(OnCreateCommentEvent(data: data));
    }
    return baseEntity;
  }

  Future<int?> discoveryLike(
    int id, {
    Function? onUserExpired,
  }) async {
    var baseEntity = await post('/social_post_like/create', params: {'social_post_id': id}, onFailed: (response) {
      if (response.statusCode == 401) {
        onUserExpired?.call();
      }
    });
    if (baseEntity != null) {
      var likeId = baseEntity.data['data']?.toInt();
      EventBusHelper().eventBus.fire(OnDiscoveryLikeEvent(data: MapEntry(id, likeId)));
      return likeId;
    }
    return null;
  }

  Future<BaseEntity?> discoveryUnLike(
    int id,
    int likeId, {
    Function? onUserExpired,
  }) async {
    var baseEntity = await delete('/social_post_like/delete/$likeId', onFailed: (response) {
      if (response.statusCode == 401) {
        onUserExpired?.call();
      }
    });
    if (baseEntity != null) {
      EventBusHelper().eventBus.fire(OnDiscoveryUnlikeEvent(data: id));
    }
    return baseEntity;
  }

  Future<int?> commentLike(
    int id, {
    Function? onUserExpired,
  }) async {
    var baseEntity = await post('/social_post_like/create', params: {'social_post_comment_id': id}, onFailed: (response) {
      if (response.statusCode == 401) {
        onUserExpired?.call();
      }
    });
    if (baseEntity != null) {
      var likeId = baseEntity.data['data']?.toInt();
      EventBusHelper().eventBus.fire(OnCommentLikeEvent(data: MapEntry(id, likeId)));
      return likeId;
    }
    return null;
  }

  Future<BaseEntity?> commentUnLike(
    int id,
    int likeId, {
    Function? onUserExpired,
  }) async {
    var baseEntity = await delete('/social_post_like/delete/$likeId', onFailed: (response) {
      if (response.statusCode == 401) {
        onUserExpired?.call();
      }
    });
    if (baseEntity != null) {
      EventBusHelper().eventBus.fire(OnCommentUnlikeEvent(data: id));
    }
    return baseEntity;
  }

  Future<String?> getPresignedUrl(Map<String, dynamic> params) async {
    var baseEntity = await get('/file/presigned_url', params: params);
    return baseEntity?.data?['data'];
  }

  // buy plan with stripe
  Future<BaseEntity?> buyPlan(body) async {
    var baseEntity = await post("/plan/buy", params: body);
    return baseEntity;
  }

  Future<MsgPageEntity?> listMsg({
    required int from,
    required int size,
  }) async {
    var baseEntity = await get('/notification/all', params: {
      'from': from,
      'size': size,
    });
    return jsonConvert.convert<MsgPageEntity>(baseEntity?.data['data']);
  }

  Future<BaseEntity?> readMsg(int id) async {
    return post('/notification/mark_read/$id');
  }

  Future<BaseEntity?> readAllMsg() async {
    return post('/notification/mark_all_read');
  }

  Future<BaseEntity?> feedback(String feedback) async {
    return post('/user/feedback', params: {
      'message': feedback,
    });
  }

  Future<EffectMap?> getHomeConfig() async {
    var baseEntity = await get("/tool/cartoonize_config/v5");
    if (baseEntity == null) return null;
    return EffectMap.fromJson(baseEntity.data);
  }

  Future<BaseEntity?> deleteDiscovery(int id) async {
    var baseEntity = await delete('/social_post/delete/$id');
    if (baseEntity != null) {
      EventBusHelper().eventBus.fire(OnDeleteDiscoveryEvent(id: id));
    }
    return baseEntity;
  }

  Future<String?> uploadImageToS3(File file, bool isFree) async {
    String fileName = getFileName(file.path);
    String bucket = "${isFree ? 'free' : 'fast'}-socialbook";
    var fileType = fileName.substring(fileName.lastIndexOf(".") + 1);
    if (TextUtil.isEmpty(fileType)) {
      fileType = '*';
    }
    String contentType = "image/$fileType";
    final params = {
      "bucket": bucket,
      "file_name": fileName,
      "content_type": contentType,
    };
    var url = await getPresignedUrl(params);
    if (url == null) {
      return null;
    }
    var baseEntity = await Uploader().uploadFile(url, file, contentType);
    if (baseEntity != null) {
      var imageUrl = url.split("?")[0];
      return imageUrl;
    }
    return null;
  }

  Future<BaseEntity?> submitAvatarAi({required Map<String, dynamic> params}) async {
    return post('/ai_avatar/create', params: params);
  }

  Future<List<dynamic>?> listAllAvatarAi() async {
    var baseEntity = await get('/ai_avatar/all');
    //todo
    return [];
  }

  Future<BaseEntity?> getAvatarAiDetail({required String token}) async {
    return await get('/ai_avatar/get', params: {
      'token': token,
    });
  }

  Future<List<PayPlanEntity>?> listAllBuyPlan(String category) async {
    var baseEntity = await get('/plan/all', params: {
      'category': category,
    });
    if (baseEntity != null) {
      return jsonConvert.convertListNotNull<PayPlanEntity>(baseEntity.data['data']);
    }
    return null;
  }
}
