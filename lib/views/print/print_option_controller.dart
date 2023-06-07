import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';

import '../../models/print_option_entity.dart';

class PrintOptionController extends GetxController {
  late CartoonizerApi cartoonizerApi;
  PrintOptionEntity printOptionEntity = PrintOptionEntity();

  bool _viewInit = false;

  set viewInit(bool value) {
    _viewInit = value;
    update();
  }

  bool get viewInit => _viewInit;

  onSuccess(PrintOptionEntity entity) {
    printOptionEntity = entity;
    _viewInit = true;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    cartoonizerApi = CartoonizerApi().bindController(this);
    cartoonizerApi.printTemplates(from: 0, size: 10).then((value) => {
          if (value != null)
            {
              onSuccess(value),
            }
        });
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
