import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/common/dialog.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:flutter/material.dart' as material;

import 'StripePaymentScreen.dart';
import 'account/LoginScreen.dart';

class StripeSubscriptionScreen extends StatefulWidget {
  const StripeSubscriptionScreen({Key? key}) : super(key: key);

  @override
  _StripeSubscriptionScreenState createState() => _StripeSubscriptionScreenState();
}

const Map<String, dynamic> subscriptions = {
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

class _StripeSubscriptionScreenState extends State<StripeSubscriptionScreen> {
  bool isYear = true;

  bool _loading = true;
  bool _purchasePending = false;
  bool _showPurchasePlan = false;
  UserManager userManager = AppDelegate.instance.getManager();

  @override
  void initState() {
    logEvent(Events.premium_page_loading);

    initStoreInfo();
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

      logEvent(
        Events.paid_success,
        eventValues: {"plan_id": subscription["plan_id"], "product_id": subscription["id"], "price": subscription["price"].toString(), "currency": "USD", "quantity": 1},
      );
    }
  }

  Widget _buildPurchaseButton() {
    if (_showPurchasePlan) {
      return Container();
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
      child: _showPurchasePlan ? null : ButtonWidget(S.of(context).txtContinue),
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
                              "${currentSubscription["title"]} : ${currentSubscription["price"]}/${currentSubscription["unit"]}", ColorConstant.White, FontWeight.w500, 14,
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
                    color: ColorConstant.CardColor,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: Row(
                      children: [
                        Image.asset(
                          isYear ? ImagesConstant.ic_radio_on : ImagesConstant.ic_radio_off,
                          height: 26,
                          width: 26,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitleTextWidget("${S.of(context).yearly} ${yearly["price"]} / ${yearly["unit"]}", ColorConstant.White, FontWeight.w500, 14, align: TextAlign.start),
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
                              TitleTextWidget("50%", ColorConstant.PrimaryColor, FontWeight.w600, 14),
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
                    color: ColorConstant.CardColor,
                    borderRadius: BorderRadius.circular(2.w),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                    child: Row(
                      children: [
                        Image.asset(
                          !isYear ? ImagesConstant.ic_radio_on : ImagesConstant.ic_radio_off,
                          height: 26,
                          width: 26,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitleTextWidget("${S.of(context).monthly} ${monthly["price"]} / ${monthly["unit"]}", ColorConstant.White, FontWeight.w500, 14,
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
                              TitleTextWidget("50%", ColorConstant.PrimaryColor, FontWeight.w600, 14),
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
            _buildPurchaseButton(),
          ],
        )
      ],
    );
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
                isLoading: _loading || _purchasePending,
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => {Navigator.pop(context)},
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: $(24),
                            ).intoContainer(padding: EdgeInsets.all(3)),
                          ),
                          Expanded(
                            child: SizedBox(),
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
                              width: 40.w,
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                              child: material.Card(
                                color: ColorConstant.CardColor,
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
                                            ImagesConstant.ic_no_ads,
                                            height: 24,
                                            width: 24,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                                            child: TitleTextWidget(S.of(context).no_ads, ColorConstant.White, FontWeight.w400, 14),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 2.h,
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            ImagesConstant.ic_no_watermark,
                                            height: 24,
                                            width: 24,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                                            child: TitleTextWidget(S.of(context).no_watermark1, ColorConstant.White, FontWeight.w400, 14),
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
                                            height: 24,
                                            width: 24,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                                            child: TitleTextWidget(S.of(context).high_resolution, ColorConstant.White, FontWeight.w400, 14),
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
                                            height: 24,
                                            width: 24,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                                            child: TitleTextWidget(S.of(context).faster_speed, ColorConstant.White, FontWeight.w400, 14),
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
                            SizedBox(
                              height: 2.h,
                            ),
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
