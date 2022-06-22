import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/common/dialog.dart';
import 'package:cartoonizer/models/UserModel.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/api/api.dart';
import 'StripeAddNewCardScreen.dart';

class StripePaymentScreen extends StatefulWidget {
  final String planId;
  const StripePaymentScreen({Key? key, required this.planId}) : super(key: key);

  @override
  _StripePaymentScreenState createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _purchasePending = false;
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

    if (creditcards.length == 0) {
      gotoAddNewCard();
    }

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

  Map getCreditCardConfigByBrand(String brand) {
    var config = {};

    switch (brand) {
      case "Visa":
        config = {
          "backgroundColor": [Color.fromRGBO(90, 117, 245, 1), Color.fromRGBO(20, 52, 203, 1)],
          "icon": "assets/images/visa.png",
        };
        break;
      case "MasterCard":
        config = {
          "backgroundColor": [Color.fromRGBO(247, 158, 27, 1), Color.fromRGBO(235, 0, 27, 1)],
          "icon": "assets/images/mastercard.png",
        };
        break;
      case "American Express":
        config = {
          "backgroundColor": [Color.fromRGBO(50, 197, 255, 1), Color.fromRGBO(39, 120, 255, 1)],
          "icon": "assets/images/american_express.png",
        };
        break;
      case "Discover":
        config = {
          "backgroundColor": [Color.fromRGBO(245, 144, 20, 1), Color.fromRGBO(255, 96, 0, 1)],
          "icon": "assets/images/discover.png",
        };
        break;
      default:
        config = {
          "backgroundColor": [Color.fromRGBO(127, 147, 178, 1), Color.fromRGBO(181, 194, 215, 1)],
          "icon": null,
        };
        break;
    }

    return config;
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
      var body = {
        "plan_id": widget.planId,
        "category": "creator",
        "new_card": {},
        "customerId": card["customer_id"],
        "payment_method": "creditcard",
        "fundingSource": card["card_id"] != null ? card["card_id"] : "",
      };

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

  void _handlePaymentSuccess() async {
    GetStorage().write('payment_result', true);
    Navigator.pop(context, true);
    Get.dialog(
      CommonDialog(
        image: ImagesConstant.ic_success,
        description: StringConstant.payment_successfully,
        isCancel: false,
        confirmText: "OK",
      ),
    );
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

  Widget _buildCreditCard(creditCard) {
    Map cardConfig = getCreditCardConfigByBrand(creditCard['brand']);
    String date = "${creditCard['expire_month'].toString().padLeft(2, '0')}/${creditCard['expire_year'].toString().substring(2)}";
    String cardNumber = "∗∗∗∗ ∗∗∗∗ ∗∗∗∗ ${creditCard['last4']}";

    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedCard = creditCard;
            });

            Get.dialog(
              CommonDialog(
                title: cardNumber,
                height: 180,
                description: "Are you sure you want to pay with \n this card?",
                confirmCallback: () {
                  _submitPayment(creditCard);
                },
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: cardConfig["backgroundColor"],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Visibility(
                        visible: cardConfig["icon"] != null,
                        child: Card(
                          color: Color.fromRGBO(255, 255, 255, 0.88),
                          child: Image.asset(
                            cardConfig["icon"],
                            width: 56,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                        )),
                    TitleTextWidget(cardNumber, ColorConstant.White, FontWeight.w500, 16.sp, align: TextAlign.center),
                  ],
                ),
                SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TitleTextWidget(date, ColorConstant.White, FontWeight.w500, 12.sp, align: TextAlign.center),
                  ],
                )
              ]),
            ),
          ),
        ));
  }

  Widget _buildNewCreditCard() {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
        child: GestureDetector(
          onTap: () {
            gotoAddNewCard();
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: ColorConstant.PrimaryColor, width: 2),
              color: Colors.white,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset(
                      ImagesConstant.ic_add,
                      width: 38,
                      height: 38,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 4.w),
                    TitleTextWidget(StringConstant.pay_with_new_card, ColorConstant.TextBlack, FontWeight.w500, 14.sp, align: TextAlign.center),
                  ],
                ),
              ]),
            ),
          ),
        ));
  }

  Widget _buildCardList() {
    if (_user == null) return Container();

    var creditcards = _user.creditcards;
    var cardList = List.generate(creditcards.length, (index) => _buildCreditCard(creditcards[index]));
    cardList.add(_buildNewCreditCard());
    return Column(
      children: cardList,
    );
  }

  void gotoAddNewCard() {
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/StripeAddNewCardScreen"),
        builder: (context) => StripeAddNewCardScreen(planId: widget.planId),
      ),
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
                        TitleTextWidget(StringConstant.payment, ColorConstant.BtnTextColor, FontWeight.w600, FontSizeConstants.topBarTitle),
                        SizedBox(
                          height: 30,
                          width: 30,
                        )
                        // GestureDetector(
                        //   onTap: () async {
                        //     gotoAddNewCard();
                        //   },
                        //   child: Image.asset(
                        //     ImagesConstant.ic_add,
                        //     height: 38,
                        //     width: 38,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildCardList(),
                          SizedBox(
                            height: 2.h,
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
