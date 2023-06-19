import 'dart:convert';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/views/print/print_payment_cancel_screen.dart';
import 'package:cartoonizer/views/print/print_payment_screen.dart';
import 'package:cartoonizer/views/print/print_payment_success_screen.dart';
import 'package:cartoonizer/views/print/widgets/time_selection_sheet.dart';
import 'package:common_utils/common_utils.dart';

import '../../Widgets/router/routers.dart';
import '../../config.dart';
import '../../models/print_order_entity.dart';
import '../../models/print_orders_entity.dart';
import '../../models/print_payment_entity.dart';

class PrintOrderController extends GetxController {
  late CartoonizerApi cartoonizerApi;
  TabController? tabController;

  List<String> statuses = ["All", "Pending", "Unpaid", "Paid", "Refunded", "voided", "Partial delivered", "Fulfilled", "Restocked"];
  Map<String, ScrollController> sControllers = {
    "Pending": ScrollController(),
    "Unpaid": ScrollController(),
    "Paid": ScrollController(),
    "Refunded": ScrollController(),
    "voided": ScrollController(),
    "All": ScrollController(),
    "Partial delivered": ScrollController(),
    "Fulfilled": ScrollController(),
    "Restocked": ScrollController(),
  };
  Map<String, bool> isLoadings = {
    "pending": false,
    "unpaid": false,
    "paid": false,
    "refunded": false,
    "voided": false,
    "all": false,
    "partial delivered": false,
    "fulfilled": false,
    "restocked": false,
  };

  Map<String, bool> allNeedReLoad = {
    "pending": false,
    "unpaid": false,
    "paid": false,
    "refunded": false,
    "voided": false,
    "all": false,
    "partial delivered": false,
    "fulfilled": false,
    "restocked": false,
  };
  bool _viewInit = false;

  int size = 10;
  String _name = "";

  set name(String value) {
    _name = value;
    timerUtil.startTimer();
    update();
  }

  String get name => _name;

  List<DateTime?> _dates = [];
  int seletedIndex = -1;

  set dates(List<DateTime?> value) {
    _dates = value;
    update();
  }

  List<DateTime?> get dates => _dates;
  String _status = "all";

  set status(String value) {
    _status = value.toLowerCase();
    update();
  }

  String get status => _status;
  TimerUtil timerUtil = TimerUtil();

  onSearchOrder(String value) {
    allNeedReLoad = {
      "pending": true,
      "unpaid": true,
      "paid": true,
      "refunded": true,
      "voided": true,
      "all": true,
      "partial delivered": true,
      "fulfilled": true,
      "restocked": true,
    };
    onRequestData(tabKey: _status, refresh: true);
    allNeedReLoad[_status.toLowerCase()] = false;
  }

  gotoPaymentPage(BuildContext context, PrintOrdersDataRows item) async {
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

    PrintPaymentEntity? payment = await cartoonizerApi.buyPlanCheckout(params);
    PrintOrderEntity orderEntity = PrintOrderEntity.fromJson({"data": item.toJson()});

    Navigator.of(context)
        .push<bool>(
      Right2LeftRouter(
        child: PrintPaymentScreen(
          payUrl: payment?.data.url ?? '',
          sessionId: payment?.data.id ?? '',
          orderEntity: orderEntity,
        ),
      ),
    )
        .then((value) {
      if (value == true) {
        Navigator.of(context).push<void>(Right2LeftRouter(
            child: PrintPaymentSuccessScreen(
          payUrl: payment?.data.url ?? '',
          sessionId: payment?.data.id ?? '',
          orderEntity: orderEntity,
        )));
      } else {
        Navigator.of(context).push<void>(Right2LeftRouter(
            child: PrintPaymentCancelScreen(
          payUrl: payment?.data.url ?? '',
          sessionId: payment?.data.id ?? '',
          orderEntity: orderEntity,
        )));
      }
    });
  }

  onChangeStatus(int index) async {
    _status = statuses[index];
    bool isRefresh = allNeedReLoad[_status.toLowerCase()]!;
    if (isLoadings[_status.toLowerCase()] == true) {
      return;
    }
    if ((orders[_status.toLowerCase()]?.length ?? 0) > 0 && isRefresh == false) {
      return;
    }
    isLoadings[_status.toLowerCase()] = true;
    await onRequestData(tabKey: _status, refresh: isRefresh);
    allNeedReLoad[_status.toLowerCase()] = false;
    update();
  }

  onShowTimeSheet(BuildContext context) {
    ShowTimeSheet.show(
        context,
        TimeSelectionSheet(
          dates: _dates,
          selectedIndex: seletedIndex,
          datesCallback: (dates, index) {
            seletedIndex = index;
            _dates = dates;
            onRequestData(refresh: true, tabKey: _status);
          },
        ));
  }

  set viewInit(bool value) {
    _viewInit = value;
    update();
  }

  Map<String, List<PrintOrdersDataRows>> _orders = {};

  set orders(Map<String, List<PrintOrdersDataRows>> value) {
    _orders = value;
    update();
  }

  Map<String, List<PrintOrdersDataRows>> get orders => _orders;

  bool get viewInit => _viewInit;
  TextEditingController searchOrderController = TextEditingController();

  onSuccess(List<PrintOrdersDataRows> entity, {bool refresh = false, required String tabKey}) async {
    String key = tabKey.toLowerCase();
    _viewInit = true;
    if ((orders[key]?.length ?? 0) > 0 && refresh == false) {
      _orders[key]?.addAll(entity);
    } else {
      _orders[key] = entity;
    }
    isLoadings[key] = false;
    update();
  }

  onListenSwiper(String tabKey) async {
    if (isLoadings[tabKey.toLowerCase()] == true) {
      return;
    }
    ScrollController controller = sControllers[tabKey]!;
    if (controller.position.pixels > controller.position.maxScrollExtent - 20) {
      // 加载更多；
      isLoadings[tabKey.toLowerCase()] = true;
      onRequestData(from: orders[tabKey.toLowerCase()]?.length ?? 0, tabKey: tabKey);
    }
  }

  @override
  void onInit() {
    super.onInit();
    cartoonizerApi = CartoonizerApi().bindController(this);
    timerUtil.setInterval(500);
    timerUtil.setOnTimerTickCallback((millisUntilFinished) {
      onSearchOrder(name);
      timerUtil.cancel();
    });
  }

  onRequestData({int from = 0, bool refresh = false, required String tabKey}) {
    String key = tabKey.toLowerCase();
    Map<String, dynamic> params = {"from": from, "size": size, "name": name};
    if (key != "all" && key != "all status") {
      if (key == "paid" || key == "unpaid" || key == "refunded" || key == "pending") {
        params["financial_status"] = _status.toLowerCase();
      } else {
        params["fulfillment_status"] = _status.toLowerCase();
      }
    }
    if (_dates.length > 0) {
      params["start_time"] = _dates[0]?.millisecondsSinceEpoch ?? 0;
      params["end_time"] = _dates[1]?.millisecondsSinceEpoch ?? 0;
    }
    cartoonizerApi.getShopifyOrders(params).then((value) => {onSuccess(value?.data.rows ?? [], refresh: refresh, tabKey: key)});
  }

  @override
  void onReady() {
    super.onReady();
    onRequestData(tabKey: "all");
  }

  @override
  void dispose() {
    super.dispose();
    cartoonizerApi.unbind();
  }
}
