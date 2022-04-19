import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/Model/UserModel.dart';
import 'package:cartoonizer/api.dart';
import 'LoginScreen.dart';

class StripePaymentScreen extends StatefulWidget {
  final String planId;
  const StripePaymentScreen({Key? key, required this.planId}) : super(key: key);

  @override
  _StripePaymentScreenState createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _purchasePending = false;
  bool _showNewCard = false;
  dynamic _selectedCard = null;
  dynamic _user = null;

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
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
    // find default card
    var creditcards = user.creditcards;
    var selectedCard = null;
    for (var card in creditcards) {
      if (card['is_default']) {
        selectedCard = card;
        break;
      }
    }

    setState(() {
      _user = user;
      _selectedCard = selectedCard;
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

  void _submitPayment(dynamic card) async {
    showPendingUI();
    try {
      var body = jsonEncode({
        "plan_id": widget.planId,
        "category": "creator",
        "new_card": {},
        "customerId": card["customer_id"],
        "payment_method": "creditcard",
        "fundingSource": card["card_id"] != null ? card["card_id"] : "",
      });

      var result = await API.buyPlan(body);
      if (result == true) {
        _handlePaymentSuccess();
      }
    } catch (e) {
      log(e.toString());
    } finally {
      hidePendingUI();
    }
  }

  void _submitPaymentWithNewCard(dynamic newCard) async {
    showPendingUI();
    try {
      // step 1: create stripe token if using new card
      var tokenData = await createStripeToken(newCard);

      // step 2: create stripe subscription, call buy plan api
      var body = jsonEncode({
        "plan_id": widget.planId,
        "category": "creator",
        "new_card": {"exp_year": newCard["exp_year"], "cvc": newCard["cvc"], "exp_month": newCard["exp_month"], "number": newCard["number"]},
        "payment_method": "creditcard",
        "fundingSource": "",
        "stripeToken": tokenData['id']
      });
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
    Navigator.pop(context, true);
  }

  void _handleStripePayment() async {
    if (_selectedCard != null) {
      _submitPayment(_selectedCard);
      return;
    }

    if (_showNewCard && formKey.currentState!.validate()) {
      var date = expiryDate.split('/');

      var newCard = {
        "number": cardNumber,
        "exp_month": date[0],
        "exp_year": date[1],
        "cvc": cvvCode,
      };
      _submitPaymentWithNewCard(newCard);
      return;
    }
  }

  Widget _buildNewCardField() {
    if (!_showNewCard) return Container();

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
        child: CreditCardForm(
            formKey: formKey, // Required
            cardNumber: cardNumber,
            expiryDate: expiryDate,
            cardHolderName: cardHolderName,
            cvvCode: cvvCode,
            onCreditCardModelChange: (CreditCardModel data) {
              setState(() {
                cardNumber = data.cardNumber;
                expiryDate = data.expiryDate;
                cardHolderName = data.cardHolderName;
                cvvCode = data.cvvCode;
              });
            }, // Required
            themeColor: ColorConstant.PrimaryColor,
            obscureCvv: true,
            obscureNumber: false,
            isHolderNameVisible: false,
            isCardNumberVisible: true,
            isExpiryDateVisible: true,
            cardNumberDecoration: const InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorConstant.PrimaryColor, width: 2.0),
              ),
              labelText: 'Card Number',
              hintText: 'XXXX XXXX XXXX XXXX',
              filled: true,
              fillColor: ColorConstant.White,
              floatingLabelStyle: TextStyle(color: ColorConstant.PrimaryColor, fontWeight: FontWeight.w500),
            ),
            expiryDateDecoration: const InputDecoration(
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorConstant.PrimaryColor, width: 2.0),
              ),
              labelText: 'Expired Date',
              hintText: 'XX/XX',
              filled: true,
              fillColor: ColorConstant.White,
              floatingLabelStyle: TextStyle(color: ColorConstant.PrimaryColor, fontWeight: FontWeight.w500),
            ),
            cvvCodeDecoration: const InputDecoration(
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: ColorConstant.PrimaryColor, width: 2.0),
              ),
              border: OutlineInputBorder(),
              labelText: 'CVV',
              hintText: 'XXX',
              filled: true,
              fillColor: ColorConstant.White,
              floatingLabelStyle: TextStyle(color: ColorConstant.PrimaryColor, fontWeight: FontWeight.w500),
            )));
  }

  void onCreditCardModelChange(CreditCardModel? creditCardModel) {
    setState(() {
      cardNumber = creditCardModel!.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

  Widget _buildPurchaseButton() {
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
      child: ButtonWidget(StringConstant.paymentBtn),
    );
  }

  Widget _buildCreditCard(creditCard) {
    bool isSelected = _selectedCard != null && creditCard['id'] == _selectedCard['id'];

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
        child: GestureDetector(
          onTap: () => {
            setState(() {
              _showNewCard = false;
              _selectedCard = creditCard;
            })
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? Color.fromRGBO(235, 232, 255, 1) : ColorConstant.White,
              borderRadius: BorderRadius.circular(2.w),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              child: Row(
                children: [
                  Image.asset(
                    isSelected ? ImagesConstant.ic_radio_on : ImagesConstant.ic_radio_off,
                    height: 8.w,
                    width: 8.w,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TitleTextWidget(creditCard["name"], ColorConstant.TextBlack, FontWeight.w500, 12.sp, align: TextAlign.start),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildCardList() {
    if (_user == null) return Container();

    var creditcards = _user.creditcards;
    return Column(
      children: List.generate(creditcards.length, (index) => _buildCreditCard(creditcards[index])),
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
                    margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => {Navigator.pop(context)},
                          child: Image.asset(
                            ImagesConstant.ic_back_dark,
                            height: 10.w,
                            width: 10.w,
                          ),
                        ),
                        TitleTextWidget(StringConstant.payment, ColorConstant.BtnTextColor, FontWeight.w600, 14.sp),
                        SizedBox(
                          height: 10.w,
                          width: 10.w,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                            height: 2.h,
                          ),
                          _buildCardList(),
                          SizedBox(
                            height: 2.h,
                          ),
                          GestureDetector(
                            onTap: () => {
                              setState(() {
                                _showNewCard = true;
                                _selectedCard = null;
                              })
                            },
                            child: TitleTextWidget(StringConstant.add_new_card, ColorConstant.BtnTextColor, FontWeight.w400, 12.sp),
                          ),
                          SizedBox(
                            height: 2.h,
                          ),
                          _buildNewCardField(),
                          SizedBox(
                            height: 2.h,
                          ),
                          _buildPurchaseButton(),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ));
  }
}
