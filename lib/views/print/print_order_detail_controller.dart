import 'dart:convert';

import 'package:cartoonizer/Common/importFile.dart';

import '../../models/print_orders_entity.dart';

class PrintOrderDetailController extends GetxController {
  PrintOrderDetailController({required this.rows}) {
    order = PrintOrdersDataRowsPayloadOrder.fromJson(jsonDecode(rows.payload)["order"]);
  }

  PrintOrdersDataRows rows;

  bool _viewInit = false;
  late PrintOrdersDataRowsPayloadOrder order;

  set viewInit(bool value) {
    _viewInit = value;
    update();
  }

  bool get viewInit => _viewInit;

  onSuccess(List<PrintOrdersDataRows> entity) {
    _viewInit = true;
    update();
  }

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
