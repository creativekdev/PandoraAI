import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/controller/effect_data_controller.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/ad_config_entity.dart';
import 'package:cartoonizer/models/ai_server_entity.dart';
import 'package:cartoonizer/models/daily_limit_rule_entity.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/models/online_model.dart';
import 'package:cartoonizer/models/platform_connection_entity.dart';
import 'package:cartoonizer/models/social_user_info.dart';
import 'package:cartoonizer/models/user_ref_link_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/views/account/EmailVerificationScreen.dart';
import 'package:cartoonizer/views/account/LoginScreen.dart';
import 'package:cartoonizer/widgets/auth/connector_platform.dart';
import 'package:common_utils/common_utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import 'rate_notice_operator.dart';

///
/// 新的用户数据管理器，暂时与老逻辑并行，新缓存key使用user_info，老的使用user
/// 目前只把正常登录切换到userManager管理，其他第三方登录沿用老逻辑，只是在登录成功后埋点获取user_info。
/// @Author: wangyu
/// @Date: 2022/6/22
///
class UserManager extends BaseManager {
  late CacheManager cacheManager;
  bool lastLauncherLoginStatus = false; //true login, false unLogin
  late AppApi api;

  Map? appVersionData;

  Map<ConnectorPlatform, List<PlatformConnectionEntity>> get platformConnections {
    Map<ConnectorPlatform, List<PlatformConnectionEntity>> result = {};
    Map<String, dynamic> cache = cacheManager.getJson('${CacheManager.platformConnections}:${_user?.id ?? 'guest'}') ?? {};
    cache.forEach((key, value) {
      var platform = ConnectorPlatformUtils.build(key);
      result[platform] = jsonConvert.convertListNotNull<PlatformConnectionEntity>(value) ?? [];
    });
    return result;
  }

  set platformConnections(Map<ConnectorPlatform, List<PlatformConnectionEntity>> data) {
    Map<String, dynamic> cache = {};
    data.forEach((key, value) {
      cache[key.value() ?? ''] = value.map((e) => e.toJson()).toList();
    });
    cacheManager.setJson('${CacheManager.platformConnections}:${_user?.id ?? 'guest'}', cache);
  }

  AdConfigEntity get adConfig {
    var data = cacheManager.getJson(CacheManager.keyAdConfig);
    if (data == null) {
      return AdConfigEntity();
    }
    return AdConfigEntity.fromJson(data);
  }

  set adConfig(AdConfigEntity config) => cacheManager.setJson(CacheManager.keyAdConfig, config.toJson());

  SocialUserInfo? _user;

  SocialUserInfo? get user {
    return _user?.copy();
  }

  set user(SocialUserInfo? userInfo) {
    if (_user == null && userInfo == null) {
      return;
    }
    if (_user != null && userInfo != null) {
      bool update = !userInfo.equals(_user);
      _user = userInfo;
      cacheManager.setJson(CacheManager.keyCurrentUser, _user?.toJson());
      if (update) {
        _notifyUserChange();
      }
    } else {
      _user = userInfo;
      cacheManager.setJson(CacheManager.keyCurrentUser, _user?.toJson());
      _notifyUserStateChange();
    }
  }

  get isNeedLogin => _user == null;

  String get sid => cacheManager.getString(CacheManager.keyLoginCookie);

  set sid(String? id) {
    cacheManager.setString(CacheManager.keyLoginCookie, id);
  }

  late RateNoticeOperator _rateNoticeOperator;

  RateNoticeOperator get rateNoticeOperator => _rateNoticeOperator;
  late StreamSubscription _userStataListen;
  late StreamSubscription _networkListen;

