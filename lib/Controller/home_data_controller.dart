import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/models/effect_map.dart';

typedef ItemRender = Widget Function();

class HomeDataController extends GetxController {
  EffectMap? data = null;
  bool loading = true;

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
    API.getHomeConfig().then((value) {
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

  HomeTabConfig({required this.item, required this.title});
}
