import 'package:cartoonizer/views/print/print_order_controller.dart';
import 'package:cartoonizer/views/print/print_order_detail_screen.dart';
import 'package:cartoonizer/views/print/widgets/print_options_item.dart';
import 'package:cartoonizer/views/print/widgets/print_order_item.dart';

import '../../Common/importFile.dart';
import '../../images-res.dart';

class PrintOrderScreen extends StatefulWidget {
  const PrintOrderScreen({Key? key}) : super(key: key);

  @override
  State<PrintOrderScreen> createState() => _PrintOrderScreenState();
}

class _PrintOrderScreenState extends State<PrintOrderScreen> {
  PrintOrderController controller = Get.put(PrintOrderController());

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            "Orders".tr,
            style: TextStyle(
              color: Colors.white,
              fontSize: $(18),
            ),
          ),
          leading: Image.asset(
            Images.ic_back,
            width: $(24),
          )
              .intoContainer(
            margin: EdgeInsets.all($(14)),
          )
              .intoGestureDetector(onTap: () {
            Navigator.pop(context);
          }),
        ),
        backgroundColor: ColorConstant.BackgroundColor,
        body: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.center, children: [
          Container(
            alignment: Alignment.centerLeft,
            margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(8)),
            height: $(40),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                TextField(
                  controller: controller.searchOrderController,
                  cursorColor: ColorConstant.White,
                  style: TextStyle(color: ColorConstant.White, fontSize: $(14)),
                  decoration: InputDecoration(
                    hintText: 'Search order',
                    hintStyle: TextStyle(color: Colors.white38, fontSize: $(14)),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular($(8)),
                    ),
                    suffixIcon: Padding(
                      padding: EdgeInsets.all($(6)),
                      child: Image.asset(
                        Images.ic_search,
                        color: Colors.white38,
                        width: $(12),
                        height: $(12),
                      ),
                    ),
                  ),
                ).intoContainer(
                  margin: EdgeInsets.only(left: 0, right: 40),
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
                  ),
                )
              ],
            ),
          ),
          TabBar(
            enableFeedback: false,
            labelColor: Colors.white,
            indicatorColor: Colors.transparent,
            labelStyle: TextStyle(fontSize: $(14)),
            tabs: const <Widget>[
              Tab(
                text: 'List',
              ),
              Tab(
                text: 'Grid',
              ),
            ],
          ),
          DividerLine(
            left: 0,
          ),
          Expanded(
              child: TabBarView(children: [
            _AutomaticKeepAlive(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    return PrintOrderItem().intoGestureDetector(onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: RouteSettings(name: "/PrintOrderDetailScreen"),
                            builder: (context) => PrintOrderDetailScreen(),
                          ));
                    });
                  }, childCount: 50)),
                ],
              ),
            ),
            _AutomaticKeepAlive(
              child: CustomScrollView(
                slivers: [
                  SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                    return PrintOrderItem();
                  }, childCount: 50)),
                ],
              ),
            ),
          ]))
        ]),
      ),
    );
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
