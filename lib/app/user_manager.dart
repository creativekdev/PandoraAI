import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/social_user_info.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/EmailVerificationScreen.dart';

typedef OnUserChange = Function(SocialUserInfo user);
typedef OnUserStateChange = Function(bool isLogin);

///
/// 新的用户数据管理器，暂时与老逻辑并行，新缓存key使用user_info，老的使用user
/// 目前只把正常登录切换到userManager管理，其他第三方登录沿用老逻辑，只是在登录成功后埋点获取user_info。
/// @Author: wangyu
/// @Date: 2022/6/22
///
class UserManager extends BaseManager {
  late CacheManager cacheManager;

  Map<String, dynamic> get aiServers => cacheManager.getJson(CacheManager.keyAiServer);

  set aiServers(Map<String, dynamic> data) => cacheManager.setJson(CacheManager.keyAiServer, data);

  SocialUserInfo? _user;

  SocialUserInfo? get user {
    if (_user == null) return null;
    return SocialUserInfo.fromJson(_user!.toJson());
  }

  set user(SocialUserInfo? userInfo) {
    if (_user != null && userInfo != null) {
      bool update = userInfo.equals(_user);
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

  set sid(String id) => cacheManager.setString(CacheManager.keyLoginCookie, id);

  List<OnUserChange> _onUserChangeListeners = [];
  List<OnUserStateChange> _onUserStateListeners = [];

  Future<void> onAllManagerCreate() async {
    super.onAllManagerCreate();
    cacheManager = AppDelegate.instance.getManager();
    initUser();
  }

  initUser() {
    var json = cacheManager.getJson(CacheManager.keyCurrentUser);
    if (json != null) {
      _user = SocialUserInfo.fromJson(json);
    }
    refreshUser();
  }

  refreshUser({BuildContext? context}) {
    CartoonizerApi().getCurrentUser().then((value) {
      aiServers = value.aiServers;
      if (value.loginSuccess) {
        user = value.user!;
        if (context != null && user!.status != 'activated') {
          // remove all route and push email verification screen
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (BuildContext context) => EmailVerificationScreen(user!.email),
              settings: RouteSettings(name: "/EmailVerificationScreen"),
            ),
            ModalRoute.withName('/EmailVerificationScreen'),
          );
        }
      }
    });
  }

  Future<BaseEntity?> login(String email, String password) async {
    var baseEntity = await CartoonizerApi().login({
      'email': email,
      'password': password,
      'type': APP_TYPE,
    });
    if (baseEntity != null) {
      refreshUser();
    }
    return baseEntity;
  }

  _notifyUserChange() {
    _onUserChangeListeners.forEach((element) => element.call(_user!));
  }

  _notifyUserStateChange() {
    _onUserStateListeners.forEach((element) => element.call(_user != null));
  }

  listenUserInfo(OnUserChange userChange) {
    _onUserChangeListeners.add(userChange);
  }

  cancelListenUserInfo(OnUserChange userChange) {
    delay(() => _onUserChangeListeners.remove(userChange));
  }

  listenUserState(OnUserStateChange userStateChane) {
    _onUserStateListeners.add(userStateChane);
  }

  cancelListenUserState(OnUserStateChange userStateChane) {
    delay(() => _onUserStateListeners.remove(userStateChane));
  }
}
