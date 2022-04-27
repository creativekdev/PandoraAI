import 'package:flutter/material.dart';
import 'package:flutter_credit_card/credit_card_widget.dart';

import 'credit_card_model.dart';

class CreditCardForm extends StatefulWidget {
  const CreditCardForm({
    Key? key,
    required this.cardNumber,
    required this.expiryDate,
    required this.cardHolderName,
    required this.cvvCode,
    required this.zipCode,
    this.obscureCvv = false,
    this.obscureNumber = false,
    required this.onCreditCardModelChange,
    required this.themeColor,
    this.textColor = Colors.black,
    this.cursorColor,
    this.cardHolderDecoration = const InputDecoration(
      labelText: 'Card holder',
    ),
    this.cardNumberDecoration = const InputDecoration(
      labelText: 'Card number',
      hintText: 'XXXX XXXX XXXX XXXX',
    ),
    this.expiryDateDecoration = const InputDecoration(
      labelText: 'Expired Date',
      hintText: 'MM/YY',
    ),
    this.zipCodeDecoration = const InputDecoration(
      labelText: 'Zip Code',
      hintText: 'XXXXX',
    ),
    this.cvvCodeDecoration = const InputDecoration(
      labelText: 'CVV',
      hintText: 'XXX',
    ),
    required this.formKey,
    this.cvvValidationMessage = 'Please input a valid CVV',
    this.zipCodeValidationMessage = 'Invalid zip code',
    this.dateValidationMessage = 'Please input a valid date',
    this.numberValidationMessage = 'Please input a valid number',
    this.isZipCodeVisible = true,
    this.isCardNumberVisible = true,
    this.isExpiryDateVisible = true,
  }) : super(key: key);

  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final String zipCode;
  final String cvvValidationMessage;
  final String zipCodeValidationMessage;
  final String dateValidationMessage;
  final String numberValidationMessage;
  final void Function(CreditCardModel) onCreditCardModelChange;
  final Color themeColor;
  final Color textColor;
  final Color? cursorColor;
  final bool obscureCvv;
  final bool obscureNumber;
  final bool isZipCodeVisible;
  final bool isCardNumberVisible;
  final bool isExpiryDateVisible;
  final GlobalKey<FormState> formKey;

  final InputDecoration cardNumberDecoration;
  final InputDecoration cardHolderDecoration;
  final InputDecoration expiryDateDecoration;
  final InputDecoration zipCodeDecoration;
  final InputDecoration cvvCodeDecoration;

  @override
  _CreditCardFormState createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  late String cardNumber;
  late String expiryDate;
  late String cardHolderName;
  late String cvvCode;
  late String zipCode;
  bool isCvvFocused = false;
  late Color themeColor;

  late void Function(CreditCardModel) onCreditCardModelChange;
  late CreditCardModel creditCardModel;

  final MaskedTextController _cardNumberController = MaskedTextController(mask: '0000 0000 0000 0000');
  final TextEditingController _expiryDateController = MaskedTextController(mask: '00/00');
  final TextEditingController _cardHolderNameController = TextEditingController();
  final TextEditingController _zipCodeController = TextEditingController();
  final TextEditingController _cvvCodeController = MaskedTextController(mask: '0000');

  FocusNode cvvFocusNode = FocusNode();
  FocusNode expiryDateNode = FocusNode();
  FocusNode cardHolderNode = FocusNode();
  FocusNode zipCodeHolderNode = FocusNode();

  void textFieldFocusDidChange() {
    creditCardModel.isCvvFocused = cvvFocusNode.hasFocus;
    onCreditCardModelChange(creditCardModel);
  }

  void createCreditCardModel() {
    cardNumber = widget.cardNumber;
    expiryDate = widget.expiryDate;
    cardHolderName = widget.cardHolderName;
    cvvCode = widget.cvvCode;
    zipCode = widget.zipCode;

    creditCardModel = CreditCardModel(cardNumber, expiryDate, cardHolderName, cvvCode, isCvvFocused, zipCode);
  }

