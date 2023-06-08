import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';

import '../../Controller/effect_data_controller.dart';
import '../../models/region_code_entity.dart';
import '../common/region/select_region_page.dart';

class PrintShippingController extends GetxController {
  late CartoonizerApi cartoonizerApi;

  TextEditingController searchAddressController = TextEditingController();
  TextEditingController apartmentController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController secondNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();

  EffectDataController effectdatacontroller = Get.find();

  int _deliveryIndex = 0;

  int get deliveryIndex => _deliveryIndex;

  set deliveryIndex(int value) {
    _deliveryIndex = value;
    update();
  }

  onTapDeliveryType(int index) {
    _deliveryIndex = index;
    update();
  }


  late RegionCodeEntity _regionEntity = RegionCodeEntity();

  set regionEntity(RegionCodeEntity value) {
    _regionEntity = value;
    update();
  }

  RegionCodeEntity get regionEntity => _regionEntity;

  bool _viewInit = false;

  set viewInit(bool value) {
    _viewInit = value;

    update();
  }

  onTapRegion(BuildContext context) {
    SelectRegionPage.pickRegion(context).then((value) {
      if (value != null) {
        _regionEntity = value;
      }
    });
  }

  bool get viewInit => _viewInit;

  onSuccess() {
    _viewInit = true;
    update();
  }

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
