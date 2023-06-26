import 'dart:convert';

import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/main.dart';
import 'package:cartoonizer/views/print/print_payment_screen.dart';
import 'package:cartoonizer/views/print/print_payment_success_screen.dart';
import 'package:cartoonizer/views/print/widgets/print_options_item.dart';
import 'package:cartoonizer/views/print/widgets/print_shipping_info_item.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../../Common/importFile.dart';
import '../../Widgets/app_navigation_bar.dart';
import '../../Widgets/router/routers.dart';
import '../../app/app.dart';
import '../../images-res.dart';
import '../../models/print_orders_entity.dart';

class PrintPaymentCancelScreen extends StatefulWidget {
  String source;
  final String sessionId;
  final String payUrl;
  final PrintOrdersDataRows orderEntity;

  PrintPaymentCancelScreen({
    Key? key,
    required this.sessionId,
    required this.payUrl,
    required this.orderEntity,
    required this.source,
  }) : super(key: key);

  @override
  State<PrintPaymentCancelScreen> createState() => _PrintPaymentCancelScreenState();
}

class _PrintPaymentCancelScreenState extends State<PrintPaymentCancelScreen> {
  late PrintOrdersDataRowsPayloadOrder order;
  late PrintOrdersDataRowsPayloadRepay repay;
  UserManager userManager = AppDelegate.instance.getManager();

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'print_payment_cancel_screen');
    order = PrintOrdersDataRowsPayloadOrder.fromJson(jsonDecode(widget.orderEntity.payload)["order"]);
    repay = PrintOrdersDataRowsPayloadRepay.fromJson(jsonDecode(widget.orderEntity.payload)["repay"]);
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
                  settings: RouteSettings(name: '/PrintPaymentScreen'),
                  child: PrintPaymentScreen(
                    payUrl: widget.payUrl,
                    sessionId: widget.sessionId,
                    orderEntity: widget.orderEntity,
                    source: widget.source,
                  )))
              .then((value) {
            if (value == true) {
              Navigator.of(context).push<void>(Right2LeftRouter(
                  settings: RouteSettings(name: '/PrintPaymentSuccessScreen'),
                  child: PrintPaymentSuccessScreen(
                    payUrl: widget.payUrl,
                    sessionId: widget.sessionId,
                    orderEntity: widget.orderEntity,
                    source: widget.source,
                  )));
            } else {
              if (MyApp.routeObserver.lastRoute?.settings.name == "/PrintPaymentCancelScreen") {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).push<void>(Right2LeftRouter(
                    settings: RouteSettings(name: '/PrintPaymentCancelScreen'),
                    child: PrintPaymentCancelScreen(
                      payUrl: widget.payUrl,
                      sessionId: widget.sessionId,
                      orderEntity: widget.orderEntity,
                      source: widget.source,
                    )));
              }
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
              value: repay.customer.firstName + " " + repay.customer.lastName,
              color: ColorConstant.White,
            ),
            if (userManager.user?.getShownEmail() != null)
              PrintShippingInfoItem(
                image: Images.ic_order_email,
                value: userManager.user!.getShownEmail(),
                color: ColorConstant.White,
              ),
            PrintShippingInfoItem(
              image: Images.ic_order_phone,
              value: repay.customer.phone,
              color: ColorConstant.White,
            ),
            PrintShippingInfoItem(
              image: Images.ic_order_address,
              value: repay.customer.addresses.first.address2 + " " + repay.customer.addresses.first.address1,
              color: ColorConstant.White,
            ),
          ]),
        )
      ]),
    );
  }
}
