import 'dart:convert';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/views/print/print_controller.dart';
import 'package:cartoonizer/views/print/print_payment_cancel_screen.dart';
import 'package:cartoonizer/views/print/print_payment_screen.dart';
import 'package:cartoonizer/views/print/print_payment_success_screen.dart';
import 'package:google_maps_webservice/places.dart';

import '../../Controller/effect_data_controller.dart';
import '../../Widgets/router/routers.dart';
import '../../models/print_order_entity.dart';
import '../../models/print_orders_entity.dart';
import '../../models/print_payment_entity.dart';
import '../../models/print_product_entity.dart';
import '../../models/region_code_entity.dart';
import '../common/region/select_region_page.dart';

class PrintShippingController extends GetxController {
  PrintShippingController() {
    _places = GoogleMapsPlaces(apiKey: googleMapApiKey);
  }

  late CartoonizerApi cartoonizerApi;

  TextEditingController searchAddressController = TextEditingController();
  TextEditingController apartmentController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController secondNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();
  FocusNode searchAddressFocusNode = FocusNode();

  EffectDataController effectdatacontroller = Get.find();
  PrintController printController = Get.find();

  String _payUrl = "";

  set payUrl(String value) {
    _payUrl = value;
    update();
  }

  String get payUrl => _payUrl;

  double _total = 0.0;

  set total(double value) {
    _total = value;
    update();
  }

  String _variantId = "";

  String getZipCode(List<AddressComponent> addressComponents) {
    for (AddressComponent component in addressComponents) {
      if (component.types.contains('postal_code')) {
        return component.shortName;
      }
    }
    return "";
  }

  set variantId(String value) {
    _variantId = value;
    searchAddressFocusNode.hasFocus;
    update();
  }

  String get variantId => _variantId;

