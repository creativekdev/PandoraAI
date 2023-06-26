import 'dart:async';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/avatar_ai_list_entity.dart';
import 'package:cartoonizer/models/avatar_config_entity.dart';
import 'package:common_utils/common_utils.dart';

class AvatarAiManager extends BaseManager {
  List<AvatarAiListEntity> dataList = [];
  late UserManager userManager;
  late CartoonizerApi api;
  AvatarConfigEntity? config;
  bool listPageAlive = false;
  late StreamSubscription userLoginListen;
  late StreamSubscription onAppStateListener;

  @override
  Future<void> onCreate() async {
    await super.onCreate();
    userLoginListen = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      listAllAvatarAi();
    });
    onAppStateListener = EventBusHelper().eventBus.on<OnAppStateChangeEvent>().listen((event) {
      if (!(event.data ?? true)) {
        refreshFromNet();
      }
    });
    api = CartoonizerApi().bindManager(this);
  }

  @override
  Future<void> onDestroy() async {
    userLoginListen.cancel();
    api.unbind();
    onAppStateListener.cancel();
    await super.onDestroy();
  }

  @override
  Future<void> onAllManagerCreate() async {
    await super.onAllManagerCreate();
    userManager = getManager();
    if (!userManager.isNeedLogin) {
      listAllAvatarAi();
    }
    getConfig();
  }

  Future<AvatarConfigEntity?> getConfig() async {
    if (config != null) {
      return config;
    } else {
      return refreshFromNet();
    }
  }

  Future<AvatarConfigEntity?> refreshFromNet() async {
    var avatarConfigEntity = await api.getAvatarAiConfig();
    if (avatarConfigEntity != null) {
      config = avatarConfigEntity;
    }
    return config;
  }

  Future<List<AvatarAiListEntity>?> listAllAvatarAi() async {
    var list = await CartoonizerApi().listAllAvatarAi();
    if (list == null) {
      return null;
    }
    dataList = list;
    if ((userManager.user?.aiAvatarCredit ?? 0) > 0) {
      dataList.insert(0, AvatarAiListEntity()..status = 'bought');
    }
    return dataList;
  }

  Future<AvatarAiListEntity?> getAvatarAiDetail({
    required String token,
  }) async {
    return await CartoonizerApi().getAvatarAiDetail(token: token);
  }
}
