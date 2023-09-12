import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/api/app_api.dart';

import '../../models/print_option_entity.dart';

class PrintOptionController extends GetxController {
  late AppApi appApi;
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
    appApi = AppApi().bindController(this);
    appApi.printTemplates(from: 0, size: 10).then((value) => {
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
    appApi.unbind();
  }
}
