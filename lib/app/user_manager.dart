import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache_manager.dart';
import 'package:cartoonizer/models/UserModel.dart';

typedef OnUserChange = Function(UserModel userModel);
typedef OnUserStateChane = Function(bool isLogin);

class UserManager extends BaseManager {
  late CacheManager cacheManager;

  UserModel? userModel;
  get isLogin=>true;
  get sid => "testSid";
  List<OnUserChange> _onUserListeners = [];
  List<OnUserStateChane> _OnUserStateListeners = [];

  Future<void> onAllManagerCreate() async {
    super.onAllManagerCreate();
    cacheManager = AppDelegate.instance.getManager();
    initUser();
  }

  initUser() {
    var json = cacheManager.getJson(CacheManager.keyCurrentUser);
    // todo 用户信息管理逻辑还未整理
  }

}
