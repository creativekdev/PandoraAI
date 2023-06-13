import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/views/print/widgets/time_selection_sheet.dart';

import '../../models/print_orders_entity.dart';

class PrintOrderController extends GetxController {
  late CartoonizerApi cartoonizerApi;
  TabController? tabController;

  List<String> statuses = ["All", "Pending", "Unpaid", "Paid", "Refunded", "voided", "Partial delivered", "Fulfilled", "Restocked"];

  bool _viewInit = false;

  List<int> from = [0, 0, 0, 0, 0, 0, 0, 0];
  int size = 10;
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
    _orders[_status.toLowerCase()] = entity;
    update();
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

  onRequestData() {
    Map<String, dynamic> params = {"from": tabController != null ? from[tabController!.index] : 0, "size": size, "name": name};
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
