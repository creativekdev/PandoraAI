import 'dart:io';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/views/payment/PurchaseScreen.dart';
import 'package:cartoonizer/views/payment/StripeSubscriptionScreen.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class PaymentUtils {
  static Future pay(BuildContext context, String source) async {
    AppDelegate.instance.getManager<CacheManager>().setString(CacheManager.prePaymentAction, source);
    Posthog().screenWithUser(screenName: 'pay_pro_screen');
    Events.payShow(source: source);
    if (Platform.isIOS) {
      return Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: "/PurchaseScreen"),
          builder: (context) => PurchaseScreen(),
        ),
      );
    } else {
      return Navigator.push(
        context,
        MaterialPageRoute(
          settings: RouteSettings(name: "/StripeSubscriptionScreen"),
          builder: (context) => StripeSubscriptionScreen(),
        ),
      );
    }
  }
}
