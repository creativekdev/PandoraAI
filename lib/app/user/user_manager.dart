import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/online_model.dart';
import 'package:cartoonizer/models/social_user_info.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/EmailVerificationScreen.dart';
import 'package:cartoonizer/views/account/LoginScreen.dart';

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

  Map<String, dynamic> get aiServers => cacheManager.getJson(CacheManager.keyAiServer);

  set aiServers(Map<String, dynamic> data) => cacheManager.setJson(CacheManager.keyAiServer, data);

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
    _userStataListen = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (event.data ?? false) {
        _rateNoticeOperator.init();
      } else {
        _rateNoticeOperator.dispose();
        _rateNoticeOperator.init();
      }
    });
  }

  @override
  Future<void> onDestroy() async {
    super.onDestroy();
    _userStataListen.cancel();
  }

  @override
  Future<void> onAllManagerCreate() async {
    super.onAllManagerCreate();
    cacheManager = AppDelegate.instance.getManager();
    initUser();
    _rateNoticeOperator = RateNoticeOperator(cacheManager: cacheManager);
    _rateNoticeOperator.init();
  }

  initUser() {
    var json = cacheManager.getJson(CacheManager.keyCurrentUser);
    if (json != null) {
      _user = SocialUserInfo.fromJson(json);
      lastLauncherLoginStatus = true;
    }
    refreshUser();
  }

  Future<OnlineModel> refreshUser({BuildContext? context}) async {
    var value = await CartoonizerApi().getCurrentUser();
    aiServers = value.aiServers;
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
    var baseEntity = await CartoonizerApi().login({
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

  doOnLogin(BuildContext context, {String? currentPageRoute, Function()? callback, bool autoExec = true}) {
    if (!isNeedLogin) {
      callback?.call();
      return;
    }
    if (currentPageRoute == null) {
      GetStorage().remove('login_back_page');
    } else {
      GetStorage().write('login_back_page', currentPageRoute);
    }
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginScreen(),
          settings: RouteSettings(name: "/LoginScreen"),
        )).then((value) async {
      if (autoExec && !isNeedLogin) {
        callback?.call();
      } else {
        // todo 非正常登录流程下，此时不一定及时获取到用户信息，需要更新一次。此代码需要在后续所有登录流程优化后删除。
        refreshUser().then((value) {
          if (autoExec && !isNeedLogin) {
            callback?.call();
          }
        });
      }
    });
  }

  Future<void> logout() async {
    user = null;
    sid = null;
    lastLauncherLoginStatus = false;
  }
}
