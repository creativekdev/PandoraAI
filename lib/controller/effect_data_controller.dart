import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/app/user/rate_notice_operator.dart';
import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:common_utils/common_utils.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../app/user/user_manager.dart';
import '../config.dart';

// dev
// const loopDuration = 30 * second;
// const refreshDuration = 1 * minute;

// prod
const loopDuration = 1 * minute;
const refreshDuration = 30 * minute;

class EffectDataController extends GetxController {
  ApiConfigEntity? data = null;
  bool loading = true;
  EffectManager effectManager = AppDelegate.instance.getManager();
  CacheManager cacheManager = AppDelegate.instance.getManager();

  List<String> tagList = [];
  late StreamSubscription onAppStateListener;
  late StreamSubscription networkListener;

  IO.Socket? socket;

  @override
  void onInit() {
    super.onInit();
    onAppStateListener = EventBusHelper().eventBus.on<OnAppStateChangeEvent>().listen((event) {
      if (!(event.data ?? true)) {
        // loadData();
        loadData(ignoreCache: true);
      }
    });
    networkListener = EventBusHelper().eventBus.on<OnNetworkStateChangeEvent>().listen((event) {
      if (data == null) {
        loadData();
      }
    });
    onConnectSocket();
  }

  onConnectSocket() async {
    final wsUrl = Uri(
      host: Config.instance.metagramSocket,
      scheme: Config.instance.metagramSocketSchema,
      port: Config.instance.metagramSocketPort,
      path: '/profile',
    );
    UserManager userManager = AppDelegate.instance.getManager();
    socket = IO.io(
        wsUrl.toString(),
        IO.OptionBuilder()
            .setTimeout(60000)
            .setTransports(['websocket', 'polling'])
            .enableReconnection()
            .setExtraHeaders({'origin': Config.instance.host}) // optional
            .enableForceNewConnection()
            .setQuery({
          'influencer_id': 'ppm_config',
        })
            .build());
    socket?.on('update_config', (data) {
      LogUtil.d(data, tag: 'socket-notification');
      loadData(ignoreCache: true);
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
  dispose() {
    onAppStateListener.cancel();
    networkListener.cancel();
    socket?.disconnect();
    super.dispose();
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  loadData({ignoreCache = false}) {
    effectManager.loadData(ignoreCache: ignoreCache).then((value) {
      loading = false;
      if (value != null && value != data) {
        this.data = value;
        buildTagList();
        EventBusHelper().eventBus.fire(OnHomeConfigGetEvent());
      }
      update();
    });
  }

  buildTagList() {
    tagList = data!.tags;
  }
}

class HomeTabConfig {
  String title;
  Widget item;
  GlobalKey<AppTabState> key;
  String tabString;

  HomeTabConfig({
    required this.key,
    required this.item,
    required this.title,
    required this.tabString,
  });
}
