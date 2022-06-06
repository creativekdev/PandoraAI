import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Model/EffectModel.dart';
import 'package:cartoonizer/api.dart';

typedef ItemRender = Widget Function();

class HomeDataController extends GetxController {
  List<EffectModel>? dataList;
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
        this.dataList = value;
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
