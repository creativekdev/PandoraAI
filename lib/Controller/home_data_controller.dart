import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api.dart';
import 'package:cartoonizer/models/EffectModel.dart';

typedef ItemRender = Widget Function();

class HomeDataController extends GetxController {
  Map<String, List<EffectModel>>? data = null;
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
