import 'dart:convert';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/models/get_address_entity.dart';
import 'package:cartoonizer/views/print/print_controller.dart';
import 'package:cartoonizer/views/print/print_payment_cancel_screen.dart';
import 'package:cartoonizer/views/print/print_payment_screen.dart';
import 'package:cartoonizer/views/print/print_payment_success_screen.dart';
import 'package:google_maps_webservice/places.dart';

import '../../Controller/effect_data_controller.dart';
import '../../Widgets/router/routers.dart';
import '../../app/user/user_manager.dart';
import '../../models/address_entity.dart';
import '../../models/print_order_entity.dart';
import '../../models/print_orders_entity.dart';
import '../../models/print_payment_entity.dart';
import '../../models/print_product_entity.dart';

class PrintShippingController extends GetxController {
  late AppApi appApi;

  ScrollController scrollController = ScrollController();

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

  late PrintOrderDataPayload orderPayload;
  late PrintOrderEntity? printOrderEntity;

  // late GetAddressEntity? address;
  late List<AddressDataCustomerAddress> addresses;
  AddressDataCustomerAddress? seletedAddress = null;

  bool _isResult = false;

  set isResult(bool value) {
    _isResult = value;
    update();
  }

  bool get isResult => _isResult;

  List<Component> components = [];

  int _deliveryIndex = 0;

  int get deliveryIndex => _deliveryIndex;

  set deliveryIndex(int value) {
    _deliveryIndex = value;
    update();
  }

  onUpdateAddress(int index) {
    AddressDataCustomerAddress? address = addresses[index];
    if (address.id != seletedAddress?.id) {
      seletedAddress = address;
      update();
    }
  }

  onTapDeliveryType(int index) {
    _deliveryIndex = index;
    _total = printController.getSubTotal() + effectdatacontroller.data!.shippingMethods[_deliveryIndex].shippingRateData.fixedAmount.amount / 100;
    update();
  }

  bool _isShowState = false;

  set isShowState(bool value) {
    _isShowState = value;
    update();
  }

  bool get isShowSate => _isShowState;

  bool _viewInit = false;

  set viewInit(bool value) {
    _viewInit = value;
    update();
  }

  Future<bool> onSubmit(BuildContext context) async {
    if (seletedAddress == null) {
      return false;
    }
    var address = {
      "first_name": seletedAddress?.firstName,
      "last_name": seletedAddress?.lastName,
      "phone": seletedAddress?.phone,
      "country_code": seletedAddress?.countryCode,
      "country": seletedAddress?.country,
      "address1": seletedAddress?.address1,
      "address2": seletedAddress?.address2,
      "zip": seletedAddress?.zip,
      "default": true,
      "city": seletedAddress?.city,
      "province": seletedAddress?.province,
      "province_code": seletedAddress?.provinceCode
    };
    await getVariantId();
    var body = {
      "variant_id": variantId,
      "quantity": printController.quantity,
      "customer": {
        "phone": seletedAddress?.phone,
        "first_name": seletedAddress?.firstName,
        "last_name": seletedAddress?.lastName,
        "addresses": [address],
        "send_email_welcome": false,
        "email": UserManager().user?.getShownEmail() ?? '',
        "name": "${seletedAddress?.firstName} ${seletedAddress?.lastName}"
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
            "phone": seletedAddress?.phone,
            "first_name": seletedAddress?.firstName,
            "last_name": seletedAddress?.lastName,
            "addresses": [address],
          },
          "delivery": effectdatacontroller.data!.shippingMethods[_deliveryIndex].shippingRateData.toJson(),
          "image": printController.preview_image,
        },
      })
    };
    printOrderEntity = await appApi.shopifyCreateOrder(body);
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

    PrintPaymentEntity? payment = await appApi.buyPlanCheckout(params);
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

  @override
  void onInit() {
    super.onInit();
    appApi = AppApi().bindController(this);
    _total = printController.getSubTotal() + effectdatacontroller.data!.shippingMethods[_deliveryIndex].shippingRateData.fixedAmount.amount / 100;
  }

  onRequestAddress() async {
    GetAddressEntity? address = await appApi.getAddress();
    addresses = address?.data?.customer.addresses ?? [];
    seletedAddress = addresses.first;
    _viewInit = true;
    update();
  }

  @override
  void onReady() {
    super.onReady();
    onRequestAddress();
  }

  @override
  void dispose() {
    super.dispose();
    appApi.unbind();
  }
}
