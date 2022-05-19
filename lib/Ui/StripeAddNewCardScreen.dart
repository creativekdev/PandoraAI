import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
// import 'package:flutter_credit_card/flutter_credit_card.dart';

import 'package:cartoonizer/Common/dialog.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/Model/UserModel.dart';
import 'package:cartoonizer/Widgets/credit_card_form/credit_card_model.dart';
import 'package:cartoonizer/Widgets/credit_card_form/credit_card_form.dart';
import 'package:cartoonizer/api.dart';
import 'LoginScreen.dart';

class StripeAddNewCardScreen extends StatefulWidget {
  final String planId;
  const StripeAddNewCardScreen({Key? key, required this.planId}) : super(key: key);

  @override
  _StripeAddNewCardScreenState createState() => _StripeAddNewCardScreenState();
}

class _StripeAddNewCardScreenState extends State<StripeAddNewCardScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _purchasePending = false;
  bool _showNewCard = false;
  dynamic _selectedCard = null;
  dynamic _user = null;

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  String zipCode = '';
  bool isCvvFocused = false;

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
    UserModel user = await API.getLogin(needLoad: false);

    setState(() {
      _user = user;
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

  Future<Map<String, dynamic>> createStripeToken(dynamic card) async {
    final url = Uri.parse('https://api.stripe.com/v1/tokens');
    final headers = {"Authorization": "Bearer ${Config.instance.stripePublishableKey}"};
    final response = await post(url,
        body: {
          'card[number]': card["number"],
          'card[exp_month]': card["exp_month"],
          'card[exp_year]': card["exp_year"],
          'card[cvc]': card["cvc"],
        },
        headers: headers);
    Map<String, dynamic> data = jsonDecode(response.body);
    return data;
  }

  void _submitPaymentWithNewCard(dynamic newCard) async {
    showPendingUI();
    try {
      // step 1: create stripe token if using new card
      var tokenData = await createStripeToken(newCard);

      // step 2: create stripe subscription, call buy plan api
      var body = {
        "plan_id": widget.planId,
        "category": "creator",
        "new_card": {"exp_year": newCard["exp_year"], "cvc": newCard["cvc"], "exp_month": newCard["exp_month"], "number": newCard["number"], "address_zip": newCard["address_zip"]},
        "payment_method": "creditcard",
        "fundingSource": "",
        "stripeToken": tokenData['id']
      };
      var result = await API.buyPlan(body);
      if (result) {
        _handlePaymentSuccess();
      }
    } catch (e) {
      log(e.toString());
    } finally {
      hidePendingUI();
    }
  }

  void _handlePaymentSuccess() async {
    GetStorage().write('payment_result', true);
    Navigator.popUntil(context, ModalRoute.withName('/StripeSubscriptionScreen'));

    Get.dialog(
      CommonDialog(
        image: ImagesConstant.ic_success,
        description: StringConstant.payment_successfully,
        isCancel: false,
        confirmText: "OK",
      ),
    );
  }

  void _handleStripePayment() async {
    if (formKey.currentState!.validate()) {
      var date = expiryDate.split('/');

      var newCard = {
        "number": cardNumber,
        "exp_month": date[0],
        "exp_year": date[1],
        "cvc": cvvCode,
        "address_zip": zipCode,
      };
      _submitPaymentWithNewCard(newCard);
      return;
    } else {
      hidePendingUI();
    }
  }

  Widget _buildNewCardField() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.h),
        child: Column(
          children: [
            CreditCardForm(
              formKey: formKey, // Required
              cardNumber: cardNumber,
              expiryDate: expiryDate,
              cardHolderName: cardHolderName,
              cvvCode: cvvCode,
              zipCode: zipCode,
              onCreditCardModelChange: (CreditCardModel data) {
                setState(() {
                  cardNumber = data.cardNumber;
                  expiryDate = data.expiryDate;
                  cardHolderName = data.cardHolderName;
                  cvvCode = data.cvvCode;
                  zipCode = data.zipCode;
                });
              }, // Required
              themeColor: ColorConstant.White,
              textColor: ColorConstant.White,
              obscureCvv: true,
              obscureNumber: false,
              isZipCodeVisible: true,
              isCardNumberVisible: true,
              isExpiryDateVisible: true,
              cardNumberDecoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ColorConstant.White, width: 2.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ColorConstant.White, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ColorConstant.White, width: 2.0),
                ),
                labelText: 'Card Number',
                hintText: 'XXXX XXXX XXXX XXXX',
                hintStyle: TextStyle(
                  color: ColorConstant.White,
                  fontWeight: FontWeight.w400,
                ),
                labelStyle: TextStyle(
                  color: ColorConstant.White,
                  fontWeight: FontWeight.w400,
                ),
                floatingLabelStyle: TextStyle(color: ColorConstant.White, fontWeight: FontWeight.w500),
              ),
              expiryDateDecoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ColorConstant.White, width: 2.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ColorConstant.White, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ColorConstant.White, width: 2.0),
                ),
                labelText: 'Expired Date',
                hintText: 'XX/XX',
                hintStyle: TextStyle(
                  color: ColorConstant.White,
                  fontWeight: FontWeight.w400,
                ),
                labelStyle: TextStyle(
                  color: ColorConstant.White,
                  fontWeight: FontWeight.w400,
                ),
                floatingLabelStyle: TextStyle(color: ColorConstant.White, fontWeight: FontWeight.w500),
              ),
              cvvCodeDecoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ColorConstant.White, width: 2.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ColorConstant.White, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ColorConstant.White, width: 2.0),
                ),
                labelText: 'CVV',
                hintText: 'XXX',
                hintStyle: TextStyle(
                  color: ColorConstant.White,
                  fontWeight: FontWeight.w400,
                ),
                labelStyle: TextStyle(
                  color: ColorConstant.White,
                  fontWeight: FontWeight.w400,
                ),
                floatingLabelStyle: TextStyle(color: ColorConstant.White, fontWeight: FontWeight.w500),
              ),
              zipCodeDecoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ColorConstant.White, width: 2.0),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ColorConstant.White, width: 2.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  borderSide: BorderSide(color: ColorConstant.White, width: 2.0),
                ),
                labelText: StringConstant.zip_code,
                hintText: 'XXXX',
                hintStyle: TextStyle(
                  color: ColorConstant.White,
                  fontWeight: FontWeight.w400,
                ),
                labelStyle: TextStyle(
                  color: ColorConstant.White,
                  fontWeight: FontWeight.w400,
                ),
                floatingLabelStyle: TextStyle(color: ColorConstant.White, fontWeight: FontWeight.w500),
              ),
            )
          ],
        ));
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      zipCode = creditCardModel.zipCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  Widget _buildPurchaseButton() {
    return GestureDetector(
      onTap: () async {
        if (_purchasePending) return;
        showPendingUI();
        var sharedPrefs = await SharedPreferences.getInstance();

        UserModel user = await API.getLogin(needLoad: true);
        bool isLogin = sharedPrefs.getBool("isLogin") ?? false;

        if (!isLogin || user.email == "") {
          hidePendingUI();
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
      child: ButtonWidget(StringConstant.paymentBtn),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: ColorConstant.BackgroundColor,
        body: SafeArea(
          child: LoadingOverlay(
              isLoading: _purchasePending,
              child: Column(
                children: [
                  Container(
                    margin: EdgeConstants.TopBarEdgeInsets,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => {Navigator.pop(context)},
                          child: Image.asset(
                            ImagesConstant.ic_back,
                            height: 30,
                            width: 30,
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
                              // height: 5.h,
                              ),
                          TitleTextWidget(StringConstant.pay_with_new_card, ColorConstant.BtnTextColor, FontWeight.w500, 24),
                          SizedBox(
                            height: 2.h,
                          ),
                          _buildNewCardField(),
                          SizedBox(
                            height: 5.h,
                          ),
                          _buildPurchaseButton(),
                          SizedBox(
                            height: 5.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ));
  }
}