  @override
  void initState() {
    super.initState();

    createCreditCardModel();

    onCreditCardModelChange = widget.onCreditCardModelChange;

    cvvFocusNode.addListener(textFieldFocusDidChange);

    _cardNumberController.addListener(() {
      setState(() {
        cardNumber = _cardNumberController.text;
        creditCardModel.cardNumber = cardNumber;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _expiryDateController.addListener(() {
      setState(() {
        expiryDate = _expiryDateController.text;
        creditCardModel.expiryDate = expiryDate;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cardHolderNameController.addListener(() {
      setState(() {
        cardHolderName = _cardHolderNameController.text;
        creditCardModel.cardHolderName = cardHolderName;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cvvCodeController.addListener(() {
      setState(() {
        cvvCode = _cvvCodeController.text;
        creditCardModel.cvvCode = cvvCode;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _zipCodeController.addListener(() {
      setState(() {
        zipCode = _zipCodeController.text;
        creditCardModel.zipCode = zipCode;
        onCreditCardModelChange(creditCardModel);
      });
    });
  }

  @override
  void dispose() {
    cardHolderNode.dispose();
    zipCodeHolderNode.dispose();
    cvvFocusNode.dispose();
    expiryDateNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    themeColor = widget.themeColor;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: themeColor.withOpacity(0.8),
        primaryColorDark: themeColor,
      ),
      child: Form(
        key: widget.formKey,
        child: Column(
          children: <Widget>[
            Visibility(
              visible: widget.isCardNumberVisible,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                margin: const EdgeInsets.only(left: 16, top: 16, right: 16),
                child: TextFormField(
                  obscureText: widget.obscureNumber,
                  controller: _cardNumberController,
                  cursorColor: widget.cursorColor ?? themeColor,
                  onEditingComplete: () {
                    FocusScope.of(context).requestFocus(expiryDateNode);
                  },
                  style: TextStyle(
                    color: widget.textColor,
                  ),
                  decoration: widget.cardNumberDecoration,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.creditCardNumber],
                  validator: (String? value) {
                    // Validate less that 13 digits +3 white spaces
                    if (value!.isEmpty || value.length < 16) {
                      return widget.numberValidationMessage;
                    }
                    return null;
                  },
                ),
              ),
            ),
            Row(
              children: <Widget>[
                Visibility(
                  visible: widget.isExpiryDateVisible,
                  child: Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
                      child: TextFormField(
                        controller: _expiryDateController,
                        cursorColor: widget.cursorColor ?? themeColor,
                        focusNode: expiryDateNode,
                        onEditingComplete: () {
                          FocusScope.of(context).requestFocus(cvvFocusNode);
                        },
                        style: TextStyle(
                          color: widget.textColor,
                        ),
                        decoration: widget.expiryDateDecoration,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        autofillHints: const <String>[AutofillHints.creditCardExpirationDate],
                        validator: (String? value) {
                          if (value!.isEmpty) {
                            return widget.dateValidationMessage;
                          }
                          final DateTime now = DateTime.now();
                          final List<String> date = value.split(RegExp(r'/'));
                          final int month = int.parse(date.first);
                          final int year = int.parse('20${date.last}');
                          final DateTime cardDate = DateTime(year, month);

                          if (cardDate.isBefore(now) || month > 12 || month == 0) {
                            return widget.dateValidationMessage;
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    margin: const EdgeInsets.only(left: 0, top: 8, right: 16),
                    child: TextFormField(
                      obscureText: widget.obscureCvv,
                      focusNode: cvvFocusNode,
                      controller: _cvvCodeController,
                      cursorColor: widget.cursorColor ?? themeColor,
                      onEditingComplete: () {
                        if (widget.isZipCodeVisible)
                          FocusScope.of(context).requestFocus(zipCodeHolderNode);
                        else {
                          FocusScope.of(context).unfocus();
                          onCreditCardModelChange(creditCardModel);
                        }
                      },
                      style: TextStyle(
                        color: widget.textColor,
                      ),
                      decoration: widget.cvvCodeDecoration,
                      keyboardType: TextInputType.number,
                      textInputAction : TextInputAction.next,
                      autofillHints: const <String>[AutofillHints.creditCardSecurityCode],
                      onChanged: (String text) {
                        setState(() {
                          cvvCode = text;
                        });
                      },
                      validator: (String? value) {
                        if (value!.isEmpty || value.length < 3) {
                          return widget.cvvValidationMessage;
                        }
                        return null;
                      },
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
              child: TextFormField(
                controller: _zipCodeController,
                cursorColor: widget.cursorColor ?? themeColor,
                focusNode: zipCodeHolderNode,
                style: TextStyle(
                  color: widget.textColor,
                ),
                decoration: widget.zipCodeDecoration,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                  onCreditCardModelChange(creditCardModel);
                },
                validator: (String? value) {
                  if (value!.isEmpty) {
                    return widget.zipCodeValidationMessage;
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
