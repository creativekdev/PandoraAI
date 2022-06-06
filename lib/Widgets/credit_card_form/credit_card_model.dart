class CreditCardModel {
  CreditCardModel(this.cardNumber, this.expiryDate, this.cardHolderName, this.cvvCode, this.isCvvFocused, this.zipCode);

  String cardNumber = '';
  String expiryDate = '';
  String cardHolderName = '';
  String cvvCode = '';
  String zipCode = '';
  bool isCvvFocused = false;
}
