import 'dart:convert';

import 'package:cartoonizer/views/print/print_order_controller.dart';

import '../../../common/event_bus_helper.dart';
import '../../../common/importFile.dart';
import '../../../widgets/router/routers.dart';
import '../../../api/app_api.dart';
import '../../../config.dart';
import '../../../models/print_orders_entity.dart';
import '../../../models/print_payment_entity.dart';
import '../print_payment_cancel_screen.dart';
import '../print_payment_screen.dart';
import '../print_payment_success_screen.dart';

class PrintOrderListController extends GetxController {
  PrintOrderListController({required this.tabKey}) {}

  late AppApi appApi;

  List<PrintOrdersDataRows> _orders = [];

  set orders(List<PrintOrdersDataRows> value) {
    _orders = value;
    update();
  }

  late StreamSubscription nameListen;
  late StreamSubscription dateTimeListen;

  bool _isfirstLoading = true;

  set isfirstLoading(bool value) {
    _isfirstLoading = value;
    update();
  }

  bool get isfirstLoading => _isfirstLoading;

  String name = '';
  List<DateTime?> dates = [];

  List<PrintOrdersDataRows> get orders => _orders;
  ScrollController scrollController = ScrollController();
  bool isLoading = false;
  int size = 10;
  final String tabKey;

  onListenSwiper() async {
    if (isLoading == true) {
      return;
    }
    if (scrollController.position.pixels > scrollController.position.maxScrollExtent - 20) {
      // 加载更多；
      isLoading = true;
      onRequestData(
        from: orders.length,
      );
    }
  }

  onRequestData({int from = 0, bool refresh = false}) {
    String key = tabKey.toLowerCase();
    Map<String, dynamic> params = {"from": from, "size": size, "name": name};
    if (key != "all" && key != "all status") {
      if (key == "paid" || key == "unpaid" || key == "refunded" || key == "pending") {
        params["financial_status"] = key;
      } else {
        params["fulfillment_status"] = key;
      }
    }
    if (dates.length > 0) {
      params["start_time"] = dates[0]?.millisecondsSinceEpoch ?? 0;
      params["end_time"] = dates[1]?.millisecondsSinceEpoch ?? 0;
    }
    appApi.getShopifyOrders(params).then((value) => {onSuccess(value?.data.rows ?? [], refresh: refresh)});
  }

  @override
  void onInit() {
    super.onInit();
    appApi = AppApi().bindController(this);
    nameListen = EventBusHelper().eventBus.on<OnPrintOrderKeyChangeEvent>().listen((event) {
      onSetName(event.data ?? '');
    });
    dateTimeListen = EventBusHelper().eventBus.on<OnPrintOrderTimeChangeEvent>().listen((event) {
      onSetDateTimes(event.data ?? []);
    });
    PrintOrderController orderController = Get.find();
    name = orderController.searchOrderController.text;
    dates = orderController.dates;
  }

  onSetName(String value) {
    name = value;
    onRequestData(refresh: true);
    update();
  }

  onSetDateTimes(List<DateTime?> value) {
    dates = value;
    onRequestData(refresh: true);
    update();
  }

  onSuccess(List<PrintOrdersDataRows> entity, {bool refresh = false}) async {
    if (_orders.length > 0 && refresh == false) {
      _orders.addAll(entity);
    } else {
      _orders = entity;
    }
    isLoading = false;
    _isfirstLoading = false;
    update();
  }

  @override
  void onReady() {
    super.onReady();
    onRequestData();
  }

  @override
  void onClose() {
    super.onClose();
    nameListen.cancel();
    dateTimeListen.cancel();
    appApi.unbind();
  }

  gotoPaymentPage(BuildContext context, PrintOrdersDataRows item, String source) async {
    PrintOrdersDataRowsPayload payload = PrintOrdersDataRowsPayload.fromJson(jsonDecode(item.payload));
    final params = {
      "order_id": payload.order.id,
      "order_type": "ps-order",
      "success_url": Config.instance.successUrl,
      "cancel_url": Config.instance.cancelUrl,
      "shipping_options": [
        {
          "shipping_rate_data": {
            "type": 'fixed_amount',
            "fixed_amount": {"amount": payload.repay.delivery.fixedAmount.amount, "currency": "usd"},
            "display_name": item.name,
          }
        }
      ],
      "line_items": [
        {
          "price_data": {
            "currency": "usd",
            "unit_amount": payload.repay.productInfo.price,
            "product_data": {
              "name": item.name,
              "images": [item.psPreviewImage],
            },
            "tax_behavior": "exclusive",
          },
          "adjustable_quantity": {"enabled": false},
          "quantity": payload.repay.productInfo.quantity
        }
      ],
    };

    PrintPaymentEntity? payment = await appApi.buyPlanCheckout(params);
    // PrintOrderEntity orderEntity = PrintOrderEntity.fromJson({"data": item.toJson()});

    Events.printStartPay(source: source, orderId: item.id.toString());
    Navigator.of(context)
        .push<bool>(
      Right2LeftRouter(
        settings: RouteSettings(name: '/PrintPaymentScreen'),
        child: PrintPaymentScreen(
          payUrl: payment?.data.url ?? '',
          sessionId: payment?.data.id ?? '',
          orderEntity: item,
          source: source,
        ),
      ),
    )
        .then((value) {
      if (value == true) {
        Events.printPayOrderSuccess(source: source, orderId: item.id.toString());
        Navigator.of(context).push<void>(Right2LeftRouter(
            settings: RouteSettings(name: '/PrintPaymentSuccessScreen'),
            child: PrintPaymentSuccessScreen(
              payUrl: payment?.data.url ?? '',
              sessionId: payment?.data.id ?? '',
              orderEntity: item,
              source: source,
            )));
      } else {
        Events.printPayOrderCancel(source: source, orderId: item.id.toString());
        Navigator.of(context).push<void>(Right2LeftRouter(
            settings: RouteSettings(name: '/PrintPaymentCancelScreen'),
            child: PrintPaymentCancelScreen(
              payUrl: payment?.data.url ?? '',
              sessionId: payment?.data.id ?? '',
              orderEntity: item,
              source: source,
            )));
      }
    });
  }
}
