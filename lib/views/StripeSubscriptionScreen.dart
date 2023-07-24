import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/dialog.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';

import 'StripePaymentScreen.dart';
import 'account/LoginScreen.dart';

class StripeSubscriptionScreen extends StatefulWidget {
  const StripeSubscriptionScreen({Key? key}) : super(key: key);

  @override
  _StripeSubscriptionScreenState createState() => _StripeSubscriptionScreenState();
}

class _StripeSubscriptionScreenState extends State<StripeSubscriptionScreen> {
  bool isYear = false;

  bool _loading = true;
  bool _purchasePending = false;
  bool _showPurchasePlan = false;
  UserManager userManager = AppDelegate.instance.getManager();
  Map<String, dynamic> subscriptions = {
    "monthly": {
      "id": "io.socialbook.cartoonizer.monthly",
      "plan_id": "80000",
      "title": "Monthly",
      "price": 3.99,
      "unit": "Month",
    },
    "yearly": {
      "id": "io.socialbook.cartoonizer.yearly",
      "plan_id": "80001",
      "title": "Yearly",
      "price": 39.99,
      "unit": "Year",
    },
  };

  @override
  void initState() {
    delay(() {
      subscriptions = {
        "monthly": {
          "id": "io.socialbook.cartoonizer.monthly",
          "plan_id": "80000",
          "title": S.of(context).monthly,
          "price": 3.99,
          "unit": S.of(context).month,
        },
        "yearly": {
          "id": "io.socialbook.cartoonizer.yearly",
          "plan_id": "80001",
          "title": S.of(context).yearly,
          "price": 39.99,
          "unit": S.of(context).year,
        },
      };
      initStoreInfo();
    });
    super.initState();
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
    var subscription = isYear ? subscriptions["yearly"] : subscriptions["monthly"];

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
      return Container();
    }

    var monthly = subscriptions["monthly"];
    var yearly = subscriptions["yearly"];

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
          : RichText(
              text: TextSpan(text: S.of(context).selected, style: TextStyle(color: ColorConstant.White, fontFamily: 'Poppins', fontSize: $(17)), children: [
              TextSpan(
                text: '\$${(isYear ? yearly['price'] : monthly['price']) ?? ''}',
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
    if (_loading) return Column();

    if (_showPurchasePlan) {
      var currentSubscription = subscriptions[userManager.user!.userSubscription['plan_type']];

      return Column(children: [
        Padding(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Container(
              decoration: BoxDecoration(
                color: ColorConstant.CardColor,
                borderRadius: BorderRadius.circular(2.w),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                child: Row(
                  children: [
                    Image.asset(
                      ImagesConstant.ic_radio_on,
                      height: 26,
                      width: 26,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitleTextWidget(
                              "${currentSubscription["title"]} : \$${currentSubscription["price"]} / ${currentSubscription["unit"]}", ColorConstant.White, FontWeight.w500, 14,
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

    var monthly = subscriptions["monthly"];
    var yearly = subscriptions["yearly"];

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
    return Row(
      children: [
        SizedBox(width: $(24)),
        Expanded(
            child: buyPlanItem(
          context,
          plan: monthly,
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
            child: buyPlanItem(context, plan: yearly, checked: isYear).intoGestureDetector(onTap: () {
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
            )),
            _buildPurchaseButton(),
            SizedBox(height: ScreenUtil.getBottomPadding(context) + $(15))
          ],
        ),
      ).intoContainer(
        decoration: BoxDecoration(image: DecorationImage(image: AssetImage(Images.ic_buy_bg), fit: BoxFit.fill)),
      ),
    );
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
            TitleTextWidget("${plan['title']}", ColorConstant.White, FontWeight.w500, $(14), align: TextAlign.center),
            SizedBox(height: $(16)),
            TitleTextWidget("\$${plan["price"]}", ColorConstant.White, FontWeight.w500, $(26), align: TextAlign.center),
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
