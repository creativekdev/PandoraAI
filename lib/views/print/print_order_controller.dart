import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/views/print/widgets/time_selection_sheet.dart';
import 'package:common_utils/common_utils.dart';

import '../../Common/event_bus_helper.dart';

class PrintOrderController extends GetxController {
  TabController? tabController;

  List<String> statuses = ["All", "Pending", "Unpaid", "Paid", "Refunded", "voided", "Partial delivered", "Fulfilled", "Restocked"];

  String getTabName(String name, BuildContext context) {
    switch (name) {
      case "All":
        return S.of(context).all;
      case "Pending":
        return S.of(context).pending;
      case "Unpaid":
        return S.of(context).unpaid;
      case "Paid":
        return S.of(context).paid;
      case "Refunded":
        return S.of(context).refunded;
      case "voided":
        return S.of(context).voided;
      case "Partial delivered":
        return S.of(context).partial_delivered;
      case "Fulfilled":
        return S.of(context).fulfilled;
      case "Restocked":
        return S.of(context).restocked;
    }
    return "";
  }

  int size = 10;

  int seletedIndex = -1;

  List<DateTime?> _dates = [];

  set dates(List<DateTime?> value) {
    _dates = value;
    update();
  }

  List<DateTime?> get dates => _dates;
  TimerUtil timerUtil = TimerUtil();

  onShowTimeSheet(BuildContext context) {
    ShowTimeSheet.show(
        context,
        TimeSelectionSheet(
          dates: _dates,
          selectedIndex: seletedIndex,
          datesCallback: (dates, index) {
            seletedIndex = index;
            _dates = dates;
            EventBusHelper().eventBus.fire(OnPrintOrderTimeChangeEvent(data: _dates));
          },
        ));
  }

  TextEditingController searchOrderController = TextEditingController();

  String onGetName() {
    return searchOrderController.text;
  }

  @override
  void onInit() {
    super.onInit();
    timerUtil.setInterval(500);
    timerUtil.setOnTimerTickCallback((millisUntilFinished) {
      EventBusHelper().eventBus.fire(OnPrintOrderKeyChangeEvent(data: searchOrderController.text));
      timerUtil.cancel();
    });
    searchOrderController.addListener(() {
      onTextChanged();
    });
  }

  void onTextChanged() {
    timerUtil.cancel();
    timerUtil.startTimer();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
    timerUtil.cancel();
  }
}
