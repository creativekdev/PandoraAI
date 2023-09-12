import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/app/user/rate_notice_operator.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/home_page_entity.dart';

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

  late HomePageEntity homeEntity;

  @override
  void onInit() {
    super.onInit();
    onAppStateListener = EventBusHelper().eventBus.on<OnAppStateChangeEvent>().listen((event) {
      if (!(event.data ?? true)) {
        loadData();
      }
    });
    networkListener = EventBusHelper().eventBus.on<OnNetworkStateChangeEvent>().listen((event) {
      if (data == null) {
        loadData();
      }
    });
  }

  @override
  dispose() {
    onAppStateListener.cancel();
    networkListener.cancel();
    super.dispose();
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  loadData() {
    effectManager.loadData().then((value) {
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
