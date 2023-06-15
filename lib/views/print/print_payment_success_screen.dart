import 'dart:convert';

import 'package:cartoonizer/views/print/print_order_screen.dart';
import 'package:cartoonizer/views/print/widgets/print_options_item.dart';
import 'package:cartoonizer/views/print/widgets/print_shipping_info_item.dart';

import '../../Common/importFile.dart';
import '../../images-res.dart';
import '../../models/print_order_entity.dart';
import '../../models/print_orders_entity.dart';

class PrintPaymentSuccessScreen extends StatefulWidget {
  const PrintPaymentSuccessScreen({Key? key, required this.sessionId, required this.payUrl, required this.orderEntity}) : super(key: key);

  final String sessionId;
  final String payUrl;
  final PrintOrderEntity orderEntity;

  @override
  State<PrintPaymentSuccessScreen> createState() => _PrintPaymentSuccessScreenState();
}

class _PrintPaymentSuccessScreenState extends State<PrintPaymentSuccessScreen> {
  late PrintOrdersDataRowsPayloadOrder order;

  @override
  void initState() {
    super.initState();
    order = PrintOrdersDataRowsPayloadOrder.fromJson(jsonDecode(widget.orderEntity.data.payload)["order"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: Image.asset(
          Images.ic_back,
          width: $(24),
        )
            .intoContainer(
          margin: EdgeInsets.all($(14)),
        )
            .intoGestureDetector(onTap: () {
          // EventBusHelper().eventBus.fire(OnTabSwitchEvent(data: [AppTabId.DISCOVERY.id(), 1]));
          Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
        }),
      ),
      backgroundColor: ColorConstant.BackgroundColor,
      body: ListView(children: [
        Image.asset(
          Images.ic_print_payment_success,
          width: $(48),
          height: $(48),
        ).intoContainer(
          padding: EdgeInsets.only(top: $(24)),
        ),
        TitleTextWidget(
          S.of(context).payment_successfully,
          Color(0xFF34C759),
          FontWeight.w500,
          $(17),
        ).intoContainer(padding: EdgeInsets.only(top: $(12))),
        Container(
          margin: EdgeInsets.only(top: $(24), left: $(68), right: $(68)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            TitleTextWidget(
              S.of(context).back_home,
              ColorConstant.White,
              FontWeight.w400,
              $(14),
            )
                .intoContainer(
              alignment: Alignment.center,
              height: $(32),
              width: $(112),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular($(16)),
                border: Border.all(
                  color: ColorConstant.White,
                  width: $(1),
                ),
              ),
            )
                .intoGestureDetector(onTap: () {
              Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
            }),
            TitleTextWidget(
              S.of(context).view_orders,
              ColorConstant.White,
              FontWeight.w400,
              $(14),
            )
                .intoContainer(
              alignment: Alignment.center,
              height: $(32),
              width: $(112),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular($(16)),
                border: Border.all(
                  color: ColorConstant.White,
                  width: $(1),
                ),
              ),
            )
                .intoGestureDetector(onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(name: "/PrintOrderScreen"),
                    builder: (context) => PrintOrderScreen(),
                  ));
            }),
          ]),
        ),
        DividerLine(
          left: $(16),
          right: $(16),
        ).intoContainer(
            padding: EdgeInsets.only(
          top: $(40),
        )),
        TitleTextWidget(
          S.of(context).order_ID + order.id.toString(),
          ColorConstant.White,
          FontWeight.w500,
          $(17),
          align: TextAlign.left,
        ).intoContainer(
            padding: EdgeInsets.only(
          left: $(15),
          top: $(24),
        )),
        Container(
          padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12)),
          margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(12)),
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
              value: order.customer.defaultAddress.firstName + " " + order.customer.defaultAddress.lastName,
              color: ColorConstant.White,
            ),
            if (order.contactEmail != null)
              PrintShippingInfoItem(
                image: Images.ic_order_email,
                value: order.contactEmail ?? '',
                color: ColorConstant.White,
              ),
            PrintShippingInfoItem(
              image: Images.ic_order_phone,
              value: order.customer.defaultAddress.phone,
              color: ColorConstant.White,
            ),
            PrintShippingInfoItem(
              image: Images.ic_order_address,
              value: order.customer.defaultAddress.address1 + " " + order.customer.defaultAddress.address2,
              color: ColorConstant.White,
            ),
          ]),
        )
      ]),
    );
  }
}
