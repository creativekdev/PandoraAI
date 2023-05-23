import 'dart:convert';
import 'dart:math';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/auth/connector_platform.dart';
import 'package:cartoonizer/api/socialmedia_connector_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/models/enums/metagram_status.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:common_utils/common_utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

const _defaultUser = 'bellapoarch';

class MetagramController extends GetxController {
  late SocialMediaConnectorApi api;

  UserManager userManager = AppDelegate().getManager();

  bool hasIgConnection = false;

  MetagramPageEntity? data;
  String? slug;
  int? coreUserId;
  int _scrollPosition = 0;

  set scrollPosition(int pos) {
    _scrollPosition = pos;
    update();
  }

  int get scrollPosition => _scrollPosition;
  late ItemScrollController itemScrollController;
  late ItemPositionsListener itemPositionsListener;
  IO.Socket? socket;
  bool metaProcessing = false;

  @override
  void onInit() {
    super.onInit();
    api = SocialMediaConnectorApi().bindController(this);
    hasIgConnection = userManager.platformConnections.containsKey(ConnectorPlatform.instagram);
    if (hasIgConnection) {
      coreUserId = userManager.platformConnections[ConnectorPlatform.instagram]?.first.coreUserId;
    }
    itemScrollController = ItemScrollController();
    itemPositionsListener = ItemPositionsListener.create();
    itemPositionsListener.itemPositions.addListener(() {
      refreshScrollPos();
    });
  }

  int lastPos = 0;

  @override
  void dispose() {
    api.unbind();
    super.dispose();
  }

  Future<bool> loadMetagramData() async {
    var value = await api.getSlugByCoreId(coreId: coreUserId!);
    if (value == null) {
      return false;
    }
    slug = value;
    var result = await api.getMetagramData(
      slug: slug!,
      from: 0,
      size: 12,
    );
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

  void refreshScrollPos() {}
}
