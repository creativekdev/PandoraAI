import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/main.dart';
import 'package:cartoonizer/models/address_entity.dart';
import 'package:cartoonizer/models/state_entity.dart';
import 'package:cartoonizer/views/common/region/calling_codes_es.dart';
import 'package:cartoonizer/views/common/region/calling_codes_zh.dart';
import 'package:cartoonizer/views/print/print_shipping_controller.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

import '../../common/Extension.dart';
import '../../generated/json/base/json_convert_content.dart';
import '../../models/print_order_entity.dart';
import '../../models/region_code_entity.dart';
import '../../network/base_requester.dart';
import '../common/region/calling_codes_en.dart';
import '../common/region/select_region_page.dart';
import '../common/state/select_state_page.dart';
import '../common/state/states_list.dart';

class PrintEditAddressController extends GetxController {
  PrintEditAddressController({AddressDataCustomerAddress? address}) {
    _places = GoogleMapsPlaces(apiKey: googleMapApiKey);
    _address = address;
  }

  late AddressDataCustomerAddress? _address;
  late AppApi appApi;

  TextEditingController searchAddressController = TextEditingController();
  TextEditingController apartmentController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController secondNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  ScrollController scrollController = ScrollController();

  FocusNode searchAddressFocusNode = FocusNode();

  String getZipCode(List<AddressComponent> addressComponents) {
    for (AddressComponent component in addressComponents) {
      if (component.types.contains('postal_code')) {
        return component.shortName;
      }
    }
    return "";
  }

  setStateEntity(List<AddressComponent> addressComponents) {
    for (AddressComponent component in addressComponents) {
      if (component.types.contains('political') && component.types.contains('administrative_area_level_1')) {
        stateController.text = component.longName;
        _stateEntity?.name = component.longName;
        _stateEntity?.code = component.shortName;
        break;
      }
    }
  }

  String _formattedAddress = "";

  set formattedAddress(String value) {
    _formattedAddress = value;
  }

  String get formattedAddress => _formattedAddress;

  String getCityName(List<AddressComponent> addressComponents) {
    for (AddressComponent component in addressComponents) {
      if (component.types.contains('political') && component.types.contains('locality')) {
        return component.shortName;
      }
    }
    return "";
  }

