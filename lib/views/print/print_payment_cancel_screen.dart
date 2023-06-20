import 'dart:convert';

import 'package:cartoonizer/views/print/print_payment_screen.dart';
import 'package:cartoonizer/views/print/print_payment_success_screen.dart';
import 'package:cartoonizer/views/print/widgets/print_options_item.dart';
import 'package:cartoonizer/views/print/widgets/print_shipping_info_item.dart';

import '../../Common/importFile.dart';
import '../../Widgets/app_navigation_bar.dart';
import '../../Widgets/router/routers.dart';
import '../../images-res.dart';
import '../../models/print_order_entity.dart';
import '../../models/print_orders_entity.dart';

class PrintPaymentCancelScreen extends StatefulWidget {
  const PrintPaymentCancelScreen({Key? key, required this.sessionId, required this.payUrl, required this.orderEntity}) : super(key: key);

  final String sessionId;
  final String payUrl;
  final PrintOrderEntity orderEntity;

  @override
  State<PrintPaymentCancelScreen> createState() => _PrintPaymentCancelScreenState();
}

class _PrintPaymentCancelScreenState extends State<PrintPaymentCancelScreen> {
  late PrintOrdersDataRowsPayloadOrder order;

  @override
  void initState() {
    super.initState();
    order = PrintOrdersDataRowsPayloadOrder.fromJson(jsonDecode(widget.orderEntity.data.payload)["order"]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
        backAction: () {
          Navigator.popUntil(context, ModalRoute.withName('/HomeScreen'));
        },
      ),
      backgroundColor: ColorConstant.BackgroundColor,
      body: ListView(children: [
        Image.asset(
          Images.ic_print_payment_failure,
          width: $(48),
          height: $(48),
        ).intoContainer(
          padding: EdgeInsets.only(top: $(24)),
        ),
        TitleTextWidget(
          S.of(context).payment_failed,
          Color(0xFFFD4245),
          FontWeight.w500,
          $(17),
        ).intoContainer(padding: EdgeInsets.only(top: $(12))),
        TitleTextWidget(
          S.of(context).try_again,
          ColorConstant.White,
          FontWeight.w400,
          $(14),
        )
            .intoContainer(
          alignment: Alignment.center,
          margin: EdgeInsets.only(top: $(24), left: $(104), right: $(104)),
          height: $(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular($(16)),
            border: Border.all(
              color: ColorConstant.White,
              width: $(1),
            ),
          ),
        )
            .intoGestureDetector(onTap: () {
          Navigator.of(context)
              .push<bool>(Right2LeftRouter(
                  child: PrintPaymentScreen(
            payUrl: widget.payUrl,
            sessionId: widget.sessionId,
            orderEntity: widget.orderEntity,
          )))
              .then((value) {
            if (value == true) {
              Navigator.of(context).push<void>(Right2LeftRouter(
                  child: PrintPaymentSuccessScreen(
                payUrl: widget.payUrl,
                sessionId: widget.sessionId,
                orderEntity: widget.orderEntity,
              )));
            } else {
              Navigator.of(context).push<void>(Right2LeftRouter(
                  child: PrintPaymentCancelScreen(
                payUrl: widget.payUrl,
                sessionId: widget.sessionId,
                orderEntity: widget.orderEntity,
              )));
            }
          });
        }),
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
                value: order.contactEmail,
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
