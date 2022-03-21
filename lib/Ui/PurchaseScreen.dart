import 'package:cartoonizer/Common/importFile.dart';

import 'dart:async';
import 'dart:io';
import 'package:cartoonizer/Utils/ConsumableStore.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import 'LoginScreen.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({Key? key}) : super(key: key);

  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

const bool _kAutoConsume = true;
const String _kConsumableId = 'io.socialbook.cartoonizer.monthly';
const String _kUpgradeId = 'io.socialbook.cartoonizer.yearly';
// const String _kConsumableId = 'android.test.purchased';
// const String _kUpgradeId = 'android.test.purchased';
const List<String> _kProductIds = <String>[
  _kConsumableId,
  _kUpgradeId,
];

class _PurchaseScreenState extends State<PurchaseScreen> {
  bool isYear = true;

  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<String> _notFoundIds = [];
  List<ProductDetails> _products = [];
  List<PurchaseDetails> _purchases = [];
  List<String> _consumables = [];
  bool _isAvailable = false;
  bool _purchasePending = false;
  bool _loading = true;
  String? _queryProductError;

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      // print("done");
      _subscription.cancel();
    }, onError: (error) {
      print("error");
      // setState(() {
      //   _loading = false;
      // });
    }, cancelOnError: true);
    initStoreInfo();
    super.initState();
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void handleError(IAPError error) {
    setState(() {
      _purchasePending = false;
    });
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.
    return Future<bool>.value(true);
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed.
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    // print("///////////////done");
    // print(purchaseDetails.verificationData.source);
    // print(purchaseDetails.verificationData.localVerificationData);
    // print(purchaseDetails.transactionDate);

    await ConsumableStore.save(purchaseDetails.purchaseID!);
    List<String> consumables = await ConsumableStore.load();
    setState(() {
      _purchasePending = false;
      _consumables = consumables;
    });
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() {
          _loading = true;
        });
        // showPendingUI();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          // handleError(purchaseDetails.error!);
          setState(() {
            _loading = false;
          });
        } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
          setState(() {
            _loading = false;
          });
          print(purchaseDetails);
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            deliverProduct(purchaseDetails);
          } else {
            _handleInvalidPurchase(purchaseDetails);
            return;
          }
        }
        if (Platform.isAndroid) {
          if (!_kAutoConsume) {
            final InAppPurchaseAndroidPlatformAddition androidAddition = _inAppPurchase.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
            await androidAddition.consumePurchase(purchaseDetails);
          }
        }
        if (purchaseDetails.pendingCompletePurchase) {
          setState(() {
            _loading = false;
          });
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    });
  }

  Future<void> initStoreInfo() async {
    final bool isAvailable = await _inAppPurchase.isAvailable();
    if (!isAvailable) {
      setState(() {
        _isAvailable = isAvailable;
        _products = [];
        _purchases = [];
        _notFoundIds = [];
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (Platform.isIOS) {
      var iosPlatformAddition = _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      await iosPlatformAddition.setDelegate(ExamplePaymentQueueDelegate());
    }

    ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
    print("productDetailResponse.error");
    print(productDetailResponse.productDetails);

    if (productDetailResponse.error != null) {
      setState(() {
        _queryProductError = productDetailResponse.error!.message;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    if (productDetailResponse.productDetails.isEmpty) {
      setState(() {
        _queryProductError = null;
        _isAvailable = isAvailable;
        _products = productDetailResponse.productDetails;
        _purchases = [];
        _notFoundIds = productDetailResponse.notFoundIDs;
        _consumables = [];
        _purchasePending = false;
        _loading = false;
      });
      return;
    }

    List<String> consumables = await ConsumableStore.load();
    print("productDetailResponse.productDetails[0].title");
    print(productDetailResponse.productDetails[0].price);
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  Column _getColumnData() {
    if (!_isAvailable) {
      return Column();
    }

    for (int i = 0; i < _purchases.length; i++) {
      if (_purchases[i].pendingCompletePurchase) {
        _inAppPurchase.completePurchase(_purchases[i]);
      }
    }

    var year, month;
    for (int i = 0; i < _products.length; i++) {
      if (_products[i].id == _kConsumableId) {
        month = _products[i];
      } else if (_products[i].id == _kUpgradeId) {
        year = _products[i];
      }
    }

    return Column(
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: GestureDetector(
                onTap: () => {
                  setState(() {
                    isYear = !isYear;
                  })
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isYear ? Color.fromRGBO(235, 232, 255, 1) : ColorConstant.White,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: Row(
                      children: [
                        Image.asset(
                          isYear ? ImagesConstant.ic_radio_on : ImagesConstant.ic_radio_off,
                          height: 8.w,
                          width: 8.w,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitleTextWidget("${year.title} : ${year.price}/Year", ColorConstant.TextBlack, FontWeight.w500, 12.sp,
                                  align: TextAlign.start),
                              // TitleTextWidget("Just ${(year.rawPrice) / 12}/Month", ColorConstant.PrimaryColor, FontWeight.w400, 10.sp),
                            ],
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Visibility(
                          visible: false,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TitleTextWidget("50%", ColorConstant.PrimaryColor, FontWeight.w600, 12.sp),
                              TitleTextWidget("OFF", ColorConstant.PrimaryColor, FontWeight.w500, 10.sp),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 2.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 5.w),
              child: GestureDetector(
                onTap: () => {
                  setState(() {
                    isYear = !isYear;
                  })
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: !isYear ? Color.fromRGBO(235, 232, 255, 1) : ColorConstant.White,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: Row(
                      children: [
                        Image.asset(
                          !isYear ? ImagesConstant.ic_radio_on : ImagesConstant.ic_radio_off,
                          height: 8.w,
                          width: 8.w,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitleTextWidget("${month.title} : ${month.price}/Month", ColorConstant.TextBlack, FontWeight.w500, 12.sp,
                                  align: TextAlign.start),
                            ],
                          ),
                        ),
                        Expanded(child: SizedBox()),
                        Visibility(
                          visible: false,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TitleTextWidget("50%", ColorConstant.PrimaryColor, FontWeight.w600, 12.sp),
                              TitleTextWidget("OFF", ColorConstant.PrimaryColor, FontWeight.w500, 10.sp),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 4.h,
            ),
            GestureDetector(
              onTap: () async {
                var sharedPrefs = await SharedPreferences.getInstance();
                if (!(sharedPrefs.getBool("isLogin") ?? false)) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings: RouteSettings(name: "/LoginScreen"),
                      builder: (context) => LoginScreen(),
                    ),
                  ).then((value) => Navigator.pop(context, value));
                } else {
                  // setState(() {
                  //   _loading = true;
                  // });
                  late PurchaseParam purchaseParam;
                  if (Platform.isAndroid) {
                    purchaseParam = GooglePlayPurchaseParam(
                      productDetails: isYear ? year : month,
                      applicationUserName: null,
                    );
                  } else {
                    purchaseParam = PurchaseParam(
                      productDetails: isYear ? year : month,
                      applicationUserName: null,
                    );
                  }
                  try {
                    _inAppPurchase.buyConsumable(purchaseParam: purchaseParam, autoConsume: _kAutoConsume || Platform.isIOS);
                  } catch (error) {
                    print("123" + error.toString());
                  }
                }
              },
              child: ButtonWidget(StringConstant.txtContinue),
            ),
          ],
        )
      ],
    );
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      var iosPlatformAddition = _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
      iosPlatformAddition.setDelegate(null);
    }
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: Stack(
        children: [
          Image.asset(
            ImagesConstant.ic_bg_premium,
            width: 100.w,
            height: 50.h,
            fit: BoxFit.fill,
          ),
          SafeArea(
            child: LoadingOverlay(
                isLoading: _loading,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => {Navigator.pop(context)},
                            child: Image.asset(
                              ImagesConstant.ic_close,
                              height: 10.w,
                              width: 10.w,
                            ),
                          ),
                          Expanded(
                            child: SizedBox(),
                          ),
                          if (_isAvailable)
                            GestureDetector(
                              onTap: () async {
                                var sharedPrefs = await SharedPreferences.getInstance();
                                if (!(sharedPrefs.getBool("isLogin") ?? false)) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      settings: RouteSettings(name: "/LoginScreen"),
                                      builder: (context) => LoginScreen(),
                                    ),
                                  ).then((value) => Navigator.pop(context, value));
                                } else {
                                  // setState(() {
                                  //   _loading = true;
                                  // });
                                  _inAppPurchase.restorePurchases();
                                }
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Color.fromRGBO(255, 255, 255, 0.8),
                                  borderRadius: BorderRadius.circular(1.w),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
                                  child: TitleTextWidget(StringConstant.restore, ColorConstant.BtnTextColor, FontWeight.w500, 11.sp),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: 3.h,
                            ),
                            Image.asset(
                              ImagesConstant.ic_purchase_emoji,
                              width: 50.w,
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                              child: Card(
                                shadowColor: Color.fromRGBO(0, 0, 0, 0.4),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(3.w),
                                ),
                                elevation: 2.h,
                                child: Padding(
                                  padding: EdgeInsets.all(5.w),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Image.asset(
                                            ImagesConstant.ic_no_watermark,
                                            height: 8.w,
                                            width: 8.w,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                                            child: TitleTextWidget(StringConstant.no_watermark1, ColorConstant.TextBlack, FontWeight.w400, 12.sp),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            ImagesConstant.ic_hd,
                                            height: 8.w,
                                            width: 8.w,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                                            child: TitleTextWidget(StringConstant.high_resolution, ColorConstant.TextBlack, FontWeight.w400, 12.sp),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            ImagesConstant.ic_rocket,
                                            height: 8.w,
                                            width: 8.w,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                                            child: TitleTextWidget(StringConstant.faster_speed, ColorConstant.TextBlack, FontWeight.w400, 12.sp),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 2.h,
                            ),
                            _getColumnData(),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
          ),
        ],
      ),
    );
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
