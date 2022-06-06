import 'package:cartoonizer/Common/importFile.dart';

class RecentController extends GetxController {
  bool initializing = true;

  late SharedPreferences sharedPreferences;

  @override
  void onInit() async {
    super.onInit();
    sharedPreferences = await SharedPreferences.getInstance();
    initializing = true;
    loadingFromCache();
    update();
  }

  loadingFromCache() {

  }
}
