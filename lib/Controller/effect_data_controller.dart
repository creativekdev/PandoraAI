import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/models/effect_map.dart';

typedef ItemRender = Widget Function();

class EffectDataController extends GetxController {
  EffectMap? data = null;
  bool loading = true;
  EffectManager effectManager = AppDelegate.instance.getManager();

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    loadData();
  }

  loadData() {
    loading = true;
    update();
    effectManager.loadData().then((value) {
      loading = false;
      if (value != null) {
        this.data = value;
      }
      update();
    });
  }
}

class HomeTabConfig {
  String title;
  Widget item;

  HomeTabConfig({
    required this.item,
    required this.title,
  });
}
