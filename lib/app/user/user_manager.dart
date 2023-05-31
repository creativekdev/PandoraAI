import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Widgets/auth/connector_platform.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/ad_config_entity.dart';
import 'package:cartoonizer/models/daily_limit_rule_entity.dart';
import 'package:cartoonizer/models/online_model.dart';
import 'package:cartoonizer/models/platform_connection_entity.dart';
import 'package:cartoonizer/models/social_user_info.dart';
import 'package:cartoonizer/models/user_ref_link_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/EmailVerificationScreen.dart';
import 'package:cartoonizer/views/account/LoginScreen.dart';
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
  late CartoonizerApi api;

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

  Map<String, dynamic> get aiServers => cacheManager.getJson(CacheManager.keyAiServer) ?? {};

  set aiServers(Map<String, dynamic> data) => cacheManager.setJson(CacheManager.keyAiServer, data);

  DailyLimitRuleEntity get limitRule {
    var data = cacheManager.getJson(CacheManager.limitRule);
    if (data == null) {
      return DailyLimitRuleEntity();
    }
    return DailyLimitRuleEntity.fromJson(data);
  }

  set limitRule(DailyLimitRuleEntity entity) => cacheManager.setJson(CacheManager.limitRule, entity.toJson());

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

  @override
  Future<void> onCreate() async {
    super.onCreate();
    api = CartoonizerApi().bindManager(this);
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
  }

  @override
  Future<void> onDestroy() async {
    _userStataListen.cancel();
    api.unbind();
    super.onDestroy();
  }

  @override
  Future<void> onAllManagerCreate() async {
    super.onAllManagerCreate();
    cacheManager = AppDelegate.instance.getManager();
    await initUser();
    _rateNoticeOperator = RateNoticeOperator(cacheManager: cacheManager);
    _rateNoticeOperator.init();
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
    }
  }

  Future<OnlineModel> refreshUser({BuildContext? context}) async {
    var value = await api.getCurrentUser();
    if (value.aiServers.isNotEmpty) {
      aiServers = value.aiServers;
    }
    adConfig = value.adConfig;
    limitRule = value.dailyLimitRuleEntity;
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
    return value;
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

  MapEntry<int, int> getAnotherMeLimit() {
    if (user == null) {
      return MapEntry(limitRule.anotherme?.anonymous ?? 0, 0);
    }
    int base;
    if (!isVip()) {
      base = limitRule.anotherme?.user ?? 0;
    } else {
      base = limitRule.anotherme?.plan ?? 0;
    }
    return MapEntry(base, (user!.payload['anotherme_daily_limit'] ?? 0) as int);
  }

  MapEntry<int, int> getTxt2ImgLimit() {
    if (user == null) {
      return MapEntry(limitRule.txt2img?.anonymous ?? 0, 0);
    }
    int base;
    if (!isVip()) {
      base = limitRule.txt2img?.user ?? 0;
    } else {
      base = limitRule.txt2img?.plan ?? 0;
    }
    return MapEntry(base, (user!.payload['txt2img_daily_limit'] ?? 0) as int);
  }

  MapEntry<int, int> getAiDrawLimit() {
    if (user == null) {
      return MapEntry(limitRule.scribble?.anonymous ?? 0, 0);
    }
    int base;
    if (!isVip()) {
      base = limitRule.scribble?.user ?? 0;
    } else {
      base = limitRule.scribble?.plan ?? 0;
    }
    return MapEntry(base, (user!.payload['scribble_daily_limit'] ?? 0) as int);
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
    var baseEntity = await CartoonizerApi2().disconnectSocialMedia(params);
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