  double get total => _total;

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
    _total = printController.getSubTotal() + effectdatacontroller.data!.shippingMethods[_deliveryIndex].shippingRateData.fixedAmount.amount / 100;
    update();
  }

  // String? regionName;
  // String? callingCode;
  // String? regionCode;
  // String? regionFlag;
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

  onTapRegion(BuildContext context) {
    SelectRegionPage.pickRegion(context).then((value) {
      if (value != null) {
        _regionEntity = value;
        update();
      }
    });
  }

  Future<bool> onSubmit(BuildContext context) async {
    if (searchAddressController.text.isEmpty) {
      CommonExtension().showToast(S.of(context).pleaseInput.replaceAll('%s', S.of(context).address));
      return false;
    }
    if (zipCodeController.text.isEmpty) {
      CommonExtension().showToast(S.of(context).pleaseInput.replaceAll('%s', S.of(context).zip_code));
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
    if (contactNumberController.text.isEmpty) {
      CommonExtension().showToast(S.of(context).pleaseInput.replaceAll('%s', S.of(context).contact_number));
      return false;
    }
    var address = {
      "first_name": firstNameController.text,
      "last_name": secondNameController.text,
      "phone": "${_regionEntity?.callingCode ?? "+1"}" + contactNumberController.text,
      "country_code": regionEntity?.regionCode,
      "country_name": regionEntity?.regionName,
      "country": regionEntity?.regionName,
      "address1": searchAddressController.text,
      "address2": apartmentController.text,
      "zip": zipCodeController.text,
      "default": false
    };
    await getVariantId();
    var body = {
      "variant_id": variantId,
      "quantity": printController.quantity,
      "customer": {
        "phone": "${_regionEntity?.callingCode ?? "+1"}" + contactNumberController.text,
        "first_name": firstNameController.text,
        "last_name": secondNameController.text,
        "addresses": [address],
        "send_email_welcome": false,
        "email": UserManager().user?.getShownEmail() ?? '',
        "name": firstNameController.text + " " + secondNameController.text
      },
      "shipping_address": address,
      "shipping_price": effectdatacontroller.data!.shippingMethods[_deliveryIndex].shippingRateData.fixedAmount.amount / 100.0,
      "shipping_method": effectdatacontroller.data!.shippingMethods[_deliveryIndex].shippingRateData.displayName,
      "name": printController.optionData.title,
      "ps_image": printController.ai_image,
      "ps_preview_image": printController.preview_image,
      "payload": jsonEncode({
        "repay": {
          "productInfo": {
            "name": printController.optionData.title,
            "quantity": printController.quantity,
            "desc": printController.optionData.desc,
            "price": (double.parse(printController.product?.data.rows.first.variants.edges.first.node.price ?? "0") * 100).toInt()
          },
          "customer": {
            "phone": "${_regionEntity?.callingCode ?? "+1"}" + contactNumberController.text,
            "first_name": firstNameController.text,
            "last_name": secondNameController.text,
            "addresses": [address],
          },
          "delivery": effectdatacontroller.data!.shippingMethods[_deliveryIndex].shippingRateData.toJson(),
          "image": printController.preview_image,
        },
      })
    };
    printOrderEntity = await cartoonizerApi.shopifyCreateOrder(body);
    if (printOrderEntity == null) {
      return false;
    }
    String payload = printOrderEntity!.data.payload;
    orderPayload = PrintOrderDataPayload.fromJson(json.decode(payload));
    // _payUrl = orderPayload.order.orderStatusUrl;
    return true;
  }

  gotoPaymentPage(BuildContext context, String source) async {
    int amount = (effectdatacontroller.data!.shippingMethods[_deliveryIndex].shippingRateData.fixedAmount.amount).toInt();
    final params = {
      "order_id": printOrderEntity?.data.id,
      "order_type": "ps-order",
      "success_url": Config.instance.successUrl,
      "cancel_url": Config.instance.cancelUrl,
      "shipping_options": [
        {
          "shipping_rate_data": {
            "type": 'fixed_amount',
            "fixed_amount": {"amount": amount, "currency": "usd"},
            "display_name": effectdatacontroller.data!.shippingMethods[_deliveryIndex].shippingRateData.displayName,
          }
        }
      ],
      "line_items": [
        {
          "price_data": {
            "currency": "usd",
            "unit_amount": (double.parse(printController.product?.data.rows.first.variants.edges.first.node.price ?? "0") * 100).toInt(),
            "product_data": {
              "name": printOrderEntity?.data.name,
              "images": [printController.preview_image],
            },
            "tax_behavior": "exclusive",
          },
          "adjustable_quantity": {"enabled": false},
          "quantity": printController.quantity
        }
      ],
    };

    PrintPaymentEntity? payment = await cartoonizerApi.buyPlanCheckout(params);
    PrintOrdersDataRows rows = PrintOrdersDataRows.fromJson(printOrderEntity!.data.toJson());
    Navigator.of(context)
        .push<bool>(
      Right2LeftRouter(
        settings: RouteSettings(name: '/PrintPaymentScreen'),
        child: PrintPaymentScreen(
          payUrl: payment?.data.url ?? '',
          sessionId: payment?.data.id ?? '',
          orderEntity: rows,
          source: source,
        ),
      ),
    )
        .then((value) {
      if (value == true) {
        Navigator.of(context).push<void>(Right2LeftRouter(
            settings: RouteSettings(name: '/PrintPaymentSuccessScreen'),
            child: PrintPaymentSuccessScreen(
              payUrl: payment?.data.url ?? '',
              sessionId: payment?.data.id ?? '',
              orderEntity: rows,
              source: source,
            )));
      } else {
        Navigator.of(context).push<void>(Right2LeftRouter(
            settings: RouteSettings(name: '/PrintPaymentCancelScreen'),
            child: PrintPaymentCancelScreen(
              payUrl: payment?.data.url ?? '',
              sessionId: payment?.data.id ?? '',
              orderEntity: rows,
              source: source,
            )));
      }
    });
  }

  getVariantId() async {
    Map<String, String> selectOptions = printController.selectOptions;
    List<PrintProductDataRowsVariantsEdges> variants = printController.product!.data.rows.first.variants.edges;
    for (var i = 0; i < variants.length; i++) {
      final variant = variants[i];
      bool found = true;
      for (var j = 0; j < variant.node.selectedOptions.length; j++) {
        final option = variant.node.selectedOptions[j];
        if (option.value != selectOptions[option.name]) {
          found = false;
          break;
        }
      }
      if (found) {
        variantId = variant.node.id.split("/").last;
      }
    }
  }

  bool get viewInit => _viewInit;

  onSuccess() {
    _viewInit = true;
    update();
  }

  @override
  void onInit() {
    super.onInit();
    _regionEntity = RegionCodeEntity();
    _regionEntity?.regionCode = "US";
    _regionEntity?.callingCode = "+1";
    _regionEntity?.regionName = "United States";
    _regionEntity?.regionFlag = "🇺🇸";
    _regionEntity?.regionSyllables = [];

    cartoonizerApi = CartoonizerApi().bindController(this);
    _total = printController.getSubTotal() + effectdatacontroller.data!.shippingMethods[_deliveryIndex].shippingRateData.fixedAmount.amount / 100;
    _viewInit = true;
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
    searchAddressFocusNode.dispose();
    zipCodeController.dispose();
    contactNumberController.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
