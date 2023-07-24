import 'dart:developer';
import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/ConsumableStore.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import 'account/LoginScreen.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({Key? key}) : super(key: key);

  @override
  _PurchaseScreenState createState() => _PurchaseScreenState();
}

const bool _kAutoConsume = true;
const String _kConsumableId = 'io.socialbook.cartoonizer.monthly';
const String _kUpgradeId = 'io.socialbook.cartoonizer.yearly';
const List<String> _kProductIds = <String>[
  _kConsumableId,
  _kUpgradeId,
];

class _PurchaseScreenState extends State<PurchaseScreen> {
  bool isYear = false;

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
  String? _queryProductError;
  UserManager userManager = AppDelegate().getManager();
  bool purchaseSuccess = false;

  @override
  void initState() {
    loadPurchase();
    super.initState();
  }

  void loadPurchase() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
    }, onDone: () {
      _subscription.cancel();
    }, onError: (error) {
      print("error");
    }, cancelOnError: true);
    initStoreInfo();
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

    var body = {"receipt_data": purchaseDetails.verificationData.serverVerificationData, "purchase_id": purchaseDetails.purchaseID ?? "", "product_id": purchaseDetails.productID};
    var response = await API.post("/api/plan/apple_store/buy", body: body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      purchaseSuccess = true;
      return Future<bool>.value(true);
    } else {
      purchaseSuccess = false;
      return Future<bool>.value(false);
    }
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    // handle invalid purchase here if _verifyPurchase failed, just finish it to void can not buy again

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
          bool valid = false;
          if (!isVip()) {
            valid = await _verifyPurchase(purchaseDetails);
          }

          if (valid) {
            // reload user by get login
            await userManager.refreshUser();
            var user = userManager.user!;
            if (user.userSubscription.containsKey('id')) {
              setState(() {
                _showPurchasePlan = true;
              });
            } else {
              _handleInvalidPurchase(purchaseDetails);
              setState(() {
                _loading = false;
              });
            }
            deliverProduct(purchaseDetails);
            setState(() {
              _loading = false;
            });
          } else {
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

      // get all transactions and finish them if testing needed
      var transactions = await SKPaymentQueueWrapper().transactions();
      transactions.forEach((transaction) {
        SKPaymentQueueWrapper().finishTransaction(transaction);
      });
    }

    await userManager.refreshUser();
    var user = userManager.user!;
    if (user.userSubscription.containsKey('id')) {
      setState(() {
        _showPurchasePlan = true;
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

  Widget _buildPurchaseButton() {
    if (_showPurchasePlan) {
      return Container();
    }

    var year, month;
    for (int i = 0; i < _products.length; i++) {
      if (_products[i].id == _kConsumableId) {
        month = _products[i];
      } else if (_products[i].id == _kUpgradeId) {
        year = _products[i];
      }
    }

    return GestureDetector(
      onTap: () async {
        if (userManager.isNeedLogin) {
          CommonExtension().showToast(S.of(context).please_login_first);
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
      child: _showPurchasePlan
          ? null
          : RichText(
              text: TextSpan(text: S.of(context).selected, style: TextStyle(color: ColorConstant.White, fontFamily: 'Poppins', fontSize: $(17)), children: [
              TextSpan(
                text: '${(isYear ? year : month)?.price ?? ''}',
                style: TextStyle(color: ColorConstant.White, fontFamily: 'Poppins', fontSize: $(23)),
              )
            ])).intoContainer(
              width: double.maxFinite,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: $(24)),
              padding: EdgeInsets.symmetric(vertical: $(10)),
              decoration: BoxDecoration(
                color: ColorConstant.DiscoveryBtn,
                borderRadius: BorderRadius.circular($(8)),
              )),
    );
  }

  Widget _buildProductList() {
    if (!_isAvailable) {
      return Container();
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

    if (month == null && year == null) {
      return TitleTextWidget("Load Data Failed\n Click to reload", ColorConstant.White, FontWeight.normal, $(16), maxLines: 2)
          .intoContainer(
              width: double.maxFinite,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular($(8)),
                color: ColorConstant.CardColor,
              ),
              margin: EdgeInsets.symmetric(horizontal: 11.w),
              padding: EdgeInsets.symmetric(vertical: $(25)))
          .intoGestureDetector(onTap: () {
        Navigator.of(context).pop();
        if (Platform.isIOS) {
          Get.to(PurchaseScreen());
        }
      });
    }
    var currentPlan;
    if (_showPurchasePlan) {
      var user = userManager.user!;
      bool isMonthlyPlan = user.userSubscription['plan_type'] == 'monthly';
      currentPlan = isMonthlyPlan ? month : year;

      return Column(children: [
        Padding(
            padding: EdgeInsets.symmetric(horizontal: $(24)),
            child: Container(
              decoration: BoxDecoration(
                color: Color(0x99ffffff),
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  children: [
                    Image.asset(
                      Images.ic_radio_on,
                      height: 26,
                      width: 26,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitleTextWidget("${currentPlan.title} : ${currentPlan.price}", ColorConstant.White, FontWeight.w500, 14, align: TextAlign.start),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ))
      ]);
    }

    return Row(
      children: [
        SizedBox(width: $(24)),
        Expanded(
            child: buyPlanItem(
          context,
          plan: month,
          checked: !isYear,
          popular: true,
        ).intoGestureDetector(onTap: () {
          if (!isYear) {
            return;
          }
          setState(() {
            isYear = false;
          });
        })),
        SizedBox(width: $(20)),
        Expanded(
            child: buyPlanItem(context, plan: year, checked: isYear).intoGestureDetector(onTap: () {
          if (isYear) {
            return;
          }
          setState(() {
            isYear = true;
          });
        })),
        SizedBox(width: $(24)),
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
    return WillPopScope(
        child: LoadingOverlay(
          isLoading: _loading,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                Row(
                  children: [
                    Image.asset(
                      Images.ic_back,
                      height: $(24),
                      width: $(24),
                    ).intoContainer(margin: EdgeInsets.symmetric(horizontal: $(15), vertical: $(10))).intoGestureDetector(onTap: () {
                      Navigator.of(context).pop();
                    }),
                    Expanded(
                      child: SizedBox(),
                    ),
                    if (_isAvailable)
                      GestureDetector(
                        onTap: () async {
                          if (userManager.isNeedLogin) {
                            return;
                          }
                          // setState(() {
                          //   _loading = true;
                          // });
                          _inAppPurchase.restorePurchases();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(255, 255, 255, 0.8),
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
                            child: TitleTextWidget(S.of(context).restore, ColorConstant.BtnTextColor, FontWeight.w500, 11.sp),
                          ),
                        ),
                      ),
                    SizedBox(width: $(24)),
                  ],
                ).intoContainer(margin: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight())),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Card(
                          color: Color(0xcc000000),
                          shadowColor: Color.fromRGBO(0, 0, 0, 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.w),
                          ),
                          margin: EdgeInsets.only(top: $(100), left: $(24), right: $(24)),
                          elevation: 2.h,
                          child: Column(
                            children: [
                              TitleTextWidget('Pandora AI Pro', Colors.white, FontWeight.w500, $(23)),
                              SizedBox(height: $(10)),
                              attrItem(context, title: S.of(context).no_ads, imageRes: Images.ic_no_ads),
                              SizedBox(height: $(10)),
                              attrItem(context, title: S.of(context).no_watermark1, imageRes: Images.ic_no_watermark),
                              SizedBox(height: $(10)),
                              attrItem(context, title: S.of(context).high_resolution, imageRes: Images.ic_hd),
                              SizedBox(height: $(10)),
                              attrItem(context, title: S.of(context).faster_speed, imageRes: Images.ic_rocket),
                              SizedBox(height: $(10)),
                              attrItem(context,
                                  title: S.of(context).buy_attr_metaverse.replaceAll("%d", '${userManager.limitRule.anotherme?.plan ?? 0}'), imageRes: Images.ic_buy_metaverse),
                              SizedBox(height: $(10)),
                              attrItem(context,
                                  title: S.of(context).buy_attr_ai_artist.replaceAll('%d', '${userManager.limitRule.txt2img?.plan ?? 0}'), imageRes: Images.ic_buy_ai_artist),
                            ],
                          ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(15))),
                        ),
                        SizedBox(height: 2.h),
                        _buildProductList(),
                      ],
                    ),
                  ),
                ),
                _buildPurchaseButton(),
                SizedBox(height: ScreenUtil.getBottomPadding(context) + $(15))
              ],
            ),
          ).intoContainer(
            decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Images.ic_buy_bg), fit: BoxFit.fill)),
          ),
        ),
        onWillPop: () async {
          if (purchaseSuccess) {
            EventBusHelper().eventBus.fire(OnPaySuccessEvent());
          }
          return true;
        });
  }

  Widget attrItem(BuildContext context, {required title, required String imageRes}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.asset(imageRes, height: 24, width: 24),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: TitleTextWidget(title, ColorConstant.White, FontWeight.w400, 14, maxLines: 2, align: TextAlign.start),
          ),
        ),
      ],
    );
  }

  Widget buyPlanItem(
    BuildContext context, {
    required plan,
    required bool checked,
    bool popular = false,
  }) {
    double width = (ScreenUtil.screenSize.width - $(68)) / 2;
    return Stack(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: $(24)),
            TitleTextWidget("${plan.title}", ColorConstant.White, FontWeight.w500, $(14), align: TextAlign.center),
            SizedBox(height: $(16)),
            TitleTextWidget("${plan.price}", ColorConstant.White, FontWeight.w500, $(26), align: TextAlign.center),
            SizedBox(height: $(16)),
            Text(
              S.of(context).most_popular,
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Poppins',
                fontSize: $(10),
              ),
            )
                .intoContainer(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: $(4)),
                    decoration: BoxDecoration(
                      color: Color(0xFFFED700),
                      borderRadius: BorderRadius.circular($(4)),
                    ))
                .visibility(
                  visible: popular,
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  maintainSemantics: true,
                ),
            SizedBox(height: $(12)),
          ],
        ).intoContainer(
          padding: EdgeInsets.symmetric(horizontal: $(10)),
          margin: EdgeInsets.only(bottom: $(7.5)),
          decoration: BoxDecoration(
            color: Color(0xcdcd16191E),
            borderRadius: BorderRadius.circular($(12)),
            border: Border.all(color: checked ? ColorConstant.DiscoveryBtn : Color(0xFF16191E), width: $(1.5)),
          ),
        ),
        Positioned(
          child: Image.asset(Images.ic_buy_item_arrow, height: $(9)).intoContainer(width: width, height: $(9), alignment: Alignment.center).visibility(visible: checked),
          bottom: 0,
        ),
      ],
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
