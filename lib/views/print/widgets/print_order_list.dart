import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/views/print/widgets/print_order_item.dart';
import 'package:cartoonizer/views/print/widgets/print_order_list_controller.dart';

import '../../../Common/importFile.dart';
import '../../../models/print_orders_entity.dart';
import '../print_order_detail_screen.dart';

typedef PrintOrderListShowLoadingCallback = void Function(bool isLoading);

class PrintOrderList extends StatefulWidget {
  const PrintOrderList({
    Key? key,
    required this.tabKey,
    required this.source,
    required this.showLoadingCallback,
  }) : super(key: key);
  final String tabKey;
  final String source;
  final PrintOrderListShowLoadingCallback showLoadingCallback;

  @override
  State<PrintOrderList> createState() => _PrintOrderListState();
}

class _PrintOrderListState extends AppState<PrintOrderList> {
  late PrintOrderListController controller;

  @override
  void initState() {
    super.initState();
    controller = PrintOrderListController(
      tabKey: widget.tabKey,
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    return GetBuilder<PrintOrderListController>(
        tag: widget.tabKey,
        init: controller,
        builder: (controller) {
          if (controller.orders.length > 0) {
            return CustomScrollView(
              controller: controller.scrollController
                ?..addListener(() {
                  controller.onListenSwiper();
                }),
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    PrintOrdersDataRows rows = controller.orders[index];
                    return PrintOrderItem(rows: rows).intoGestureDetector(onTap: () async {
                      widget.showLoadingCallback(true);
                      if (rows.financialStatus == "unpaid" || rows.financialStatus == "pending") {
                        await controller.gotoPaymentPage(context, rows, widget.source);
                        widget.showLoadingCallback(false);
                        return;
                      }
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: RouteSettings(name: "/PrintOrderDetailScreen"),
                            builder: (context) => PrintOrderDetailScreen(
                              rows: rows,
                              source: widget.source,
                            ),
                          ));
                      widget.showLoadingCallback(false);
                    });
                  }, childCount: controller.orders.length),
                ),
              ],
            );
          }
          return LoadingOverlay(
              isLoading: controller.isfirstLoading, child: Center(child: TitleTextWidget(S.of(context).empty_msg, ColorConstant.White, FontWeight.normal, $(12))));
        });
  }

  @override
  void dispose() {
    Get.delete<PrintOrderListController>(tag: widget.tabKey);
    super.dispose();
  }
}
