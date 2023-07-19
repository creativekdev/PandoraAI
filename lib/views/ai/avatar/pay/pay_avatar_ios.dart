import 'dart:developer';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

class PayAvatarIOS {
  String planId;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  UserManager userManager = AppDelegate().getManager();
  late AppApi api = AppApi();

  PayAvatarIOS({required this.planId});

  startPay(BuildContext context, Function(bool result) callback) async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      CommonExtension().showToast(S.of(context).commonFailedToast);
      return false;
    }
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      if (purchaseDetailsList.isNotEmpty) {
        _listenToPurchaseUpdated(purchaseDetailsList.first, callback);
      }
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      print("error");
    }, cancelOnError: true);

    var iosPlatformAddition = _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
    await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());

    // get all transactions and finish them if testing needed
    var transactions = await SKPaymentQueueWrapper().transactions();
    transactions.forEach((transaction) {
      SKPaymentQueueWrapper().finishTransaction(transaction);
    });

    ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails([planId].toSet());

    if (productDetailResponse.productDetails.isNotEmpty) {
      var purchase = PurchaseParam(productDetails: productDetailResponse.productDetails.first);
      _inAppPurchase.buyNonConsumable(purchaseParam: purchase);
    } else {
      CommonExtension().showToast(S.of(context).commonFailedToast);
    }
  }

  void _listenToPurchaseUpdated(PurchaseDetails purchaseDetails, Function(bool result) callback) async {
    if (purchaseDetails.status == PurchaseStatus.pending) {
    } else if (purchaseDetails.status == PurchaseStatus.canceled || purchaseDetails.status == PurchaseStatus.error) {
      callback.call(false);
    } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
      log("_listenToPurchaseUpdated ${purchaseDetails.purchaseID ?? ""}");
      bool valid = await _verifyPurchase(purchaseDetails);

      if (valid) {
        // reload user by get login
        await userManager.refreshUser();
      }
      callback.call(valid);
    }
    if (purchaseDetails.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.

    var body = {"receipt_data": purchaseDetails.verificationData.serverVerificationData, "purchase_id": purchaseDetails.purchaseID ?? "", "product_id": purchaseDetails.productID};
    // var build = DioNode.instance.build();
    // var response = await build.post('https://576e-156-251-179-119.ngrok.io/api/plan/apple_store/buy', data: body);
    var value = await api.buyApple(body);

    if (value != null) {
      return Future<bool>.value(true);
    } else {
      return Future<bool>.value(false);
    }
  }

  dispose() {
    _subscription.cancel();
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
