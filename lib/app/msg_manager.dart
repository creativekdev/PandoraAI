import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/enums/msg_type.dart';
import 'package:cartoonizer/models/msg_count_entity.dart';
import 'package:cartoonizer/models/msg_entity.dart';
import 'package:cartoonizer/models/page_entity.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:cartoonizer/views/msg/msg_list_controller.dart';
import 'package:common_utils/common_utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../config.dart';

class MsgManager extends BaseManager {
  late AppApi api;

  Rx<int> unreadCount = 0.obs;
  Rx<int> likeCount = 0.obs;
  Rx<int> commentCount = 0.obs;
  Rx<int> systemCount = 0.obs;

  late StreamSubscription userStateListen;

  IO.Socket? socket;

  @override
  Future<void> onCreate() async {
    super.onCreate();
    api = AppApi().bindManager(this);

    userStateListen = EventBusHelper().eventBus.on<LoginStateEvent>().listen((event) async {
      if (event.data ?? false) {
        if (socket?.disconnected ?? true) {
          onConnectSocket();
        }
        loadUnreadCount();
      } else {
        unreadCount.value = 0;
        socket?.disconnect();
      }
    });
  }

  onConnectSocket() async {
    final wsUrl = Uri(
      host: Config.instance.metagramSocket,
      scheme: Config.instance.metagramSocketSchema,
      port: Config.instance.metagramSocketPort,
      path: '/notification',
    );
    UserManager userManager = AppDelegate.instance.getManager();
    socket = IO.io(
        wsUrl.toString(),
        IO.OptionBuilder()
            .setTimeout(60000)
            .setTransports(['websocket', 'polling'])
            .enableReconnection()
            .setExtraHeaders({'origin': Config.instance.host, 'cookie': "sb.connect.sid=${userManager.sid}"}) // optional
            .enableForceNewConnection()
            .build());
    socket?.on('notification', (data) {
      LogUtil.d(data, tag: 'socket-notification');
      loadUnreadCount();
    });
    socket?.onConnect((data) {
      LogUtil.d(data, tag: 'socket-onConnect');
    });
    socket?.onError((data) {
      LogUtil.d(data, tag: 'socket-onError');
    });
    socket?.onDisconnect((data) {
      LogUtil.d(data, tag: 'socket-onDisconnect');
    });
    socket?.onConnectError((data) {
      LogUtil.d(data, tag: 'socket-onConnectError');
    });
    socket?.onReconnectError((data) {
      LogUtil.d(data, tag: 'socket-onReconnectError');
    });
    socket?.onConnectTimeout((data) {
      LogUtil.d(data, tag: 'socket-onConnectTimeout');
    });
    socket?.onReconnect((data) {
      LogUtil.d(data, tag: 'socket-onReconnect');
    });
    socket?.connect();
  }

  @override
  Future<void> onAllManagerCreate() async {
    super.onAllManagerCreate();
    UserManager userManager = AppDelegate.instance.getManager();
    if (!userManager.isNeedLogin) {
      onConnectSocket();
      delay(() => loadUnreadCount(), milliseconds: 2000);
    }
  }

  @override
  Future<void> onDestroy() async {
    api.unbind();
    socket?.dispose();
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
