import 'dart:io';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/dialog.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/widgets/outline_widget.dart';
import 'package:common_utils/common_utils.dart';

import '../../utils/utils.dart';
import '../account/LoginScreen.dart';
import 'StripePaymentScreen.dart';
import 'widgets/payment_attrs_list.dart';

class StripeSubscriptionScreen extends StatefulWidget {
  const StripeSubscriptionScreen({Key? key}) : super(key: key);

  @override
  _StripeSubscriptionScreenState createState() => _StripeSubscriptionScreenState();
}

class _StripeSubscriptionScreenState extends State<StripeSubscriptionScreen> {
  bool isYear = true;

  bool _loading = true;
  bool _purchasePending = false;
  bool _showPurchasePlan = false;
  UserManager userManager = AppDelegate.instance.getManager();
  Map<String, dynamic> subscriptions = {
    "monthly": {
      "id": "io.socialbook.cartoonizer.monthly",
      "plan_id": "80000",
      "title": S.of(Get.context!).monthly,
      "price": 3.99,
      "unit": S.of(Get.context!).month,
    },
    "yearly": {
      "id": "io.socialbook.cartoonizer.yearly",
      "plan_id": "80001",
      "title": S.of(Get.context!).yearly,
      "price": 39.99,
      "unit": S.of(Get.context!).year,
    },
    "yearly29": {
      "id": "io.socialbook.cartoonizer.yearly29",
      "plan_id": "80002",
      "title": S.of(Get.context!).yearly,
      "price": 29.99,
      "unit": S.of(Get.context!).year,
    },
  };

  @override
  void initState() {
    super.initState();
    initStoreInfo();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initStoreInfo() async {
    // reload user by get login
    userManager.refreshUser().then((value) {
      setState(() {
        _loading = false;
      });
      if (userManager.user != null) {
        if (userManager.user!.userSubscription.containsKey('id')) {
          setState(() {
            _showPurchasePlan = true;
          });
        } else {
          setState(() {
            _showPurchasePlan = false;
          });
        }
      }
    });
  }

  void showPendingUI() {
    setState(() {
      _purchasePending = true;
    });
  }

  void hidePendingUI() {
    setState(() {
      _purchasePending = false;
    });
  }

  void _handleStripePayment() async {
    var subscription = isYear ? subscriptions["yearly29"] : subscriptions["monthly"];

    bool? result = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/StripePaymentScreen"),
        builder: (context) => StripePaymentScreen(planId: subscription["plan_id"]),
      ),
    );
    if (result ?? false) {
      Get.dialog(
        CommonDialog(
          image: ImagesConstant.ic_success,
          description: S.of(context).payment_successfully,
          isCancel: false,
          confirmText: S.of(context).ok,
        ),
      );
    }

    var paymentResult = GetStorage().read('payment_result');

    if (paymentResult != null && paymentResult as bool == true) {
      initStoreInfo();
      GetStorage().remove("payment_result");
    }
  }

  Widget _buildPurchaseButton() {
    if (_showPurchasePlan) {
      return Container(height: 50.dp);
    }

    return GestureDetector(
      onTap: () async {
        if (_purchasePending) return;
        // FirebaseAnalytics.instance.logEvent(name: Events.click_purchase);

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
          _handleStripePayment();
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
              height: 50.dp,
              alignment: Alignment.center,
              margin: EdgeInsets.symmetric(horizontal: $(15)),
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
    if (_loading) {
      return Container(
        height: 170.dp,
      );
    }

    if (_showPurchasePlan) {
      var subscription = userManager.user!.userSubscription;
      var planId = subscription['plan_id']?.toString();
      var appleId = subscription['apple_store_plan_id']?.toString();
      var currentSubscription;
      if (!TextUtil.isEmpty(appleId)) {
        currentSubscription = subscriptions.values.toList().pick((t) => t['id'] == appleId);
      } else if (!TextUtil.isEmpty(planId)) {
        currentSubscription = subscriptions.values.toList().pick((t) => t['plan_id'] == planId);
      }
      if (currentSubscription == null) {
        return Container();
      }
      return buyPlanItem(
        context,
        plan: currentSubscription,
        checked: true,
        popular: false,
      ).intoContainer(
          margin: EdgeInsets.only(
        left: 15.dp,
        right: 15.dp,
        top: 20.dp,
        bottom: 90.dp,
      ));
    }

    var monthly = subscriptions["monthly"];
    var yearly = subscriptions["yearly29"];

    if (monthly == null && yearly == null) {
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
        if (Platform.isAndroid) {
          Get.to(StripeSubscriptionScreen());
        }
      });
    }

    var yearlyPrice = double.tryParse(yearly['price']?.toString() ?? '0') ?? 0;
    double originYearlyPrice = 0;
    if (yearlyPrice != 0) {
      originYearlyPrice = yearlyPrice / 0.75;
    }
    return Column(
      children: [
        buyPlanItem(
          context,
          plan: monthly,
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
          plan: yearly,
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
    ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15), vertical: $(20)));
  }

  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: _loading || _purchasePending,
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
    );
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
                  text: "${plan['title']}",
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
                                    width: yearlyOriP.toStringAsFixed(2).length * $(8.8),
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
                  child: TitleTextWidget("\$${plan["price"]}", ColorConstant.White, FontWeight.w500, $(26), align: TextAlign.center),
                ),
                SizedBox(height: $(12)),
              ],
            ).intoContainer(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: $(10)),
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
                  '25% off',
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
          )
      ],
    ).intoContainer(height: 60.dp);
  }
}
