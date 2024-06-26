import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/widgets/auth/connector_platform.dart';
import 'package:cartoonizer/api/uploader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/main.dart';
import 'package:cartoonizer/models/ad_config_entity.dart';
import 'package:cartoonizer/models/address_entity.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/app_feature_entity.dart';
import 'package:cartoonizer/models/avatar_ai_list_entity.dart';
import 'package:cartoonizer/models/avatar_config_entity.dart';
import 'package:cartoonizer/models/back_pick_template_entity.dart';
import 'package:cartoonizer/models/daily_limit_rule_entity.dart';
import 'package:cartoonizer/models/discovery_comment_list_entity.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/discovery_sort.dart';
import 'package:cartoonizer/models/generate_limit_entity.dart';
import 'package:cartoonizer/models/home_post_entity.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:cartoonizer/models/msg_count_entity.dart';
import 'package:cartoonizer/models/online_model.dart';
import 'package:cartoonizer/models/page_entity.dart';
import 'package:cartoonizer/models/pay_plan_entity.dart';
import 'package:cartoonizer/models/platform_connection_entity.dart';
import 'package:cartoonizer/models/print_option_entity.dart';
import 'package:cartoonizer/models/print_payment_entity.dart';
import 'package:cartoonizer/models/social_user_info.dart';
import 'package:cartoonizer/models/user_ref_link_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/network/dio_node.dart';
import 'package:cartoonizer/network/retry_able_requester.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:common_utils/common_utils.dart';
import 'package:device_uuid/device_uuid.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../models/get_address_entity.dart';
import '../models/print_order_entity.dart';
import '../models/print_orders_entity.dart';
import '../models/print_product_entity.dart';

class AppApi extends RetryAbleRequester {
  CacheManager cacheManager = AppDelegate().getManager();
  UserManager userManager = AppDelegate().getManager();

  AppApi({Dio? client}) : super(client: client);

