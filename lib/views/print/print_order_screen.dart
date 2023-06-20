import 'package:cartoonizer/Widgets/search_bar.dart';
import 'package:cartoonizer/views/print/print_order_controller.dart';
import 'package:cartoonizer/views/print/print_order_detail_screen.dart';
import 'package:cartoonizer/views/print/widgets/print_options_item.dart';
import 'package:cartoonizer/views/print/widgets/print_order_item.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../../Common/importFile.dart';
import '../../Widgets/app_navigation_bar.dart';
import '../../Widgets/blank_area_intercept.dart';
import '../../images-res.dart';
import '../../models/print_orders_entity.dart';

class PrintOrderScreen extends StatefulWidget {
  String source;

  PrintOrderScreen({
    Key? key,
    required this.source,
  }) : super(key: key);

  @override
  State<PrintOrderScreen> createState() => _PrintOrderScreenState();
}

class _PrintOrderScreenState extends State<PrintOrderScreen> with SingleTickerProviderStateMixin {
  PrintOrderController controller = Get.put(PrintOrderController());

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'print_order_screen');
    controller.tabController = TabController(length: controller.statuses.length, vsync: this);
    controller.tabController!.addListener(() {
      controller.onChangeStatus(controller.tabController!.index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: controller.statuses.length,
      child: BlankAreaIntercept(
        child: Scaffold(
          appBar: AppNavigationBar(
            backgroundColor: Colors.transparent,
            middle: Text(
              S.of(context).orders,
              style: TextStyle(
                color: Colors.white,
                fontSize: $(18),
              ),
            ),
          ),
          backgroundColor: ColorConstant.BackgroundColor,
          body: GetBuilder<PrintOrderController>(
            init: controller,
            builder: (controller) {
              return Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
                Container(
                  alignment: Alignment.centerLeft,
                  margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(8)),
                  height: $(40),
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      SearchBar(
                        controller: controller.searchOrderController,
                        hintStyle: TextStyle(color: Colors.white38, fontSize: $(14)),
                        style: TextStyle(color: Colors.white, fontSize: $(14)),
                        onSearchClear: () {
                          controller.searchOrderController.clear();
                          // controller.onSearchOrder("");
                          controller.name = "";
                        },
                        onChange: (String value) {
                          controller.name = value;
                        },
                        onStartSearch: () {},
                        contentPadding: EdgeInsets.only(bottom: $(10)),
                      ).intoContainer(
                        padding: EdgeInsets.only(left: $(10)),
                        margin: EdgeInsets.only(right: $(40)),
                        decoration: BoxDecoration(
                          color: Color(0xFF0F0F0F),
                          borderRadius: BorderRadius.circular($(8)),
                        ),
                      ),
                      Positioned(
                        right: $(0),
                        child: Image.asset(
                          Images.ic_filter,
                          width: $(24),
                        ).intoGestureDetector(onTap: () {
                          controller.onShowTimeSheet(context);
                        }),
                      )
                    ],
                  ),
                ),
                Theme(
                  data: ThemeData(
                    splashColor: Colors.transparent, // 点击时的水波纹颜色设置为透明
                    highlightColor: Colors.transparent, // 点击时的背景高亮颜色设置为透明
                  ),
                  child: TabBar(
                    controller: controller.tabController,
                    enableFeedback: false,
                    automaticIndicatorColorAdjustment: false,
                    isScrollable: true,
                    labelColor: Colors.white,
                    indicatorColor: Colors.transparent,
                    labelStyle: TextStyle(fontSize: $(14)),
                    onTap: (index) {
                      controller.tabController?.index = index;
                      controller.onChangeStatus(index);
                    },
                    tabs: controller.statuses.map((String tab) {
                      return Tab(text: controller.getTabName(tab, context));
                    }).toList(),
                  ),
                ),
                DividerLine(
                  left: 0,
                ),
                Expanded(
                  child: TabBarView(
                      controller: controller.tabController,
                      children: controller.statuses.map((e) {
                        if (controller.orders[e.toLowerCase()] != null && controller.orders[e.toLowerCase()]!.length > 0) {
                          return _AutomaticKeepAlive(
                            child: CustomScrollView(
                              controller: controller.sControllers[e]
                                ?..addListener(() {
                                  controller.onListenSwiper(e);
                                }),
                              slivers: [
                                SliverList(
                                    delegate: SliverChildBuilderDelegate((context, index) {
                                  PrintOrdersDataRows rows = controller.orders[e.toLowerCase()]![index];

                                  return PrintOrderItem(rows: rows).intoGestureDetector(onTap: () {
                                    if (rows.financialStatus == "unpaid" || rows.financialStatus == "pending") {
                                      controller.gotoPaymentPage(context, rows, widget.source);
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
                                  });
                                }, childCount: controller.orders[e.toLowerCase()]?.length ?? 0)),
                              ],
                            ),
                          );
                        }
                        return Center(child: TitleTextWidget(S.of(context).empty_msg, ColorConstant.White, FontWeight.normal, $(12)));
                      }).toList()),
                ),
              ]);
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    Get.delete<PrintOrderController>();
    super.dispose();
  }
}

class _AutomaticKeepAlive extends StatefulWidget {
  final Widget child;

  const _AutomaticKeepAlive({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<_AutomaticKeepAlive> createState() => _AutomaticKeepAliveState();
}

class _AutomaticKeepAliveState extends State<_AutomaticKeepAlive> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
