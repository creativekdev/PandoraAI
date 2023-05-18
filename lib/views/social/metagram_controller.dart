import 'dart:math';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/auth/connector_platform.dart';
import 'package:cartoonizer/api/socialmedia_connector_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
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
  late TimerUtil timer;
  int _scrollPosition = 0;

  set scrollPosition(int pos) {
    _scrollPosition = pos;
    update();
  }

  int get scrollPosition => _scrollPosition;
  late ItemScrollController itemScrollController;
  late ItemPositionsListener itemPositionsListener;

  @override
  void onInit() {
    super.onInit();
    api = SocialMediaConnectorApi().bindController(this);
    hasIgConnection = userManager.platformConnections.containsKey(ConnectorPlatform.instagram);
    if (hasIgConnection) {
      coreUserId = userManager.platformConnections[ConnectorPlatform.instagram]?.first.coreUserId;
    }
    timer = TimerUtil()
      ..setInterval(3000)
      ..setOnTimerTickCallback(
        (millisUntilFinished) {
          loadMetagramData();
        },
      );
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
      // result.rows = [...result.rows, ...result.rows];
      // result.rows = [...result.rows, ...result.rows];
      data = result;
      var status = MetagramStatusUtils.build(data?.socialPostPage?.status);
      if (status == MetagramStatus.completed) {
        timer.cancel();
      }
      update();
      return true;
    } else {
      return false;
    }
  }

  void startLoadPage() {
    if (data == null) {
      return;
    }
    var status = MetagramStatusUtils.build(data?.socialPostPage?.status);
    if (status == MetagramStatus.completed) {
      return;
    } else {
      // final wsUrl = Uri(
      //   host: 'io.socialbook.io',
      //   scheme: 'https',
      //   port: 8185,
      //   queryParameters: {
      //     'influencer_id': '$coreUserId',
      //   },
      //   path: '/profile',
      // );
      // IO.Socket socket = IO.io(
      //     wsUrl.toString(),
      //     IO.OptionBuilder()
      //         .setTransports(['websocket', 'polling'])
      //         .enableReconnection() // for Flutter or Dart VM
      //         .disableAutoConnect() // disable auto-connection
      //         .setExtraHeaders({'origin': 'https://socialbook.io'}) // optional
      //         .build());
      // socket.onConnect((_) {
      //   print('connect');
      //   // socket.emit('msg', 'test');
      // });
      // socket.onDisconnect((data) {
      //   print(data);
      // });
      // socket.connect();
      // WebSocket.connect(
      //   wsUrl,
      //   headers: {'origin': "https://socialbook.io"},
      // ).then((value) {
      //   value.listen((event) {
      //     print(event.toString());
      //   });
      // });
      timer.startTimer();
      if (status == MetagramStatus.init) {
        api.startBuildMetagram(coreUserId: coreUserId!);
      }
    }
  }

  void refreshScrollPos() {

  }
}