  factory AppApi.quickResponse() {
    var client = DioNode.instance.client;
    client.options.connectTimeout = 10000;
    return AppApi(client: client);
  }

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
    var map = <String, dynamic>{
      'device_id': token,
    };
    var osVersion = await getOsVersion();
    if (!TextUtil.isEmpty(osVersion)) {
      map['os_version'] = osVersion;
    }
    var baseEntity = await get('/user/get_login', params: map, needRetry: false, canClickRetry: false);
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
          adConfig: adConfig,
          dailyLimitRuleEntity: dailyLimitRuleEntity,
          feature: featureEntity,
        );
      }
    }
    return OnlineModel(
      user: null,
      loginSuccess: false,
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
    String? category,
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
    if (category != null) {
      map['category'] = category;
    }
    var baseEntity = await get('/social_post/all', params: map, options: Options(responseType: ResponseType.stream));
    if (baseEntity == null) {
      return null;
    } else {
      var stream = await (baseEntity.data as ResponseBody).stream.toList();
      final result = BytesBuilder();
      for (Uint8List subList in stream) {
        result.add(subList);
      }
      String s = Utf8Decoder().convert(result.takeBytes());
      var json = jsonDecode(s);
      return jsonConvert.convert<PageEntity>(json['data']);
    }
  }

  Future<DiscoveryListEntity?> getDiscoveryDetail(
    int id, {
    bool useCache = false,
    bool toast = true,
    bool needRetry = true,
  }) async {
    if (useCache) {
      var json = cacheManager.getJson(CacheManager.cacheDiscoveryListEntity + '$id');
      if (json != null) {
        return jsonConvert.convert<DiscoveryListEntity>(json);
      }
    }
    var baseEntity = await get(
      '/social_post/get/$id',
      toastOnFailed: toast,
      needRetry: needRetry,
    );
    if (baseEntity == null) {
      return null;
    }
    var data = baseEntity.data['data'];
    cacheManager.setJson(CacheManager.cacheDiscoveryListEntity + '$id', data);
    return jsonConvert.convert<DiscoveryListEntity>(data);
  }

  Future<MetagramItemEntity?> getMetagramItem(
    int id, {
    bool useCache = false,
    bool toast = true,
    bool needRetry = true,
  }) async {
    if (useCache) {
      var json = cacheManager.getJson(CacheManager.cacheDiscoveryListEntity + '$id');
      if (json != null) {
        return jsonConvert.convert<MetagramItemEntity>(json);
      }
    }
    var baseEntity = await get(
      '/social_post/get/$id',
      toastOnFailed: toast,
      needRetry: needRetry,
    );
    if (baseEntity == null) {
      return null;
    }
    var data = baseEntity.data['data'];
    cacheManager.setJson(CacheManager.cacheDiscoveryListEntity + '$id', data);
    return jsonConvert.convert<MetagramItemEntity>(data);
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
      if (response?.statusCode == 401) {
        onUserExpired.call();
      }
    });
  }

  /// get discovery effect's comments
  Future<PageEntity?> listDiscoveryComments({
    required int from,
    required int pageSize,
    required int socialPostId,
    int? parentSocialPostCommentId,
    bool retry = false,
  }) async {
    var map = <String, dynamic>{
      'from': from,
      'size': pageSize,
      'social_post_id': socialPostId,
    };
    if (parentSocialPostCommentId != null) {
      map['parent_social_post_comment_id'] = parentSocialPostCommentId;
    }
    var baseEntity = await get('/social_post_comment/all', params: map, needRetry: retry);
    return jsonConvert.convert<PageEntity>(baseEntity?.data['data']);
  }

  /// create a comment of discovery
  Future<DiscoveryCommentListEntity?> createDiscoveryComment({
    required String comment,
    required int socialPostId,
    int? replySocialPostCommentId,
    int? parentSocialPostCommentId,
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
    if (parentSocialPostCommentId != null) {
      map['parent_social_post_comment_id'] = parentSocialPostCommentId;
    }
    var baseEntity = await post('/social_post_comment/create', params: map, onFailed: (response) {
      if (response?.statusCode == 401) {
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
      var entity = jsonConvert.convert<DiscoveryCommentListEntity>(baseEntity.data['data']);
      entity?.userAvatar = userManager.user?.getShownAvatar() ?? '';
      entity?.userName = userManager.user?.getShownName() ?? '';
      return entity;
    }
    return null;
  }

  Future<bool> updateDiscoveryComment(
    int id, {
    required String text,
  }) async {
    var baseEntity = await post('/social_post_comment/update/$id', params: {'text': text}, onFailed: (response) {}, toastOnFailed: false, needRetry: false);
    if (baseEntity != null) {
      // var likeId = baseEntity.data['data']?.toInt();
      // Events.discoveryLikeClick(source: source, style: style);
      // EventBusHelper().eventBus.fire(OnDiscoveryLikeEvent(data: MapEntry(id, likeId)));
      return true;
    }
    return false;
  }

  Future<bool> deleteDiscoveryComment(int id) async {
    var baseEntity = await delete('/social_post_comment/delete/$id', params: {}, onFailed: (response) {
      if (response?.statusCode == 401) {
        // onUserExpired?.call();
      }
    }, toastOnFailed: false, needRetry: false);
    if (baseEntity != null) {
      // var likeId = baseEntity.data['data']?.toInt();
      // Events.discoveryLikeClick(source: source, style: style);
      // EventBusHelper().eventBus.fire(OnDiscoveryLikeEvent(data: MapEntry(id, likeId)));
      return true;
    }
    return false;
  }

  Future<int?> discoveryLike(
    int id, {
    Function? onUserExpired,
    required String source,
    required String style,
  }) async {
    var baseEntity = await post('/social_post_like/create', params: {'social_post_id': id}, onFailed: (response) {
      if (response?.statusCode == 401) {
        onUserExpired?.call();
      }
    }, toastOnFailed: false, needRetry: false);
    if (baseEntity != null) {
      var likeId = baseEntity.data['data']?.toInt();
      Events.discoveryLikeClick(source: source, style: style);
      EventBusHelper().eventBus.fire(OnDiscoveryLikeEvent(data: MapEntry(id, likeId)));
      return likeId;
    }
    return null;
  }

  Future<PrintOptionEntity?> printTemplates({
    Function? onUserExpired,
    required int from,
    required int size,
  }) async {
    var baseEntity = await get('/tool/canva/resource/print_templates', params: {'from': from, 'size': size}, onFailed: (response) {
      if (response?.statusCode == 401) {
        onUserExpired?.call();
      }
    }, toastOnFailed: false, needRetry: false);
    if (baseEntity != null) {
      var entity = jsonConvert.convert<PrintOptionEntity>(baseEntity.data);
      return entity;
    }
    return null;
  }

  Future<PrintProductEntity?> shopifyProducts({
    Function? onUserExpired,
    required String product_ids,
    required int is_admin_shop,
  }) async {
    var baseEntity = await get('/shopify_v2/products', params: {'product_ids': "gid://shopify/Product/$product_ids", 'is_admin_shop': is_admin_shop}, onFailed: (response) {
      if (response?.statusCode == 401) {
        onUserExpired?.call();
      }
    }, toastOnFailed: false, needRetry: false);
    if (baseEntity != null) {
      var entity = jsonConvert.convert<PrintProductEntity>(baseEntity.data);
      return entity;
    }
    return null;
  }

  Future<BaseEntity?> discoveryUnLike(
    int id,
    int likeId, {
    Function? onUserExpired,
  }) async {
    var baseEntity = await delete('/social_post_like/delete/$likeId', onFailed: (response) {
      if (response?.statusCode == 401) {
        onUserExpired?.call();
      }
    }, toastOnFailed: false, needRetry: false);
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
      if (response?.statusCode == 401) {
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
      if (response?.statusCode == 401) {
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

  Future<PrintOrdersEntity?> getShopifyOrders(body) async {
    var baseEntity = await get("/ps_order/all", params: body);
    return jsonConvert.convert<PrintOrdersEntity>(baseEntity?.data);
  }

  Future<BaseEntity?> getShopifyOrderDetail(int id) async {
    var baseEntity = await get("/ps_order/get/${id}");
    return jsonConvert.convert<BaseEntity>(baseEntity?.data);
  }

  // buy plan with stripe
  Future<PrintOrderEntity?> shopifyCreateOrder(body) async {
    var baseEntity = await post("/shopify_v2/order/create", params: body, canClickRetry: false, needRetry: false);
    return jsonConvert.convert<PrintOrderEntity>(baseEntity?.data);
  }

  // buy plan with stripe
  Future<BaseEntity?> buyPlan(body) async {
    var baseEntity = await post("/plan/buy", params: body);
    return baseEntity;
  }

  // buy plan with check
  Future<PrintPaymentEntity?> buyPlanCheckout(body) async {
    var baseEntity = await post("/plan/checkout", params: body);
    return jsonConvert.convert<PrintPaymentEntity>(baseEntity?.data);
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
    var baseEntity = await get('/notification/action_count', needRetry: false);
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

  Future<AddressEntity?> createAddress(Map<String, dynamic> map) async {
    final baseEntity = await post('/shopify_v2/customer/create_address', params: {"address": map});
    AddressEntity? entity = jsonConvert.convert<AddressEntity>(baseEntity?.data);
    if (entity != null) {
      EventBusHelper().eventBus.fire(OnAddPrintAddressEvent(address: entity.data.customerAddress));
    }
    return entity;
  }

  Future<BaseEntity?> deletePrintAddress(int address_id) async {
    final baseEntity = await delete('/shopify_v2/customer/delete_address', data: {"address_id": address_id});
    if (baseEntity != null) {
      EventBusHelper().eventBus.fire(OnDeletePrintAddressEvent(id: address_id));
    }
    return baseEntity;
  }

  Future<AddressEntity?> updateAddress(Map<String, dynamic> map, int address_id) async {
    final baseEntity = await post('/shopify_v2/customer/update_address', params: {"address": map, "address_id": address_id});
    AddressEntity? entity = jsonConvert.convert<AddressEntity>(baseEntity?.data);
    if (entity != null) {
      EventBusHelper().eventBus.fire(OnUpdatePrintAddressEvent(address: entity.data.customerAddress));
    }
    return entity;
  }

  Future<GetAddressEntity?> getAddress() async {
    final baseEntity = await get('/shopify_v2/customer/get');
    return jsonConvert.convert<GetAddressEntity>(baseEntity?.data);
  }

  Future<BaseEntity?> deleteAddress(String feedback) async {
    return post('/user/feedback', params: {
      'message': feedback,
    });
  }

  Future<BaseEntity?> postReport(int postid) async {
    return post('/social_post/report/$postid');
  }

  Future<BaseEntity?> postCommentReport(int postid) async {
    return post('/social_post_comment/report/$postid');
  }

  Future<ApiConfigEntity?> getHomeConfig() async {
    var baseEntity = await get(
      "/tool/cartoonize_config_new/v7",
      needRetry: true,
      canClickRetry: true,
      params: {
        'separate_sticker': 1,
        'list_format': 1,
      },
    );
    if (baseEntity == null) return null;
    return ApiConfigEntity.fromJson(baseEntity.data["data"]);
  }

  Future<HomePostEntity?> socialHomePost({required int from, required int size, required String category}) async {
    var params = <String, dynamic>{'from': from, 'size': size, 'category': category};
    var baseEntity = await get('/social_post/home', params: params);
    return jsonConvert.convert<HomePostEntity>(baseEntity?.data);
  }

  Future<BaseEntity?> deleteDiscovery(int id) async {
    var baseEntity = await delete('/social_post/delete/$id');
    if (baseEntity != null) {
      EventBusHelper().eventBus.fire(OnDeleteDiscoveryEvent(id: id));
    }
    return baseEntity;
  }

  Future<String?> uploadToS3(
    File file,
    bool isFree, {
    ProgressCallback? onSendProgress,
  }) async {
    String fileName = getFileName(file.path);
    String bucket = "${isFree ? 'free' : 'fast'}-socialbook";
    var fileType = fileName.substring(fileName.lastIndexOf(".") + 1);
    if (TextUtil.isEmpty(fileType)) {
      fileType = '*';
    }
    String tname = 'file';
    if (file.path.isVideoFile) {
      tname = 'video';
    } else if (file.path.isImageFile) {
      tname = 'image';
    }
    String contentType = "$tname/$fileType";
    final params = {
      "bucket": bucket,
      "file_name": fileName,
      "content_type": contentType,
    };
    var url = await getPresignedUrl(params);
    if (url == null) {
      return null;
    }
    var baseEntity = await Uploader().uploadFile(url, file, contentType, onSendProgress: onSendProgress);
    if (baseEntity != null) {
      var imageUrl = url.split("?")[0];
      return imageUrl;
    }
    return null;
  }

  Future<String?> uploadBytesToS3(
    Uint8List bytes,
    bool isFree,
    String contentType, {
    ProgressCallback? onSendProgress,
  }) async {
    String bucket = "${isFree ? 'free' : 'fast'}-socialbook";
    String fileName = 'paiFile-${DateTime.now().microsecondsSinceEpoch}';
    final params = {
      "bucket": bucket,
      "file_name": fileName,
      "content_type": contentType,
    };
    var url = await getPresignedUrl(params);
    if (url == null) {
      return null;
    }
    var baseEntity = await Uploader().upload(url, bytes, contentType, onSendProgress: onSendProgress);
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
    var baseEntity = await get('/ai_avatar/all', canClickRetry: true);
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
    var baseEntity = await get('/ai_avatar/config/v1',
        params: {
          'language': MyApp.currentLocales,
        },
        needRetry: true,
        canClickRetry: true);
    return jsonConvert.convert<AvatarConfigEntity>(baseEntity?.data);
  }

  Future<BaseEntity?> logAnotherMe(Map<String, dynamic> params) async {
    return await get('/log/anotherme', params: params);
  }

  Future<BaseEntity?> logScribble(Map<String, dynamic> params) async {
    return await get('/log/scribble', params: params);
  }

  Future<BaseEntity?> logStyleMorph(Map<String, dynamic> params) async {
    return await get('/log/stylemorph', params: params);
  }

  Future<BaseEntity?> logCartoonizer(Map<String, dynamic> params) async {
    return await get('/log/cartoonize', params: params);
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
    var baseEntity = await get(
      '/check_app_version',
      needRetry: true,
      canClickRetry: true,
    );
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

  Future<GenerateLimitEntity?> getAiDrawLimit() async {
    var baseEntity = await get('/tool/scribble/usage');
    return jsonConvert.convert<GenerateLimitEntity>(baseEntity?.data['data']);
  }

  Future<GenerateLimitEntity?> getRemoveBgLimit() async {
    var baseEntity = await get('/tool/removebg/usage');
    return jsonConvert.convert<GenerateLimitEntity>(baseEntity?.data['data']);
  }

  Future<GenerateLimitEntity?> getTxt2ImgLimit() async {
    var baseEntity = await get('/tool/txt2img/usage');
    return jsonConvert.convert<GenerateLimitEntity>(baseEntity?.data['data']);
  }

  Future<GenerateLimitEntity?> getStyleMorphLimit() async {
    var baseEntity = await get('/tool/stylemorph/usage');
    return jsonConvert.convert<GenerateLimitEntity>(baseEntity?.data['data']);
  }

  Future<GenerateLimitEntity?> getAiColoringLimit() async {
    var baseEntity = await get('/tool/lineart/usage');
    return jsonConvert.convert<GenerateLimitEntity>(baseEntity?.data['data']);
  }

  Future<GenerateLimitEntity?> getCartoonizeLimit() async {
    var baseEntity = await get('/tool/cartoonize/usage');
    return jsonConvert.convert<GenerateLimitEntity>(baseEntity?.data['data']);
  }

  Future<String?> submitInvitedCode(String invitedCode) async {
    var baseEntity = await post(
      '/refer/create',
      params: {'rf': invitedCode, 'rf_product': APP_NAME},
      needRetry: false,
      canClickRetry: false,
    );
    return baseEntity?.data['data'];
  }

  Future<UserRefLinkEntity?> createRefCode(String refCode) async {
    var baseEntity = await post('/refer_link/create', params: {
      'code': refCode,
    });
    return jsonConvert.convert<UserRefLinkEntity>(baseEntity?.data['data']);
  }

  Future<BaseEntity?> unsubscribe(String category) async {
    return await post('/plan/cancel', params: {'category': category});
  }

  Future<BaseEntity?> appleBuy(Map<String, dynamic> params) async {
    return await post('/plan/apple_store/buy', params: params);
  }

  Future<Map<ConnectorPlatform, List<PlatformConnectionEntity>>?> listConnections() async {
    var baseEntity = await get('/user/connected_channels');
    List<PlatformConnectionEntity>? list = jsonConvert.convertListNotNull<PlatformConnectionEntity>(baseEntity?.data['data']);
    if (list == null) {
      return null;
    }
    Map<ConnectorPlatform, List<PlatformConnectionEntity>> result = {};
    for (var value in list) {
      List<PlatformConnectionEntity> list = result[value.platform] ?? [];
      list.add(value);
      result[value.platform] = list;
    }
    return result;
  }

  Future<BaseEntity?> logError({
    required String reqMethod,
    required String api,
    required String errorMessage,
    required String headers,
    required int statusCode,
  }) async {
    if (api.contains('/log/api_error')) {
      return null;
    }
    return await post(
      '/log/api_error',
      params: {
        'requestMethod': reqMethod,
        'api': api,
        'headers': headers,
        'statusCode': statusCode,
        'errorMessage': errorMessage,
      },
      needRetry: false,
      toastOnFailed: false,
    );
  }

  Future<List<BackPickTemplateEntity>?> listBackgroundImages({
    required int from,
    required int size,
    String? keyword,
  }) async {
    Map<String, dynamic> params = {
      'from': from,
      'size': size,
    };
    if (!TextUtil.isEmpty(keyword)) {
      params['q'] = keyword;
    }
    var baseEntity = await get('/tool/canva/resource/backgrounds', params: params);
    return jsonConvert.convertListNotNull<BackPickTemplateEntity>(baseEntity?.data['data']);
  }
}

class AppApi2 extends RetryAbleRequester {
  CacheManager cacheManager = AppDelegate().getManager();
  UserManager userManager = AppDelegate().getManager();

  AppApi2({Dio? client}) : super(client: client);

  @override
  Future<ApiOptions>? apiOptions(Map<String, dynamic> params) async {
    Map<String, String> headers = {};
    headers['cookie'] = "sb.connect.sid=${userManager.sid}";
    return ApiOptions(baseUrl: Config.instance.host, headers: headers);
  }

  Future<BaseEntity?> disconnectSocialMedia(Map<String, dynamic> params) async {
    return await post('/disconnect', params: params);
  }
}
