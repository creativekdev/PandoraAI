import 'dart:async';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/models/msg_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

class MsgManager extends BaseManager {
  List<MsgEntity> msgList = [];
  late CartoonizerApi api;

  Rx<int> unreadCount = 0.obs;
  int page = 0;
  int pageSize = 20;
  late StreamSubscription userStateListen;

  @override
  Future<void> onCreate() async {
    super.onCreate();
    userStateListen = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (event.data ?? false) {
        loadFirstPage();
      } else {
        msgList.clear();
        page = 0;
      }
    });
    api = CartoonizerApi().bindManager(this);
  }

  @override
  Future<void> onDestroy() async {
    api.unbind();
    super.onDestroy();
  }

  // return true means nomore, false means can load also.
  Future<bool> loadFirstPage() async {
    var pageEntity = await api.listMsg(from: 0, size: pageSize);
    if (pageEntity == null) {
      return true;
    }
    unreadCount.value = pageEntity.unreadCount;
    page = 0;
    var list = pageEntity.getDataList<MsgEntity>();
    msgList = list;
    if (list.length != pageSize) {
      return true;
    } else {
      return false;
    }
  }

  // return true means nomore, false means can load also.
  Future<bool> loadMorePage() async {
    var pageEntity = await api.listMsg(from: (page + 1) * pageSize, size: pageSize);
    if (pageEntity == null) {
      return false;
    }
    unreadCount.value = pageEntity.unreadCount;
    page++;
    var list = pageEntity.getDataList<MsgEntity>();
    msgList.addAll(list);
    if (list.length != pageSize) {
      return true;
    } else {
      return false;
    }
  }

  Future<BaseEntity?> readMsg(MsgEntity data) async {
    var readMsg = await api.readMsg(data.id);
    if (!data.read && readMsg != null) {
      unreadCount.value--;
      if (unreadCount.value < 0) {
        unreadCount.value = 0;
      }
    }
    return readMsg;
  }

  Future<BaseEntity?> readAll() async {
    var baseEntity = await api.readAllMsg();
    if (baseEntity != null) {
      unreadCount.value = 0;
      for (var value in msgList) {
        value.read = true;
      }
    }
    return baseEntity;
  }
}