  @override
  Future<void> onCreate() async {
    super.onCreate();
    api = AppApi().bindManager(this);
    _userStataListen = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (event.data ?? false) {
        _rateNoticeOperator.init();
        refreshConnections();
      } else {
        Posthog().reset();
        _rateNoticeOperator.dispose();
        _rateNoticeOperator.init();
      }
    });
    _networkListen = EventBusHelper().eventBus.on<OnNetworkStateChangeEvent>().listen((event) {
      if (event.data != ConnectivityResult.none) {
        refreshUser();
      }
    });
  }

  @override
  Future<void> onDestroy() async {
    _userStataListen.cancel();
    api.unbind();
    _networkListen.cancel();
    super.onDestroy();
  }

  @override
  Future<void> onAllManagerCreate() async {
    super.onAllManagerCreate();
    cacheManager = AppDelegate.instance.getManager();
    _rateNoticeOperator = RateNoticeOperator(cacheManager: cacheManager);
    _rateNoticeOperator.init();
    initUser();
  }

  initUser() async {
    var json = cacheManager.getJson(CacheManager.keyCurrentUser);
    if (json != null) {
      _user = SocialUserInfo.fromJson(json);
      lastLauncherLoginStatus = true;
    }
    refreshUser();
    refreshConnections();
    if (_user != null) {
      Posthog().identify(userId: _user?.getShownEmail());
      FirebaseAnalytics.instance.setUserProperty(name: 'user_email', value: _user?.getShownEmail());
      FirebaseAnalytics.instance.setUserProperty(name: 'user_name', value: _user?.getShownName());
      FirebaseAnalytics.instance.setUserId(id: _user?.id.toString());
    }
  }

  Future<OnlineModel> refreshUser({BuildContext? context}) async {
    var list = await Future.wait([
      AppApi.quickResponse().checkAppVersion(),
      api.getCurrentUser(),
    ]);
    OnlineModel result = OnlineModel(
      user: null,
      loginSuccess: false,
      adConfig: AdConfigEntity(),
      dailyLimitRuleEntity: DailyLimitRuleEntity(),
      feature: null,
    );
    for (var value in list) {
      if (value is Map) {
        appVersionData = value;
      } else if (value is OnlineModel) {
        adConfig = value.adConfig;
        cacheManager.featureOperator.refreshFeature(value.feature);
        if (value.loginSuccess) {
          user = value.user!;
          if (context != null && user!.status != 'activated') {
            // remove all route and push email verification screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => EmailVerificationScreen(user!.getShownEmail()),
                settings: RouteSettings(name: "/EmailVerificationScreen"),
              ),
            );
          }
        }
        result = value;
      }
    }
    return result;
  }

  Future<BaseEntity?> login(String email, String password) async {
    var baseEntity = await api.login({
      'email': email,
      'password': password,
      // 'type': APP_TYPE,
    });
    if (baseEntity != null) {
      await refreshUser();
    }
    return baseEntity;
  }

  _notifyUserChange() {
    EventBusHelper().eventBus.fire(UserInfoChangeEvent(data: user!));
  }

  _notifyUserStateChange() {
    EventBusHelper().eventBus.fire(LoginStateEvent(data: _user != null));
  }

  doOnLogin(BuildContext context,
      {required String logPreLoginAction, String? currentPageRoute, Function()? callback, bool autoExec = true, bool toSignUp = false, Function? onCancel}) {
    if (!isNeedLogin) {
      callback?.call();
      return;
    }
    cacheManager.setString(CacheManager.preLoginAction, logPreLoginAction);
    if (currentPageRoute == null) {
      GetStorage().remove('login_back_page');
    } else {
      GetStorage().write('login_back_page', currentPageRoute);
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(
            toSignUp: toSignUp,
          ),
          settings: RouteSettings(name: "/LoginScreen"),
        )).then((value) async {
      cacheManager.setString(CacheManager.preLoginAction, null);
      if (isNeedLogin) {
        onCancel?.call();
      } else {
        if (autoExec) {
          callback?.call();
        } else {
          // 非正常登录流程下，此时不一定及时获取到用户信息，需要更新一次。此代码需要在后续所有登录流程优化后删除。
          refreshUser().then((value) {
            if (autoExec && !isNeedLogin) {
              callback?.call();
            }
          });
        }
      }
    });
  }

  Future<void> logout() async {
    user = null;
    sid = null;
    lastLauncherLoginStatus = false;
  }

  MapEntry<int, int> getLimitRule(HomeCardType type) {
    EffectDataController dataController = Get.find();
    var key = type.value();
    var pick = dataController.data!.aiConfig.pick((t) => t.key == key);
    if (pick == null) {
      return MapEntry(0, 0);
    }
    if (user == null) {
      return MapEntry(pick.anonymousDailyLimit, 0);
    }
    return MapEntry(pick.limitBase, (user!.payload['${key}_daily_limit'] ?? 0) as int);
  }

  Future<UserRefLinkEntity?> getRefCode() async {
    if (user == null) {
      return null;
    }
    if (!user!.referLinks.isEmpty) {
      return user!.referLinks.first;
    }
    var entity = await api.createRefCode(randomRefCode());
    if (entity != null) {
      var newUser = user!;
      newUser.referLinks.add(entity);
      user = newUser;
      return user!.referLinks.first;
    } else {
      await refreshUser();
      if (user?.referLinks.isEmpty ?? true) {
        return null;
      }
      return user!.referLinks.first;
    }
  }

  String randomRefCode() {
    var md5 = EncryptUtil.encodeMd5('${DateTime.now().millisecondsSinceEpoch}');
    return md5.substring(0, 12).toUpperCase();
  }

  Future<BaseEntity?> unsubscribe(String planCategory) async {
    if (!(_user?.userSubscription.containsKey('id') ?? false)) {
      return null;
    }
    var baseEntity = await api.unsubscribe(planCategory);
    return baseEntity;
  }

  Future<bool> refreshConnections() async {
    if (isNeedLogin) {
      return false;
    }
    var map = await api.listConnections();
    if (map != null) {
      platformConnections = map;
      EventBusHelper().eventBus.fire(OnConnectionsChangeEvent());
      return true;
    }
    return false;
  }

  Future<bool> disconnectSocialAccount({required PlatformConnectionEntity connection}) async {
    Map<String, dynamic> params = {
      "id": connection.id,
      'target': connection.channel,
    };
    switch (connection.platform) {
      case ConnectorPlatform.youtube:
        params['youtube_channel'] = connection.coreUser.youtubeChannel;
        break;
      case ConnectorPlatform.facebook:
        break;
      case ConnectorPlatform.instagram:
        params['instagram_username'] = connection.coreUser.instagramUsername;
        break;
      case ConnectorPlatform.instagramBusiness:
        params['instagram_username'] = connection.coreUser.instagramUsername;
        break;
      case ConnectorPlatform.tiktok:
        params['tiktok_username'] = connection.coreUser.tiktokUsername;
        break;
      case ConnectorPlatform.UNDEFINED:
        break;
    }
    var baseEntity = await AppApi2().disconnectSocialMedia(params);
    if (baseEntity != null) {
      var connections = platformConnections;
      var platformConnection = connections[connection.platform] as List<PlatformConnectionEntity>;
      platformConnection.removeWhere((element) => element.coreUserId == connection.coreUserId);
      if (platformConnection.isEmpty) {
        connections.remove(connection.platform);
      } else {
        connections[connection.platform] = platformConnection;
      }
      platformConnections = connections;
      EventBusHelper().eventBus.fire(OnConnectionsChangeEvent());
      return true;
    }
    return false;
  }
}
