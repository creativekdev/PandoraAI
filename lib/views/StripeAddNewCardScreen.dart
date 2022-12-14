import 'dart:convert';
import 'dart:developer';
import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/network/base_requester.dart';
import 'package:http/http.dart';
// import 'package:flutter_credit_card/flutter_credit_card.dart';

import 'package:cartoonizer/common/dialog.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/models/UserModel.dart';
import 'package:cartoonizer/Widgets/credit_card_form/credit_card_model.dart';
import 'package:cartoonizer/Widgets/credit_card_form/credit_card_form.dart';
import 'package:cartoonizer/api/api.dart';
import 'account/LoginScreen.dart';

class StripeAddNewCardScreen extends StatefulWidget {
  final String planId;
  final bool buySingle;

  const StripeAddNewCardScreen({
    Key? key,
    required this.planId,
    this.buySingle = false,
  }) : super(key: key);

  @override
  _StripeAddNewCardScreenState createState() => _StripeAddNewCardScreenState();
}

class _StripeAddNewCardScreenState extends State<StripeAddNewCardScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _purchasePending = false;
  bool _showNewCard = false;
  dynamic _selectedCard = null;

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  String zipCode = '';
  bool isCvvFocused = false;
  late bool buySingle;

  @override
  void initState() {
    super.initState();
    buySingle = widget.buySingle;
  }

  @override
  void dispose() {
    super.dispose();
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
      BaseEntity? baseEntity;
      if (buySingle) {
        baseEntity = await CartoonizerApi().buySingle(body);
      } else {
        baseEntity = await CartoonizerApi().buyPlan(body);
      }
      if (baseEntity != null) {
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
    EventBusHelper().eventBus.fire(OnPaySuccessEvent());
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
              formKey: formKey,
              // Required
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
              },
              // Required
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
        var userManager = AppDelegate().getManager<UserManager>();
        await userManager.refreshUser();

        if (userManager.isNeedLogin) {
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
    return LoadingOverlay(
      isLoading: _purchasePending,
      child: Scaffold(
        backgroundColor: ColorConstant.BackgroundColor,
        appBar: AppNavigationBar(
          blurAble: false,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
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
    );
  }
}
