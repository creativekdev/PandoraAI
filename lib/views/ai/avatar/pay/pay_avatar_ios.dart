import 'dart:developer';
import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/ConsumableStore.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:http/http.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class PayAvatarIOS extends StatefulWidget {
  String planId;

  PayAvatarIOS({Key? key, required this.planId}) : super(key: key);

  @override
  State<PayAvatarIOS> createState() => _PayAvatarIOSState();
}

class _PayAvatarIOSState extends State<PayAvatarIOS> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late String planId;

  @override
  void initState() {
    super.initState();
    planId = widget.planId;
    init();
  }

  init() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    var iosPlatformAddition = _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
    await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());

    // get all transactions and finish them if testing needed
    var transactions = await SKPaymentQueueWrapper().transactions();
    transactions.forEach((transaction) {
      SKPaymentQueueWrapper().finishTransaction(transaction);
    });

    ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails([planId].toSet());
    print(productDetailResponse.productDetails);

  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class ExamplePaymentQueueDelegate implements SKPaymentQueueDelegateWrapper {
  @override
  bool shouldContinueTransaction(SKPaymentTransactionWrapper transaction, SKStorefrontWrapper storefront) {
    return true;
  }

  @override
  bool shouldShowPriceConsent() {
    return false;
  }
}
