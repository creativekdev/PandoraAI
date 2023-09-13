import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:cartoonizer/views/print/print_order_detail_controller.dart';
import 'package:cartoonizer/views/print/widgets/print_options_item.dart';
import 'package:cartoonizer/views/print/widgets/print_order_info_item.dart';
import 'package:cartoonizer/views/print/widgets/print_shipping_info_item.dart';
import 'package:common_utils/common_utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../../common/importFile.dart';
import '../../widgets/cacheImage/cached_network_image_utils.dart';
import '../../images-res.dart';
import '../../models/print_orders_entity.dart';

class PrintOrderDetailScreen extends StatefulWidget {
  String source;
  PrintOrdersDataRows rows;

  PrintOrderDetailScreen({
    Key? key,
    required this.rows,
    required this.source,
  }) : super(key: key);

  @override
  State<PrintOrderDetailScreen> createState() => _PrintOrderDetailScreenState();
}

class _PrintOrderDetailScreenState extends State<PrintOrderDetailScreen> {
  late PrintOrderDetailController controller;
  late PrintOrdersDataRows rows;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'print_order_detail_screen');
    rows = widget.rows;
    controller = Get.put(PrintOrderDetailController(rows: rows));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavigationBar(
        middle: Text(
          S.of(context).order_details,
          style: TextStyle(
            color: Colors.white,
            fontSize: $(18),
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: ColorConstant.BackgroundColor,
      body: GetBuilder<PrintOrderDetailController>(
          init: controller,
          builder: (controller) {
            return CustomScrollView(slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12)),
                  color: Color(0xFF1B1C1D),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    TitleTextWidget(
                      "${S.of(context).order_ID} ${rows.shopifyOrderId}",
                      ColorConstant.White,
                      FontWeight.w500,
                      $(17),
                      align: TextAlign.left,
                    ),
                    SizedBox(height: $(16)),
                    DividerLine(
                      left: 0,
                    ),
                    SizedBox(height: $(16)),
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular($(8)),
                        child: CachedNetworkImageUtils.custom(
                          context: context,
                          imageUrl: rows.psPreviewImage,
                          width: $(80),
                          height: $(80),
                          fit: BoxFit.cover,
                        ).intoContainer(
                            decoration: BoxDecoration(
                          color: Color(0xFFFB8888),
                          borderRadius: BorderRadius.circular($(8)),
                        )),
                      ),
                      SizedBox(width: $(16)),
                      Expanded(
                        child: TitleTextWidget(
                          "${rows.name}",
                          ColorConstant.White,
                          FontWeight.w500,
                          $(14),
                          align: TextAlign.left,
                          maxLines: 3,
                        ),
                      ),
                    ]),
                    PrintOrderInfoItem(
                      name: S.of(context).order_ID,
                      value: "${rows.shopifyOrderId}",
                    ),
                    PrintOrderInfoItem(
                      name: S.of(context).variations,
                      value: "${controller.order.lineItems.first.variantTitle}",
                    ),
                    PrintOrderInfoItem(
                      name: S.of(context).number,
                      value: "${controller.order.lineItems.first.quantity}",
                    ),
                    PrintOrderInfoItem(
                      name: S.of(context).Subtotal,
                      value: "${rows.totalPrice}",
                    ),
                    PrintOrderInfoItem(
                      name: S.of(context).order_time,
                      value: "${DateUtil.formatDate(rows.created.timezoneCur, format: 'yyyy-MM-dd HH:mm')}",
                    ),
                  ]),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: $(8),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12)),
                  color: Color(0xFF1B1C1D),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    TitleTextWidget(
                      S.of(context).shipping_information,
                      ColorConstant.White,
                      FontWeight.w500,
                      $(17),
                      align: TextAlign.left,
                    ),
                    SizedBox(height: $(16)),
                    DividerLine(
                      left: 0,
                    ),
                    PrintShippingInfoItem(
                      image: Images.ic_order_name,
                      value: controller.order.customer.defaultAddress.firstName + " " + controller.order.customer.defaultAddress.lastName,
                    ),
                    if (controller.order.contactEmail != null)
                      PrintShippingInfoItem(
                        image: Images.ic_order_email,
                        value: controller.order.contactEmail ?? '',
                      ),
                    PrintShippingInfoItem(
                      image: Images.ic_order_phone,
                      value: controller.order.customer.defaultAddress.phone,
                    ),
                    PrintShippingInfoItem(
                      image: Images.ic_order_address,
                      value: controller.order.customer.defaultAddress.address1 + " " + controller.order.customer.defaultAddress.address2,
                    ),
                  ]),
                ),
              )
            ]);
          }),
    );
  }

  @override
  void dispose() {
    Get.delete<PrintOrderDetailController>();
    super.dispose();
  }
}
