import 'dart:developer';
import 'dart:io';

import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/controller/effect_data_controller.dart';
import 'package:cartoonizer/api/api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/ConsumableStore.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/widgets/outline_widget.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import '../account/LoginScreen.dart';
import 'widgets/payment_attrs_list.dart';

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
          : Text(
              S.of(context).pay_now,
              style: TextStyle(
                fontSize: $(22),
                color: Colors.white,
                fontFamily: 'Poppins',
              ),
            ).intoContainer(
              width: double.maxFinite,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: $(15)),
              padding: EdgeInsets.symmetric(vertical: $(10)),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorConstant.ColorLinearStart,
                    ColorConstant.ColorLinearEnd,
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
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
    var yearlyPrice = double.tryParse(year.price?.toString() ?? '0') ?? 0;
    double originYearlyPrice = 0;
    if (yearlyPrice != 0) {
      originYearlyPrice = yearlyPrice / 0.65;
    }

    var currentPlan;
    if (_showPurchasePlan) {
      var user = userManager.user!;
      bool isMonthlyPlan = user.userSubscription['plan_type'] == 'monthly';
      currentPlan = isMonthlyPlan ? month : year;
      return buyPlanItem(
        context,
        plan: currentPlan,
        checked: true,
        popular: false,
      ).intoContainer(
          margin: EdgeInsets.only(
        left: $(15),
        right: $(15),
        top: $(15),
      ));
    }

    return Column(
      children: [
        SizedBox(height: $(20)),
        buyPlanItem(
          context,
          plan: month,
          checked: !isYear,
          popular: false,
        ).intoGestureDetector(onTap: () {
          if (!isYear) {
            return;
          }
          setState(() {
            isYear = false;
          });
        }),
        SizedBox(height: $(10)),
        buyPlanItem(
          context,
          plan: year,
          checked: isYear,
          popular: true,
          yearlyOriP: originYearlyPrice,
        ).intoGestureDetector(onTap: () {
          if (isYear) {
            return;
          }
          setState(() {
            isYear = true;
          });
        }),
      ],
    ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15)));
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
                            color: Color(0x99000000),
                            borderRadius: BorderRadius.circular(1.w),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.6.h),
                            child: TitleTextWidget(S.of(context).restore, Colors.white.withOpacity(0.62), FontWeight.w500, 11.sp),
                          ),
                        ),
                      ),
                    SizedBox(width: $(24)),
                  ],
                ).intoContainer(margin: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight())),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    RichText(
                        text: TextSpan(
                            text: S.of(context).app_name,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: $(20),
                              fontWeight: FontWeight.w500,
                              fontFamily: 'Poppins',
                            ),
                            children: [
                          WidgetSpan(
                            baseline: TextBaseline.alphabetic,
                            alignment: PlaceholderAlignment.baseline,
                            child: ShaderMask(
                              shaderCallback: (rect) {
                                return LinearGradient(colors: [
                                  ColorConstant.ColorLinearStart,
                                  ColorConstant.ColorLinearEnd,
                                ]).createShader(rect);
                              },
                              blendMode: BlendMode.srcATop,
                              child: Text(
                                S.of(context).pro,
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: $(20),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ).intoContainer(margin: EdgeInsets.only(left: $(6))),
                          )
                        ])),
                    SizedBox(height: $(10)),
                    TitleTextWidget(S.of(context).buy_attr_ai_tools, Colors.white, FontWeight.normal, $(14), maxLines: 3)
                        .intoContainer(margin: EdgeInsets.symmetric(horizontal: $(26))),
                    SizedBox(height: $(15)),
                    PaymentAttrsList(),
                    _buildProductList(),
                  ],
                )),
                _buildPurchaseButton(),
                SizedBox(height: ScreenUtil.getBottomPadding(context) + $(15))
              ],
            ),
          ).intoContainer(
            decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Images.ic_pro_background), fit: BoxFit.fill)),
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset(imageRes, height: 24, width: 24),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: TitleTextWidget(title, ColorConstant.White, FontWeight.w400, 14, maxLines: 10, align: TextAlign.start),
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
    double? yearlyOriP,
  }) {
    return Stack(
      children: [
        OutlineWidget(
            strokeWidth: $(1.5),
            radius: $(14),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: !checked
                  ? [Color(0xff131313), Color(0xff131313)]
                  : [
                      ColorConstant.ColorLinearStart,
                      ColorConstant.ColorLinearStart,
                      ColorConstant.ColorLinearStart,
                      ColorConstant.ColorLinearEnd,
                    ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: $(20),
                  height: $(20),
                  child: Container(
                    width: $(15),
                    height: $(15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular($(24)),
                      color: checked ? ColorConstant.ColorLinearStart : Colors.transparent,
                    ),
                  ).intoCenter(),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: checked ? ColorConstant.ColorLinearStart : Color(0xff3b3b3b),
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular($(24))),
                ),
                SizedBox(width: $(10)),
                RichText(
                    text: TextSpan(
                  text: "${plan.title}",
                  style: TextStyle(
                    fontSize: $(14),
                    color: Colors.white,
                    fontFamily: 'Poppins',
                  ),
                  children: [
                    WidgetSpan(
                        baseline: TextBaseline.alphabetic,
                        alignment: PlaceholderAlignment.middle,
                        child: yearlyOriP != null
                            ? Stack(
                                children: [
                                  Text(
                                    '(${yearlyOriP.toStringAsFixed(2)})',
                                    style: TextStyle(color: Color(0xffa5a5a5), fontSize: $(14)),
                                  ),
                                  Container(
                                    height: 1,
                                    color: checked ? ColorConstant.ColorLinearStart : Color(0xffa5a5a5),
                                    width: yearlyOriP.toStringAsFixed(2).length * $(10.4),
                                  ).intoCenter(),
                                ],
                              ).intoContainer(height: $(20), margin: EdgeInsets.only(left: $(6)))
                            : Container()),
                  ],
                )),
                Expanded(child: Container()),
                ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: checked
                          ? [
                              ColorConstant.ColorLinearStart,
                              ColorConstant.ColorLinearStart,
                              ColorConstant.ColorLinearStart,
                              ColorConstant.ColorLinearEnd,
                            ]
                          : [
                              Colors.white,
                              Colors.white,
                            ],
                    ).createShader(rect);
                  },
                  child: TitleTextWidget("${plan.price}", ColorConstant.White, FontWeight.w500, $(26), align: TextAlign.center),
                ),
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
                    .visibility(visible: false),
                SizedBox(height: $(12)),
              ],
            ).intoContainer(
              padding: EdgeInsets.symmetric(horizontal: $(10), vertical: $(6)),
              margin: EdgeInsets.all($(1.5)),
              decoration: BoxDecoration(
                color: Color(0xff040404),
                borderRadius: BorderRadius.circular($(14)),
                border: Border.all(color: Colors.transparent, width: $(1.5)),
              ),
            )),
        if (yearlyOriP != null)
          Positioned(
            child: ClipRRect(
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), topRight: Radius.circular($(32))),
              child: Container(
                child: Text(
                  '35% off',
                  style: TextStyle(color: Colors.white, fontSize: $(8), fontFamily: 'Poppins'),
                ),
                padding: EdgeInsets.symmetric(horizontal: $(8)),
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  colors: checked
                      ? [
                          ColorConstant.ColorLinearStart,
                          ColorConstant.ColorLinearEnd,
                        ]
                      : [
                          Color(0xff131313),
                          Color(0xff131313),
                        ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )),
              ),
            ),
            top: 1,
            right: 0,
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

int getPlanLimit(HomeCardType type) {
  EffectDataController effectDataController = Get.find();
  var pick = effectDataController.data?.aiConfig.pick((t) => t.key == type.value());
  if (pick == null) {
    return 0;
  }
  return pick.planDailyLimit;
}
