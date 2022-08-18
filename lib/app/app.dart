import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/app/image_scale_manager.dart';
import 'package:cartoonizer/app/msg_manager.dart';
import 'package:cartoonizer/app/notification_manager.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/importFile.dart';

///
/// @Author: wangyu
/// @Date: 2022/6/22
///
/// AppDelegate
class AppDelegate {
  factory AppDelegate() => _getInstance();

  static AppDelegate get instance => _getInstance();
  static AppDelegate? _instance;
  Map<String, BaseManager> managerMap = Map();
  bool _initialized = false;

  List<Function(bool status)> _listeners = [];

  get initialized => _initialized;

  AppDelegate._internal() {
    _initialized = false;
  }

  listen(Function(bool status) listener) {
    _listeners.add(listener);
  }

  cancelListenAsync(Function(bool status) listener) {
    delay(() => _listeners.remove(listener));
  }

  _notifyStatus() {
    var iterator = _listeners.iterator;
    while (iterator.moveNext()) {
      iterator.current.call(_initialized);
    }
  }

  init() async {
    _initialized = false;
    _notifyStatus();
    if (managerMap.isNotEmpty) {
      debugPrint("error: appDelegate is inited already, please don't call repeat");
      return;
    }
    var startTime = DateTime.now();
    debugPrint("start init app delegate, currentTime:${startTime.toString()}");
    var list = List<BaseManager>.empty(growable: true);
    _registerManager(list);
    for (var manager in list) {
      var managerName = manager.runtimeType.toString();
      var managerStartTime = DateTime.now();
      debugPrint("start init $managerName, currentTime:${managerStartTime.toString()}");
      managerMap[manager.runtimeType.toString()] = manager;
      await manager.onCreate();
      var managerEndTime = DateTime.now();
      debugPrint("init $managerName, spend ${managerEndTime.millisecondsSinceEpoch - managerStartTime.millisecondsSinceEpoch} milliseconds");
    }
    for (var manager in managerMap.values) {
      await manager.onAllManagerCreate();
    }
    var endTime = DateTime.now();
    debugPrint("init all managers finished, currentTime:${endTime.toString()}");
    debugPrint("init all managers finished, spend ${endTime.millisecondsSinceEpoch - startTime.millisecondsSinceEpoch} milliseconds");
    _initialized = true;
    _notifyStatus();
  }

  ///reload app delegate
  Future<bool> reload() async {
    _initialized = false;
    _notifyStatus();
    var start = DateTime.now();
    debugPrint('start destroy all managers,currentTime:$start');
    for (var manager in managerMap.values) {
      debugPrint('destroy manager,${manager.runtimeType.toString()}');
      await manager.onDestroy();
      debugPrint('destroy ${manager.runtimeType.toString()} finished');
    }
    debugPrint('destroy all managers finished, spend ${DateTime.now().millisecondsSinceEpoch - start.millisecondsSinceEpoch} milliseconds');
    debugPrint('re-register all managers');
    var reloadStart = DateTime.now();
    for (var manager in managerMap.values) {
      await manager.onCreate();
    }
    for (var manager in managerMap.values) {
      await manager.onAllManagerCreate();
    }
    debugPrint('register managers finished, spend ${DateTime.now().millisecondsSinceEpoch - reloadStart.millisecondsSinceEpoch} milliseconds');
    _initialized = true;
    _notifyStatus();
    return true;
  }

  static AppDelegate _getInstance() {
    if (_instance == null) {
      _instance = new AppDelegate._internal();
    }
    return _instance!;
  }

  ///register all data manager, app need to be restarted whenever add or remove any manager instance
  _registerManager(List<BaseManager> list) {
    list.add(NotificationManager());
    list.add(ThirdpartManager());
    list.add(CacheManager());
    list.add(UserManager());
    list.add(EffectManager());
    list.add(ImageScaleManager());
    list.add(MsgManager());
  }

  T getManager<T extends BaseManager>() {
    return managerMap[T.toString()] as T;
  }

  bool exists<T extends BaseManager>() {
    return managerMap[T.toString()] != null;
  }
}

abstract class BaseManager {
  bool _mounted = false;

  get mounted => _mounted;

  @protected
  Future<void> onCreate() async {
    _mounted = true;
  }

  @protected
  Future<void> onAllManagerCreate() async {}

  @protected
  Future<void> onDestroy() async {
    _mounted = false;
  }

  T getManager<T extends BaseManager>() {
    return AppDelegate.instance.getManager<T>();
  }
}
