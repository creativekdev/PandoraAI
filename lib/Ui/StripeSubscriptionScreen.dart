import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart';
import 'package:flutter/material.dart' as material;

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/Model/UserModel.dart';
import 'package:cartoonizer/api.dart';
import 'LoginScreen.dart';
import 'StripePaymentScreen.dart';

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

  late UserModel _user;

  @override
  void initState() {
    initStoreInfo();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> initStoreInfo() async {
    // reload user by get login
    UserModel user = await API.getLogin(needLoad: true);
    setState(() {
      _loading = false;
    });
    if (user.subscription.containsKey('id')) {
      setState(() {
        _showPurchasePlan = true;
        _user = user;
      });
    }
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

  Future<Map<String, dynamic>> createStripeToken() async {
    final url = Uri.parse('https://api.stripe.com/v1/tokens');
    final headers = {"Authorization": "Bearer ${Config.instance.stripePublishableKey}"};
    final response = await post(url,
        body: {
          'card[number]': "4242424242424242",
          'card[exp_month]': '4',
          'card[exp_year]': '2025',
          'card[cvc]': '314',
        },
        headers: headers);
    Map<String, dynamic> data = jsonDecode(response.body);
    return data;
  }

  void _handleStripePayment() async {
    var subscription = isYear ? subscriptions["yearly"] : subscriptions["monthly"];
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/StripePaymentScreen"),
        builder: (context) => StripePaymentScreen(planId: subscription["plan_id"]),
      ),
    );

    if (result != null && result as bool == true) {
      initStoreInfo();
    }
  }

  Widget _buildPurchaseButton() {
    if (_showPurchasePlan) {
      return Container();
    }

    return GestureDetector(
      onTap: () async {
        var sharedPrefs = await SharedPreferences.getInstance();

        UserModel user = await API.getLogin(needLoad: true);
        bool isLogin = sharedPrefs.getBool("isLogin") ?? false;

        if (!isLogin || user.email == "") {
          CommonExtension().showToast(StringConstant.please_login_first);
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
      child: _showPurchasePlan ? null : ButtonWidget(StringConstant.txtContinue),
    );
  }

  Column _buildProductList() {
    if (_loading) return Column();

    if (_showPurchasePlan) {
      var currentSubscription = subscriptions[_user.subscription['plan_type']];

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
                          TitleTextWidget(
                              "${currentSubscription["title"]} : ${currentSubscription["price"]}/${currentSubscription["unit"]}", ColorConstant.TextBlack, FontWeight.w500, 12.sp,
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
                              TitleTextWidget("${yearly["title"]} ${yearly["price"]} / ${yearly["unit"]}", ColorConstant.TextBlack, FontWeight.w500, 12.sp, align: TextAlign.start),
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
                              TitleTextWidget("${monthly["title"]} ${monthly["price"]} / ${monthly["unit"]}", ColorConstant.TextBlack, FontWeight.w500, 12.sp,
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
                            child: Image.asset(
                              ImagesConstant.ic_close,
                              height: 10.w,
                              width: 10.w,
                            ),
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
                              width: 50.w,
                              fit: BoxFit.fitWidth,
                            ),
                            SizedBox(
                              height: 1.h,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                              child: material.Card(
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