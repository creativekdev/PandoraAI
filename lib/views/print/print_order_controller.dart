import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';

class PrintOrderController extends GetxController {
  late CartoonizerApi cartoonizerApi;

  bool _viewInit = false;

  set viewInit(bool value) {
    _viewInit = value;
    update();
  }

  bool get viewInit => _viewInit;
  TextEditingController searchOrderController = TextEditingController();

  // onSuccess(PrintOptionEntity entity) {
  //
  // }

  @override
  void onInit() {
    super.onInit();
    cartoonizerApi = CartoonizerApi().bindController(this);
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
    cartoonizerApi.unbind();
  }
}
