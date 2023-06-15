import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/views/print/widgets/time_selection_sheet.dart';

import '../../models/print_orders_entity.dart';

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
    "Pending": false,
    "Unpaid": false,
    "Paid": false,
    "Refunded": false,
    "voided": false,
    "All": false,
    "Partial delivered": false,
    "Fulfilled": false,
    "Restocked": false,
  };
  bool _viewInit = false;

  int size = 4;
  String name = "";
  List<DateTime?> _dates = [];

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

  onChangeStatus(int index) {
    _status = statuses[index];
    if ((orders[_status.toLowerCase()]?.length ?? 0) > 0) {
      return;
    }
    onRequestData();
    update();
  }

  onShowTimeSheet(BuildContext context) {
    ShowTimeSheet.show(context, TimeSelectionSheet(
      datesCallback: (dates) {
        _dates = dates;
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

  onSuccess(List<PrintOrdersDataRows> entity) {
    _viewInit = true;
    if ((orders[_status.toLowerCase()]?.length ?? 0) > 0) {
      _orders[_status.toLowerCase()]?.addAll(entity);
    } else {
      _orders[_status.toLowerCase()] = entity;
    }
    isLoadings[_status.toLowerCase()] = false;
    update();
  }

  onListenSwiper(String tabKey) {
    if (isLoadings[_status.toLowerCase()] == true) {
      return;
    }

    ScrollController controller = sControllers[tabKey]!;
    if (controller.position.pixels > controller.position.maxScrollExtent - 20) {
      // 加载更多；
      isLoadings[_status.toLowerCase()] = true;
      onRequestData(from: orders[tabKey.toLowerCase()]?.length ?? 0);
    }
  }

  @override
  void onInit() {
    super.onInit();
    searchOrderController.addListener(() {
      if (searchOrderController.text != name) {
        name = searchOrderController.text;
        onRequestData();
      }
    });
    cartoonizerApi = CartoonizerApi().bindController(this);
    onRequestData();
  }

  onRequestData({int from = 0}) {
    Map<String, dynamic> params = {"from": from, "size": size, "name": name};
    if (_status.toLowerCase() != "all" && _status.toLowerCase() != "all status") {
      if (_status.toLowerCase() == "paid" || _status.toLowerCase() == "unpaid" || _status.toLowerCase() == "refunded" || _status.toLowerCase() == "pending") {
        params["financial_status"] = _status.toLowerCase();
      } else {
        params["fulfillment_status"] = _status.toLowerCase();
      }
    }
    if (_dates.length > 0) {
      params["start_time"] = _dates[0]?.millisecondsSinceEpoch ?? 0;
      params["end_time"] = _dates[1]?.millisecondsSinceEpoch ?? 0;
    }
    cartoonizerApi.getShopifyOrders(params).then((value) => {onSuccess(value?.data.rows ?? [])});
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