  List<Prediction> _predictions = [];
  late PrintOrderDataPayload orderPayload;
  late PrintOrderEntity? printOrderEntity;

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
  List<Component> components = [];

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
      components: components, // 限制搜索结果的条件
    );

    // 处理搜索结果
    if (response.isOkay) {
      _predictions = response.predictions;
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

  bool _isShowState = false;

  set isShowState(bool value) {
    _isShowState = value;
    update();
  }

  bool get isShowSate => _isShowState;

  StateEntity? _stateEntity = StateEntity();

  set stateEntity(StateEntity? value) {
    _stateEntity = value;
    update();
  }

  StateEntity? get stateEntity => _stateEntity;

  RegionCodeEntity? _countryEntity;

  set countryEntity(RegionCodeEntity? value) {
    _countryEntity = value;
    update();
  }

  RegionCodeEntity? get countryEntity => _countryEntity;

  RegionCodeEntity? _regionEntity;

  set regionEntity(RegionCodeEntity? value) {
    _regionEntity = value;
    update();
  }

  RegionCodeEntity? get regionEntity => _regionEntity;

  bool _viewInit = false;

  set viewInit(bool value) {
    _viewInit = value;

    update();
  }

  onTapRegion(BuildContext context, SelectRegionType type) {
    SelectRegionPage.pickRegion(context, type: type).then((value) {
      if (value != null) {
        if (type == SelectRegionType.callingCode) {
          _regionEntity = value;
        } else if (type == SelectRegionType.country) {
          _countryEntity = value;
          countryController.text = _countryEntity!.regionName!;
          _isShowState = getStateList();
          components = [Component(Component.country, _countryEntity!.regionCode!)];
        }
        update();
      }
    });
  }

  onTapState(BuildContext context) {
    if (countryController.text.isNotEmpty) {
      SelectStatePage.pickRegion(context, countryEntity?.regionCode ?? '').then((value) {
        if (value != null) {
          stateController.text = value.name!;
          _stateEntity?.name = value.name;
          _stateEntity?.code = value.code;
          update();
        }
      });
    }
  }

  bool getStateList() {
    if (_countryEntity == null) {
      return false;
    }
    return (states_list[_countryEntity?.regionCode ?? ''] ?? []).length > 0;
  }

  Future<bool> onSubmit(BuildContext context) async {
    if (countryController.text.isEmpty) {
      CommonExtension().showToast(S.of(context).pleaseInput.replaceAll('%s', S.of(context).country_region));
      return false;
    }
    if (getStateList() && stateController.text.isEmpty) {
      CommonExtension().showToast(S.of(context).pleaseInput.replaceAll('%s', S.of(context).STATE));
      return false;
    }
    if (searchAddressController.text.isEmpty) {
      CommonExtension().showToast(S.of(context).pleaseInput.replaceAll('%s', S.of(context).address));
      return false;
    }

    if (firstNameController.text.isEmpty) {
      CommonExtension().showToast(S.of(context).pleaseInput.replaceAll('%s', S.of(context).first_name));
      return false;
    }
    if (secondNameController.text.isEmpty) {
      CommonExtension().showToast(S.of(context).pleaseInput.replaceAll('%s', S.of(context).last_name));
      return false;
    }
    if (zipCodeController.text.isEmpty) {
      CommonExtension().showToast(S.of(context).pleaseInput.replaceAll('%s', S.of(context).zip_code));
      return false;
    }
    if (contactNumberController.text.isEmpty) {
      CommonExtension().showToast(S.of(context).pleaseInput.replaceAll('%s', S.of(context).contact_number));
      return false;
    }
    PrintShippingController shippingController = Get.find();
    var address = {
      "first_name": firstNameController.text,
      "last_name": secondNameController.text,
      "phone": "${_regionEntity?.callingCode ?? "+1"} ${contactNumberController.text}",
      "country_code": countryEntity?.regionCode,
      "country": countryEntity?.regionName,
      "address1": formattedAddress.isEmpty
          ? "${searchAddressController.text} ,${cityController.text} ,${stateEntity?.code} ${zipCodeController.text}, ${countryController.text}"
          : formattedAddress,
      "address2": apartmentController.text,
      "zip": zipCodeController.text,
      "default": shippingController.addresses.length > 0 ? (_address != null ? _address?.xDefault : false) : true,
      "city": cityController.text,
      "province": stateEntity?.name,
      "province_code": stateEntity?.code
    };

    if (_address != null) {
      await appApi.updateAddress(address, _address!.id).then((value) {
        if (value?.data is AddressData) {
          CommonExtension().showToast(S.of(context).update_address_success);
          Navigator.pop(context);
        }
      });
    } else {
      await appApi.createAddress(address).then((value) {
        if (value?.data is AddressData) {
          CommonExtension().showToast(S.of(context).save_address_success);
          Navigator.pop(context);
        }
      });
    }
    return true;
  }

  Future<bool> onDeleteAddress(BuildContext context) async {
    BaseEntity? entity = await appApi.deletePrintAddress(8332508365020);
    if (entity == null) {
      return false;
    } else {
      CommonExtension().showToast(S.of(context).delete_address_success);
    }
    return true;
  }

  bool get viewInit => _viewInit;

  onSuccess() {
    _viewInit = true;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    if (_address != null) {
      String countryCode = 'US';
      if (_address != null && _address?.countryCode != null) {
        countryCode = _address!.countryCode!;
      }
      _countryEntity = getRegionEntityBy(countryCode!);
      firstNameController.text = _address!.firstName;
      countryController.text = _address?.countryName ?? '';
      stateController.text = _address?.province ?? '';
      _stateEntity?.name = _address?.province ?? '';
      _stateEntity?.code = _address?.provinceCode ?? '';
      searchAddressController?.text = _address?.address1 ?? '';
      apartmentController.text = _address?.address2 ?? '';
      secondNameController.text = _address?.lastName ?? '';
      cityController.text = _address?.city ?? '';
      zipCodeController.text = _address?.zip ?? '';
    } else {
      _regionEntity = RegionCodeEntity();
      _regionEntity?.regionCode = "US";
      _regionEntity?.callingCode = "+1";
      _regionEntity?.regionName = "United States";
      _regionEntity?.regionFlag = "🇺🇸";
      _regionEntity?.regionSyllables = [];
    }

    appApi = AppApi().bindController(this);
    getPhoneBy();
  }

  Future<void> getPhoneBy() async {
    if (_address != null) {
      PhoneNumber number;
      try {
        number = await PhoneNumber.getRegionInfoFromPhoneNumber(_address?.phone ?? '');
      } catch (_) {
      } finally {
        _regionEntity = getRegionEntityBy('US');
        contactNumberController.text = _address?.phone.substring(_regionEntity?.callingCode?.length ?? 0) ?? '';
        _viewInit = true;
        update();
      }
    }
    _viewInit = true;
    update();
  }

  List<Map<String, dynamic>> _getCallingCodeList() {
    if (MyApp.currentLocales == 'en') {
      return calling_code_en;
    } else if (MyApp.currentLocales == 'zh') {
      return calling_code_zh;
    } else if (MyApp.currentLocales == 'es') {
      return calling_code_es;
    }
    return calling_code_en;
  }

  RegionCodeEntity getRegionEntityBy(String countryCode) {
    print(countryCode);
    List<RegionCodeEntity> dataList = jsonConvert.convertListNotNull<RegionCodeEntity>(_getCallingCodeList())!;
    for (RegionCodeEntity region in dataList) {
      if (region.regionCode == countryCode) {
        return region;
      }
    }
    return RegionCodeEntity();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
    appApi.unbind();
    searchAddressController.dispose();
    apartmentController.dispose();
    firstNameController.dispose();
    secondNameController.dispose();
    searchAddressFocusNode.dispose();
    zipCodeController.dispose();
    contactNumberController.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
