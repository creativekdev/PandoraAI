import 'dart:convert';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/views/print/print_controller.dart';
import 'package:cartoonizer/views/print/print_payment_cancel_screen.dart';
import 'package:cartoonizer/views/print/print_payment_screen.dart';
import 'package:cartoonizer/views/print/print_payment_success_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_webservice/places.dart';

import '../../Controller/effect_data_controller.dart';
import '../../Widgets/router/routers.dart';
import '../../models/print_order_entity.dart';
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
  TextEditingController firstNameController = TextEditingController();
  TextEditingController secondNameController = TextEditingController();
  TextEditingController contactNumberController = TextEditingController();

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

  set variantId(String value) {
    _variantId = value;
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
      print(value);
      if (value != null) {
        _regionEntity = value;
        update();
      }
    });
  }

  gotoPaymentPage(BuildContext context) async {
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
            "unit_amount": (printController.total * 100).toInt(),
            "product_data": {
              "name": printOrderEntity?.data.name,
              "images": [printController.preview_image],
            },
            "tax_behavior": "exclusive",
          },
          "adjustable_quantity": {"enabled": false},
          "quantity": printController.quatity
        }
      ],
    };

    PrintPaymentEntity? payment = await cartoonizerApi.buyPlanCheckout(params);

    Navigator.of(context)
        .push<bool>(
      Right2LeftRouter(
        child: PrintPaymentScreen(
          payUrl: payment?.data.url ?? '',
          sessionId: payment?.data.id ?? '',
          orderEntity: printOrderEntity!,
          // cancelPayCallBack: (sessionId, payUrl) {
          //   Navigator.of(context).pop();
          //   Navigator.of(context).push<void>(Right2LeftRouter(
          //       child: PrintPaymentCancelScreen(
          //     payUrl: payUrl,
          //     sessionId: sessionId,
          //     orderEntity: printOrderEntity!,
          //   )));
          // },
          // payCompleteCallBack: (sessionId, payUrl) {
          //   Navigator.of(context).pop();
          //   Navigator.of(context).push<void>(Right2LeftRouter(
          //       child: PrintPaymentSuccessScreen(
          //     payUrl: payUrl,
          //     sessionId: sessionId,
          //     orderEntity: printOrderEntity!,
          //   )));
          // },
        ),
      ),
    )
        .then((value) {
      if (value == true) {
        Navigator.of(context).push<void>(Right2LeftRouter(
            child: PrintPaymentSuccessScreen(
          payUrl: payUrl,
          sessionId: payment?.data.id ?? '',
          orderEntity: printOrderEntity!,
        )));
      } else {
        Navigator.of(context).push<void>(Right2LeftRouter(
            child: PrintPaymentCancelScreen(
          payUrl: payUrl,
          sessionId: payment?.data.id ?? '',
          orderEntity: printOrderEntity!,
        )));
      }
    });
  }

  Future<bool> onSubmit() async {
    if (searchAddressController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please input address", gravity: ToastGravity.CENTER);
      return false;
    }
    if (apartmentController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please input apartment/suite/other", gravity: ToastGravity.CENTER);
      return false;
    }
    if (firstNameController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please input first name", gravity: ToastGravity.CENTER);
      return false;
    }
    if (secondNameController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please input second name", gravity: ToastGravity.CENTER);
      return false;
    }
    if (contactNumberController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Please input contact number", gravity: ToastGravity.CENTER);
      return false;
    }
    var address = {
      "first_name": firstNameController.text,
      "last_name": secondNameController.text,
      "phone": "${_regionEntity?.callingCode ?? "+1"}" + contactNumberController.text,
      "country_code": regionEntity?.callingCode,
      "country_name": regionEntity?.regionName,
      "country": regionEntity?.regionName,
      "address1": searchAddressController.text,
      "address2": apartmentController.text,
    };
    await getVariantId();
    var body = {
      "variant_id": variantId,
      "quantity": printController.quatity,
      "customer": {
        "first_name": firstNameController.text,
        "last_name": secondNameController.text,
        "addresses": [address],
      },
      "shipping_address": address,
      "shipping_method": effectdatacontroller.data!.shippingMethods[_deliveryIndex].shippingRateData.displayName,
      "name": printController.optionData.title,
      "ps_image": printController.ai_image,
      "ps_preview_image": printController.preview_image,
    };
    printOrderEntity = await cartoonizerApi.shopifyCreateOrder(body);
    if (printOrderEntity == null) {
      Fluttertoast.showToast(msg: "Something went wrong", gravity: ToastGravity.CENTER);
      return false;
    }
    String payload = printOrderEntity!.data.payload;
    orderPayload = PrintOrderDataPayload.fromJson(json.decode(payload));
    // _payUrl = orderPayload.order.orderStatusUrl;
    return true;
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
    contactNumberController.dispose();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
}
