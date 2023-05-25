import 'dart:convert';
import 'dart:math';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/socialmedia_connector_api.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/models/enums/metagram_status.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:common_utils/common_utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class MetagramController extends GetxController {
  late SocialMediaConnectorApi api;

  bool hasIgConnection = false;

  MetagramPageEntity? data;
  String? slug;
  int? coreUserId;
  int _scrollPosition = 0;

  int pageSize = 18;

  set scrollPosition(int pos) {
    _scrollPosition = pos;
    update();
  }

  int get scrollPosition => _scrollPosition;
  late ItemScrollController itemScrollController;
  late ItemPositionsListener itemPositionsListener;
  IO.Socket? socket;
  bool metaProcessing = false;
  bool isSelf = false;
  ScrollController scrollController = ScrollController();
  bool _isRequesting = false;

  late StreamSubscription onLikeEventListener;
  late StreamSubscription onUnlikeEventListener;
  Rx<bool> likeLocalAddAlready = false.obs;

  @override
  void onInit() {
    super.onInit();
    api = SocialMediaConnectorApi().bindController(this);
    itemScrollController = ItemScrollController();
    itemPositionsListener = ItemPositionsListener.create();
    itemPositionsListener.itemPositions.addListener(() {
      if (_isRequesting) {
        return;
      }
      if (data == null) {
        return;
      }
      if (data!.rows.length < pageSize) {
        return;
      }
      int pos = max(itemPositionsListener.itemPositions.value.first.index, itemPositionsListener.itemPositions.value.last.index);
      if (pos >= data!.rows.length - 2) {
        loadMoreMetagramData();
      }
    });
    scrollController.addListener(() {
      if (_isRequesting) {
        return;
      }
      if (data == null) {
        return;
      }
      if (data!.rows.length < pageSize) {
        return;
      }
      if (scrollController.position.pixels > scrollController.position.maxScrollExtent - 20) {
        loadMoreMetagramData();
      }
    });
    onLikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryLikeEvent>().listen((event) {
      // Get the ID and like ID from the event data.
      var id = event.data!.key;
      var likeId = event.data!.value;
      // For each data item in the data list, check if the ID matches the event ID.
      // If so, update the likeId and likes properties, and update the view.
      for (var data in data!.rows) {
        if (data.id == id) {
          data.likeId = likeId;
          data.liked.value = true;
          if (likeLocalAddAlready.value) {
            likeLocalAddAlready.value = false;
          } else {
            data!.likes++;
          }
          update();
        }
      }
    });
    onUnlikeEventListener = EventBusHelper().eventBus.on<OnDiscoveryUnlikeEvent>().listen((event) {
      // For each data item in the data list, check if the ID matches the event ID.
      // If so, set the likeId property to null, decrement the likes property, and update the view.
      for (var data in data!.rows) {
        if (data.id == event.data) {
          data.likeId = null;
          data.liked.value = false;
          if (likeLocalAddAlready.value) {
            likeLocalAddAlready.value = false;
          } else {
            data.likes--;
          }
          update();
        }
      }
    });
  }

  @override
  void dispose() {
    api.unbind();
    super.dispose();
  }

  onPageStart(BuildContext context, int? userId) {
    isSelf = userId == coreUserId;
    coreUserId = userId;
    loadMetagramData().then((value) {
      if (value) {
        startLoadPage();
        // do nothing;
      } else {
        Navigator.of(context).pop();
      }
    });
  }

  Future<bool> loadMetagramData() async {
    if (_isRequesting) {
      return false;
    }
    _isRequesting = true;
    var value = await api.getSlugByCoreId(coreId: coreUserId!);
    if (value == null) {
      _isRequesting = false;
      return false;
    }
    slug = value;
    var result = await api.getMetagramData(
      slug: slug!,
      from: 0,
      size: pageSize,
    );
    _isRequesting = false;
    if (result != null) {
      data = result;
      var status = MetagramStatusUtils.build(data?.socialPostPage?.status);
      if (status == MetagramStatus.completed) {
        metaProcessing = false;
      } else {
        metaProcessing = true;
      }
      update();
      return true;
    } else {
      return false;
    }
  }

  Future<bool> loadMoreMetagramData() async {
    if (_isRequesting) {
      return false;
    }
    _isRequesting = true;
    var result = await api.getMetagramData(
      slug: slug!,
      from: data!.rows.length,
      size: pageSize,
    );
    _isRequesting = false;
    if (result != null) {
      data!.socialPostPage = result.socialPostPage;
      data!.rows.addAll(result.rows);
      data!.total = result.total;
      data!.page = result.page;
      var status = MetagramStatusUtils.build(data?.socialPostPage?.status);
      if (status == MetagramStatus.completed) {
        metaProcessing = false;
      } else {
        metaProcessing = true;
      }
      update();
      return true;
    } else {
      return false;
    }
  }

  void startLoadPage({bool force = false}) {
    if (data == null) {
      return;
    }
    var status = MetagramStatusUtils.build(data?.socialPostPage?.status);
    if (!force) {
      if (status == MetagramStatus.completed) {
        return;
      }
    }
    final wsUrl = Uri(
      host: Config.instance.metagramSocket,
      scheme: Config.instance.metagramSocketSchema,
      port: Config.instance.metagramSocketPort,
      path: '/profile',
    );
    metaProcessing = true;
    update();
    socket = IO.io(
        wsUrl.toString(),
        IO.OptionBuilder()
            .setTransports(['websocket', 'polling'])
            .enableReconnection() // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connection
            .setExtraHeaders({'origin': Config.instance.host}) // optional
            .enableForceNewConnection()
            .setQuery({
              'influencer_id': '$coreUserId',
            })
            .build());
    socket?.onConnect((_) {
      print('connect');
    });
    socket?.on('social_post_page_update', (data) {
      try {
        Map<String, dynamic> payload = jsonDecode(data);
        bool success = payload['success'] ?? false;
        if (success) {
          var status = MetagramStatusUtils.build(payload['step']);
          if (status == MetagramStatus.init || status == MetagramStatus.processing) {
            metaProcessing = true;
            update();
          }
          if (status == MetagramStatus.processing || status == MetagramStatus.completed) {
            loadMetagramData();
            if (status == MetagramStatus.completed) {
              socket?.disconnect();
              metaProcessing = false;
              update();
            }
          }
        }
      } catch (e) {
        LogUtil.e(e.toString(), tag: 'socket-error');
      }
    });
    socket?.onDisconnect((data) {
      print(data);
    });
    socket?.connect();
    if (status == MetagramStatus.init || force) {
      api.startBuildMetagram(coreUserId: coreUserId!);
      loadMetagramData();
    }
  }
}
