import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:google_maps_webservice/places.dart';

import '../../Controller/effect_data_controller.dart';
import '../../models/region_code_entity.dart';
import '../common/region/select_region_page.dart';

class PrintShippingController extends GetxController {
  PrintShippingController() {
    _places = GoogleMapsPlaces(apiKey: googleMapApiKey);
  }

  late CartoonizerApi cartoonizerApi;

  TextEditingController searchAddressController = TextEditingController();
  TextEditingController apartmentController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController secondNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();

  EffectDataController effectdatacontroller = Get.find();

  List<Prediction> _predictions = [];

  bool _isResult = false;

  set isResult(bool value) {
    _isResult = value;
    update();
  }

  bool get isResult => _isResult;

  set predictions(List<Prediction> value) {
    _predictions = value;
    update();
  }

  List<Prediction> get predictions => _predictions;


  Future searchLocation(GoogleMapsPlaces places, String text) async {
    if (text.isEmpty) {
      _predictions = [];
      return;
    }
    // 进行地点搜索操作
    PlacesAutocompleteResponse response = await places.autocomplete(
      text, // 搜索关键字
      types: ['geocode'], // 限制搜索结果类型为地理编码（地址）
      // language: 'en', // 搜索结果的语言
      // components: [Component(Component.country, 'us')], // 限制搜索结果的条件
    );

    // 处理搜索结果
    if (response.isOkay) {
      _predictions = response.predictions;
      print(_predictions);
    }
  }

  OverlayEntry? _overlayEntry;

  set overlayEntry(OverlayEntry? value) {
    _overlayEntry = value;
    update();
  }

  OverlayEntry? get overlayEntry => _overlayEntry;
  final String googleMapApiKey = 'AIzaSyAb_K04sbhK0h7hDPeHlOcNPtlX059TxHk'; // 替换为你的 Google Maps API 密钥

  GoogleMapsPlaces? _places;

  set places(GoogleMapsPlaces value) {
    _places = value;
    update();
  }

  GoogleMapsPlaces get places => _places!;

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
    searchAddressController.dispose();
    apartmentController.dispose();
    firstNameController.dispose();
    secondNameController.dispose();
    contactNumberController.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
