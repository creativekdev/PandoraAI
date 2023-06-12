import 'package:cartoonizer/views/print/widgets/print_options_item.dart';
import 'package:cartoonizer/views/print/widgets/print_order_info_item.dart';
import 'package:cartoonizer/views/print/widgets/print_shipping_info_item.dart';

import '../../Common/importFile.dart';
import '../../images-res.dart';

class PrintOrderDetailScreen extends StatefulWidget {
  const PrintOrderDetailScreen({Key? key}) : super(key: key);

  @override
  State<PrintOrderDetailScreen> createState() => _PrintOrderDetailScreenState();
}

class _PrintOrderDetailScreenState extends State<PrintOrderDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          "Order Details".tr,
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
      body: CustomScrollView(slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12)),
            color: Color(0xFF1B1C1D),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              TitleTextWidget(
                "Order ID: 1234567",
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
                Image.asset(
                  Images.ic_ai_draw_camera,
                  width: $(80),
                  height: $(80),
                ).intoContainer(
                    decoration: BoxDecoration(
                  color: Color(0xFFFB8888),
                  borderRadius: BorderRadius.circular(8),
                )),
                SizedBox(width: $(16)),
                TitleTextWidget(
                  "Order ID: 1234567",
                  ColorConstant.White,
                  FontWeight.w500,
                  $(14),
                  align: TextAlign.left,
                  maxLines: 3,
                ),
              ]),
              PrintOrderInfoItem(),
              PrintOrderInfoItem(),
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
                "Shopping Information".tr,
                ColorConstant.White,
                FontWeight.w500,
                $(17),
                align: TextAlign.left,
              ),
              SizedBox(height: $(16)),
              DividerLine(
                left: 0,
              ),
              PrintShippingInfoItem()
            ]),
          ),
        )
      ]),
    );
  }
}
