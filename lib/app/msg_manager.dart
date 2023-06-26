import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/models/enums/msg_type.dart';
import 'package:cartoonizer/models/msg_count_entity.dart';
import 'package:cartoonizer/models/msg_entity.dart';
import 'package:cartoonizer/models/page_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/views/msg/msg_list_controller.dart';
import 'package:common_utils/common_utils.dart';

import 'user/user_manager.dart';

class MsgManager extends BaseManager {
  late CartoonizerApi api;

  Rx<int> unreadCount = 0.obs;
  Rx<int> likeCount = 0.obs;
  Rx<int> commentCount = 0.obs;
  Rx<int> systemCount = 0.obs;

  late StreamSubscription userStateListen;
  late TimerUtil timer;

  @override
  Future<void> onCreate() async {
    super.onCreate();
    api = CartoonizerApi().bindManager(this);
    timer = TimerUtil()
      ..setInterval(60000)
      ..setOnTimerTickCallback(
        (millisUntilFinished) {
          var manager = AppDelegate.instance.getManager<UserManager>();
          if (!manager.isNeedLogin) {
            loadUnreadCount();
          }
        },
      );
    userStateListen = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) {
      if (event.data ?? false) {
        loadUnreadCount();
      } else {
        unreadCount.value = 0;
      }
    });
  }

  @override
  Future<void> onAllManagerCreate() async {
    super.onAllManagerCreate();
    delay(() => timer.startTimer(), milliseconds: 2000);
  }

  @override
  Future<void> onDestroy() async {
    api.unbind();
    timer.cancel();
    super.onDestroy();
  }

  Future<List<MsgEntity>?> loadMsgList({required int page, required int pageSize, required List<MsgType> actions}) async {
    String? action;
    if (!actions.isEmpty) {
      action = actions.filter((t) => t != MsgType.UNDEFINED).map((e) => e.value()).toList().join(',');
    }
    var pageEntity = await api.listMsg(from: page * pageSize, size: pageSize, action: action);
    if (pageEntity == null) {
      return null;
    }
    if (page == 0) {
      api.listMsg(from: 0, size: 1, toast: false).then((value) {
        if (value != null) {
          unreadCount.value = value.unreadCount;
        }
      });
    }
    var list = pageEntity.getDataList<MsgEntity>();
    return list;
  }

  Future<List<MsgDiscoveryEntity>?> loadMsgDiscoveryEntity({
    required int page,
    required int pageSize,
    required MsgTab tab,
  }) async {
    if (tab == MsgTab.system) {
      return null;
    }
    PageEntity? pageEntity;
    if (tab == MsgTab.like) {
      pageEntity = await api.listAllLikeEvent(from: page, size: pageSize);
    } else {
      pageEntity = await api.listAllCommentEvent(from: page, size: pageSize);
    }
    if (pageEntity == null) {
      return null;
    }
    return pageEntity.getDataList<MsgDiscoveryEntity>();
  }

  Future<List<MsgCountEntity>?> loadUnreadCount() async {
    List<MsgCountEntity>? actionList = await api.getAllUnreadCount();
    if (actionList != null) {
      int total = 0;
      int like = 0;
      int comment = 0;
      int system = 0;
      actionList.forEach((element) {
        total += element.count;
        var action = MsgTypeUtils.build(element.action);
        if (action == MsgType.like_social_post || action == MsgType.like_social_post_comment) {
          like += element.count;
        } else if (action == MsgType.comment_social_post || action == MsgType.comment_social_post_comment) {
          comment += element.count;
        } else if (action == MsgType.ai_avatar_completed) {
          system += element.count;
        }
      });
      unreadCount.value = total;
      likeCount.value = like;
      commentCount.value = comment;
      systemCount.value = system;
    }
    return actionList;
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

  Future<BaseEntity?> readAll(List<MsgType> actions) async {
    List<String>? action;
    if (!actions.isEmpty) {
      var filter = actions.filter((t) => t != MsgType.UNDEFINED);
      action = filter.map((e) => e.value().toString()).toList();
    }
    var baseEntity = await api.readAllMsg(action);
    if (baseEntity != null) {
      loadUnreadCount();
    }
    return baseEntity;
  }
}
