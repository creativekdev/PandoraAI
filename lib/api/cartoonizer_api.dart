import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/events.dart';
import 'package:cartoonizer/api/uploader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/ThemeConstant.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/ad_config_entity.dart';
import 'package:cartoonizer/models/app_feature_entity.dart';
import 'package:cartoonizer/models/avatar_ai_list_entity.dart';
import 'package:cartoonizer/models/avatar_config_entity.dart';
import 'package:cartoonizer/models/daily_limit_rule_entity.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/effect_map.dart';
import 'package:cartoonizer/models/enums/discovery_sort.dart';
import 'package:cartoonizer/models/generate_limit_entity.dart';
import 'package:cartoonizer/models/msg_count_entity.dart';
import 'package:cartoonizer/models/online_model.dart';
import 'package:cartoonizer/models/page_entity.dart';
import 'package:cartoonizer/models/pay_plan_entity.dart';
import 'package:cartoonizer/models/social_user_info.dart';
import 'package:cartoonizer/models/user_ref_link_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';

class CartoonizerApi extends BaseRequester {
  CacheManager cacheManager = AppDelegate().getManager();
  UserManager userManager = AppDelegate().getManager();

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
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
        AdConfigEntity adConfig = AdConfigEntity.fromJson(data['ads_config'] ?? {});
        DailyLimitRuleEntity dailyLimitRuleEntity = DailyLimitRuleEntity.fromJson(data['daily_limit_rules'] ?? {});
        AppFeatureEntity? featureEntity;
        if (data['new_feature'] != null) {
          featureEntity = jsonConvert.convert(data['new_feature']);
        }
        return OnlineModel(
          user: user,
          loginSuccess: login,
          aiServers: data['ai_servers'],
          adConfig: adConfig,
          dailyLimitRuleEntity: dailyLimitRuleEntity,
          feature: featureEntity,
        );
      }
    }
    return OnlineModel(
      user: null,
      loginSuccess: false,
      aiServers: {},
      adConfig: AdConfigEntity(),
      dailyLimitRuleEntity: DailyLimitRuleEntity(),
      feature: null,
    );
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

  Future<DiscoveryListEntity?> getDiscoveryDetail(int id, {bool useCache = false, bool toast = true}) async {
    if (useCache) {
      var json = cacheManager.getJson(CacheManager.cacheDiscoveryListEntity + '$id');
      if (json != null) {
        return jsonConvert.convert<DiscoveryListEntity>(json);
      }
    }
    var baseEntity = await get('/social_post/get/$id', toastOnFailed: toast);
    if (baseEntity == null) {
      return null;
    }
    var data = baseEntity.data['data'];
    cacheManager.setJson(CacheManager.cacheDiscoveryListEntity + '$id', data);
    return jsonConvert.convert<DiscoveryListEntity>(data);
  }

  /// share effect to discovery
  Future<BaseEntity?> startSocialPost({
    required String description,
    required List<DiscoveryResource> resources,
    required String effectKey,
    required Function onUserExpired,
    required String category,
    required String? payload,
  }) async {
    var encode = jsonEncode(resources.map((e) => e.toJson()).toList());
    var params = <String, dynamic>{
      'resources': encode,
      'text': description,
      'cartoonize_key': effectKey,
      'category': category,
    };
    if (payload != null) {
      params['payload'] = payload;
    }
    return post('/social_post/create', params: params, onFailed: (response) {
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
    required String source,
    required String style,
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
      Events.discoveryCommentClick(source: source, style: style);
      EventBusHelper().eventBus.fire(OnCreateCommentEvent(data: data));
    }
    return baseEntity;
  }

  Future<int?> discoveryLike(
    int id, {
    Function? onUserExpired,
    required String source,
    required String style,
  }) async {
    var baseEntity = await post('/social_post_like/create', params: {'social_post_id': id}, onFailed: (response) {
      if (response.statusCode == 401) {
        onUserExpired?.call();
      }
    }, toastOnFailed: false);
    if (baseEntity != null) {
      var likeId = baseEntity.data['data']?.toInt();
      Events.discoveryLikeClick(source: source, style: style);
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
    }, toastOnFailed: false);
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

  // buy plan with stripe
  Future<BaseEntity?> buySingle(body) async {
    var baseEntity = await post("/plan/buy_single", params: body);
    return baseEntity;
  }

  // buy plan with stripe
  Future<BaseEntity?> buyApple(body) async {
    var baseEntity = await post("/plan/apple_store/buy", params: body);
    return baseEntity;
  }

  Future<MsgPageEntity?> listMsg({
    required int from,
    required int size,
    String? action,
    bool toast = true,
  }) async {
    var params = <String, dynamic>{
      'from': from,
      'size': size,
    };
    if (action != null) {
      params['action'] = action;
    }
    var baseEntity = await get('/notification/all', params: params, toastOnFailed: toast);
    return jsonConvert.convert<MsgPageEntity>(baseEntity?.data['data']);
  }

  Future<PageEntity?> listAllCommentEvent({
    required int from,
    required int size,
  }) async {
    var params = <String, dynamic>{
      'from': from,
      'size': size,
    };
    var baseEntity = await get('/social_post_comment/all_for_author', params: params);
    return jsonConvert.convert<PageEntity>(baseEntity?.data['data']);
  }

  Future<PageEntity?> listAllLikeEvent({
    required int from,
    required int size,
  }) async {
    var params = <String, dynamic>{
      'from': from,
      'size': size,
    };
    var baseEntity = await get('/social_post_like/all_for_author', params: params);
    return jsonConvert.convert<PageEntity>(baseEntity?.data['data']);
  }

  Future<List<MsgCountEntity>?> getAllUnreadCount() async {
    var baseEntity = await get('/notification/action_count');
    return jsonConvert.convertListNotNull<MsgCountEntity>(baseEntity?.data['data']);
  }

  Future<BaseEntity?> readMsg(int id) async {
    return post('/notification/mark_read/$id');
  }

  Future<BaseEntity?> readAllMsg(List<String>? actions) async {
    var params = <String, dynamic>{};
    if (actions != null) {
      params['actions'] = actions;
    }
    return post('/notification/mark_all_read', params: params);
  }

  Future<BaseEntity?> feedback(String feedback) async {
    return post('/user/feedback', params: {
      'message': feedback,
    });
  }

  Future<EffectMap?> getHomeConfig() async {
    var baseEntity = await get("/tool/cartoonize_config/v6");
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

  Future<List<AvatarAiListEntity>?> listAllAvatarAi() async {
    var baseEntity = await get('/ai_avatar/all');
    if (baseEntity == null) {
      return null;
    }
    return jsonConvert.convertListNotNull<AvatarAiListEntity>(baseEntity.data['data']);
  }

  Future<AvatarAiListEntity?> getAvatarAiDetail({required String token, bool useCache = true}) async {
    var cacheManager = AppDelegate.instance.getManager<CacheManager>();
    var json = cacheManager.getJson(CacheManager.avatarHistory + token);
    if (!useCache || (json == null || TextUtil.isEmpty(json['share_code']?.toString()) || json['output_images'] == null || (json['output_images'] as List).isEmpty)) {
      var baseEntity = await get('/ai_avatar/get', params: {
        'token': token,
      });
      var entity = jsonConvert.convert<AvatarAiListEntity>(baseEntity?.data['data']);
      if (entity != null) {
        cacheManager.setJson(CacheManager.avatarHistory + token, entity.toJson());
      }
      return entity;
    } else {
      return jsonConvert.convert<AvatarAiListEntity>(json);
    }
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

  Future<AvatarConfigEntity?> getAvatarAiConfig() async {
    var baseEntity = await get('/ai_avatar/config/v1', params: {
      'language': AppContext.currentLocales,
    });
    return jsonConvert.convert<AvatarConfigEntity>(baseEntity?.data);
  }

  Future<BaseEntity?> getInspirationText() async {}

  Future<BaseEntity?> logAnotherMe(Map<String, dynamic> params) async {
    return await get('/log/anotherme', params: params);
  }

  Future<BaseEntity?> logTxt2Img(Map<String, dynamic> params) async {
    if (params.containsKey('init_images')) {
      return await get('/log/img2img', params: params);
    } else {
      return await get('/log/txt2img', params: params);
    }
  }

  Future<Map> checkAppVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    var baseEntity = await get('/check_app_version');
    if (baseEntity != null) {
      var result = baseEntity.data['data'] as Map;
      int availableBuild = result['available_build'] ?? 0;
      int latestBuild = result['latest_build'] ?? 0;
      if (availableBuild > latestBuild) {
        availableBuild = latestBuild;
      }
      var currentBuild = int.parse(packageInfo.buildNumber);
      if (latestBuild > currentBuild) {
        result["need_update"] = true;
      } else {
        result['need_update'] = false;
      }
      if (availableBuild > currentBuild) {
        result["force"] = true;
      } else {
        result["force"] = false;
      }
      return result;
    } else {
      return {"need_update": false, 'force': false};
    }
  }

  Future<GenerateLimitEntity?> getMetaverseLimit() async {
    var baseEntity = await get('/tool/anotherme/usage');
    return jsonConvert.convert<GenerateLimitEntity>(baseEntity?.data['data']);
  }

  Future<GenerateLimitEntity?> getTxt2ImgLimit() async {
    var baseEntity = await get('/tool/txt2img/usage');
    return jsonConvert.convert<GenerateLimitEntity>(baseEntity?.data['data']);
  }

  Future<String?> submitInvitedCode(String invitedCode) async {
    var baseEntity = await post('/refer/create', params: {
      'rf': invitedCode,
      'rf_product': APP_NAME,
    });
    return baseEntity?.data['data'];
  }

  Future<UserRefLinkEntity?> createRefCode(String refCode) async {
    var baseEntity = await post('/refer_link/create', params: {
      'code': refCode,
    });
    return jsonConvert.convert<UserRefLinkEntity>(baseEntity?.data['data']);
  }
}
