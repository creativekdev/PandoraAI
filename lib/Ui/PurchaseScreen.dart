import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import 'package:cartoonizer/Common/ConsumableStore.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/Model/UserModel.dart';
import 'package:cartoonizer/api.dart';
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
  bool _showPurchasePlan = false;
  late UserModel _user;
  String? _queryProductError;

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      print("error");
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

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify a purchase before delivering the product.
    // For the purpose of an example, we directly return true.

    Map<String, dynamic> body = {
      "receipt_data": purchaseDetails.verificationData.serverVerificationData,
      "purchase_id": purchaseDetails.purchaseID,
      "product_id": purchaseDetails.productID
    };

    var sharedPreferences = await SharedPreferences.getInstance();
    final headers = {"cookie": "sb.connect.sid=${sharedPreferences.getString("login_cookie")}"};

    var response = await post(Uri.parse('${Config.instance.apiHost}/plan/apple_store/buy'), body: body, headers: headers);
    if (response.statusCode == 200) {
      return Future<bool>.value(true);
    } else {
      return Future<bool>.value(false);
    }
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if  _verifyPurchase` failed, just finish it to void can not buy again

    if (purchaseDetails.pendingCompletePurchase) {
      _inAppPurchase.completePurchase(purchaseDetails);
    }
  }

  void deliverProduct(PurchaseDetails purchaseDetails) async {
    // IMPORTANT!! Always verify purchase details before delivering the product.
    if (purchaseDetails.productID == _kConsumableId || purchaseDetails.productID == _kUpgradeId) {
      await ConsumableStore.save(purchaseDetails.purchaseID ?? "");
      final List<String> consumables = await ConsumableStore.load();
      setState(() {
        _purchasePending = false;
        _consumables = consumables;
      });
    } else {
      setState(() {
        _purchases.add(purchaseDetails);
        _purchasePending = false;
      });
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    purchaseDetailsList.forEach((PurchaseDetails purchaseDetails) async {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        setState(() {
          _loading = true;
        });
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          setState(() {
            _loading = false;
          });
        } else if (purchaseDetails.status == PurchaseStatus.purchased || purchaseDetails.status == PurchaseStatus.restored) {
          log("_listenToPurchaseUpdated ${purchaseDetails.purchaseID ?? ""}");
          bool valid = await _verifyPurchase(purchaseDetails);
          if (valid) {
            // reload user by get login
            UserModel user = await API.getLogin(needLoad: true);
            if (user.subscription.containsKey('id')) {
              setState(() {
                _showPurchasePlan = true;
                _user = user;
              });
            }
            deliverProduct(purchaseDetails);
            setState(() {
              _loading = false;
            });
          } else {
            _handleInvalidPurchase(purchaseDetails);
            setState(() {
              _loading = false;
            });
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

    // get all transactions and finish them if testing needed
    var transactions = await SKPaymentQueueWrapper().transactions();
    transactions.forEach((transaction) {
      SKPaymentQueueWrapper().finishTransaction(transaction);
    });

    UserModel user = await API.getLogin(needLoad: true);
    if (user.subscription.containsKey('id')) {
      setState(() {
        _showPurchasePlan = true;
        _user = user;
      });
    }

    ProductDetailsResponse productDetailResponse = await _inAppPurchase.queryProductDetails(_kProductIds.toSet());
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
    setState(() {
      _isAvailable = isAvailable;
      _products = productDetailResponse.productDetails;
      _notFoundIds = productDetailResponse.notFoundIDs;
      _consumables = consumables;
      _purchasePending = false;
      _loading = false;
    });
  }

  Widget _buildPurchaseButton(year, month) {
    if (_showPurchasePlan) {
      return Container();
    }

    return GestureDetector(
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
          late PurchaseParam purchaseParam;
          if (Platform.isAndroid) {
            purchaseParam = GooglePlayPurchaseParam(productDetails: isYear ? year : month);
          } else {
            purchaseParam = PurchaseParam(productDetails: isYear ? year : month);
          }

          try {
            _inAppPurchase.buyConsumable(purchaseParam: purchaseParam, autoConsume: _kAutoConsume || Platform.isIOS);
          } catch (error) {
            print("123" + error.toString());
          }
        }
      },
      child: _showPurchasePlan ? null : ButtonWidget(StringConstant.txtContinue),
    );
  }

  Column _buildProductList() {
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

    var currentPlan;
    if (_showPurchasePlan) {
      bool isMonthlyPlan = _user.subscription['plan_type'] == 'monthly';
      currentPlan = isMonthlyPlan ? month : year;

      return Column(children: [
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(235, 232, 255, 1),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  children: [
                    Image.asset(
                      ImagesConstant.ic_radio_on,
                      height: 8.w,
                      width: 8.w,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitleTextWidget("${currentPlan.title} : ${currentPlan.price}/${isMonthlyPlan ? "Month" : "Year"}", ColorConstant.TextBlack, FontWeight.w500, 12.sp,
                              align: TextAlign.start),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ))
      ]);
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
                              TitleTextWidget("${year.title} : ${year.price}/Year", ColorConstant.TextBlack, FontWeight.w500, 12.sp, align: TextAlign.start),
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
                              TitleTextWidget("${month.title} : ${month.price}/Month", ColorConstant.TextBlack, FontWeight.w500, 12.sp, align: TextAlign.start),
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
            _buildPurchaseButton(year, month),
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
                            _buildProductList(),
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
