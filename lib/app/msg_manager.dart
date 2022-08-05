import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/models/msg_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';

class MsgManager extends BaseManager {
  List<MsgEntity> msgList = [];
  late CartoonizerApi api;

  int page = 0;
  int pageSize = 20;

  @override
  Future<void> onCreate() async {
    super.onCreate();
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
    return api.readMsg(data.id);
  }
}
