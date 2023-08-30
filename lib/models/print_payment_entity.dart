import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/print_payment_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class PrintPaymentEntity {
  late PrintPaymentData data;

  PrintPaymentEntity();

  factory PrintPaymentEntity.fromJson(Map<String, dynamic> json) => $PrintPaymentEntityFromJson(json);

  Map<String, dynamic> toJson() => $PrintPaymentEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintPaymentData {
  late String id;
  late String object;
  @JSONField(name: "after_expiration")
  dynamic afterExpiration;
  @JSONField(name: "allow_promotion_codes")
  dynamic allowPromotionCodes;
  @JSONField(name: "amount_subtotal")
  late int amountSubtotal;
  @JSONField(name: "amount_total")
  late int amountTotal;
  @JSONField(name: "automatic_tax")
  late PrintPaymentDataAutomaticTax automaticTax;
  @JSONField(name: "billing_address_collection")
  dynamic billingAddressCollection;
  @JSONField(name: "cancel_url")
  late String cancelUrl;
  @JSONField(name: "client_reference_id")
  dynamic clientReferenceId;
  dynamic consent;
  @JSONField(name: "consent_collection")
  dynamic consentCollection;
  late int created;
  late String currency;
  @JSONField(name: "currency_conversion")
  dynamic currencyConversion;
  @JSONField(name: "custom_fields")
  late List<dynamic> customFields;
  @JSONField(name: "custom_text")
  late PrintPaymentDataCustomText customText;
  dynamic customer;
  @JSONField(name: "customer_creation")
  late String customerCreation;
  @JSONField(name: "customer_details")
  dynamic customerDetails;
  @JSONField(name: "customer_email")
  dynamic customerEmail;
  @JSONField(name: "expires_at")
  late int expiresAt;
  dynamic invoice;
  @JSONField(name: "invoice_creation")
  late PrintPaymentDataInvoiceCreation invoiceCreation;
  late bool livemode;
  dynamic locale;
  late PrintPaymentDataMetadata metadata;
  late String mode;
  @JSONField(name: "payment_intent")
  late String paymentIntent;
  @JSONField(name: "payment_link")
  dynamic paymentLink;
  @JSONField(name: "payment_method_collection")
  late String paymentMethodCollection;
  @JSONField(name: "payment_method_options")
  late PrintPaymentDataPaymentMethodOptions paymentMethodOptions;
  @JSONField(name: "payment_method_types")
  late List<String> paymentMethodTypes;
  @JSONField(name: "payment_status")
  late String paymentStatus;
  @JSONField(name: "phone_number_collection")
  late PrintPaymentDataPhoneNumberCollection phoneNumberCollection;
  @JSONField(name: "recovered_from")
  dynamic recoveredFrom;
  @JSONField(name: "setup_intent")
  dynamic setupIntent;
  dynamic shipping;
  @JSONField(name: "shipping_address_collection")
  dynamic shippingAddressCollection;
  @JSONField(name: "shipping_options")
  late List<PrintPaymentDataShippingOptions> shippingOptions;
  @JSONField(name: "shipping_rate")
  dynamic shippingRate;
  late String status;
  @JSONField(name: "submit_type")
  dynamic submitType;
  dynamic subscription;
  @JSONField(name: "success_url")
  late String successUrl;
  @JSONField(name: "total_details")
  late PrintPaymentDataTotalDetails totalDetails;
  late String url;

  PrintPaymentData();

  factory PrintPaymentData.fromJson(Map<String, dynamic> json) => $PrintPaymentDataFromJson(json);

  Map<String, dynamic> toJson() => $PrintPaymentDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintPaymentDataAutomaticTax {
  late bool enabled;
  dynamic status;

  PrintPaymentDataAutomaticTax();

  factory PrintPaymentDataAutomaticTax.fromJson(Map<String, dynamic> json) => $PrintPaymentDataAutomaticTaxFromJson(json);

  Map<String, dynamic> toJson() => $PrintPaymentDataAutomaticTaxToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintPaymentDataCustomText {
  @JSONField(name: "shipping_address")
  dynamic shippingAddress;
  dynamic submit;

  PrintPaymentDataCustomText();

  factory PrintPaymentDataCustomText.fromJson(Map<String, dynamic> json) => $PrintPaymentDataCustomTextFromJson(json);

  Map<String, dynamic> toJson() => $PrintPaymentDataCustomTextToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintPaymentDataInvoiceCreation {
  late bool enabled;
  @JSONField(name: "invoice_data")
  late PrintPaymentDataInvoiceCreationInvoiceData invoiceData;

  PrintPaymentDataInvoiceCreation();

  factory PrintPaymentDataInvoiceCreation.fromJson(Map<String, dynamic> json) => $PrintPaymentDataInvoiceCreationFromJson(json);

  Map<String, dynamic> toJson() => $PrintPaymentDataInvoiceCreationToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintPaymentDataInvoiceCreationInvoiceData {
  @JSONField(name: "account_tax_ids")
  dynamic accountTaxIds;
  @JSONField(name: "custom_fields")
  dynamic customFields;
  dynamic description;
  dynamic footer;
  late PrintPaymentDataInvoiceCreationInvoiceDataMetadata metadata;
  @JSONField(name: "rendering_options")
  dynamic renderingOptions;

  PrintPaymentDataInvoiceCreationInvoiceData();

  factory PrintPaymentDataInvoiceCreationInvoiceData.fromJson(Map<String, dynamic> json) => $PrintPaymentDataInvoiceCreationInvoiceDataFromJson(json);

  Map<String, dynamic> toJson() => $PrintPaymentDataInvoiceCreationInvoiceDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintPaymentDataInvoiceCreationInvoiceDataMetadata {
  PrintPaymentDataInvoiceCreationInvoiceDataMetadata();

  factory PrintPaymentDataInvoiceCreationInvoiceDataMetadata.fromJson(Map<String, dynamic> json) => $PrintPaymentDataInvoiceCreationInvoiceDataMetadataFromJson(json);

  Map<String, dynamic> toJson() => $PrintPaymentDataInvoiceCreationInvoiceDataMetadataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintPaymentDataMetadata {
  PrintPaymentDataMetadata();

  factory PrintPaymentDataMetadata.fromJson(Map<String, dynamic> json) => $PrintPaymentDataMetadataFromJson(json);

  Map<String, dynamic> toJson() => $PrintPaymentDataMetadataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintPaymentDataPaymentMethodOptions {
  PrintPaymentDataPaymentMethodOptions();

  factory PrintPaymentDataPaymentMethodOptions.fromJson(Map<String, dynamic> json) => $PrintPaymentDataPaymentMethodOptionsFromJson(json);

  Map<String, dynamic> toJson() => $PrintPaymentDataPaymentMethodOptionsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintPaymentDataPhoneNumberCollection {
  late bool enabled;

  PrintPaymentDataPhoneNumberCollection();

  factory PrintPaymentDataPhoneNumberCollection.fromJson(Map<String, dynamic> json) => $PrintPaymentDataPhoneNumberCollectionFromJson(json);

  Map<String, dynamic> toJson() => $PrintPaymentDataPhoneNumberCollectionToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintPaymentDataShippingOptions {
  @JSONField(name: "shipping_amount")
  late int shippingAmount;
  @JSONField(name: "shipping_rate")
  late String shippingRate;

  PrintPaymentDataShippingOptions();

  factory PrintPaymentDataShippingOptions.fromJson(Map<String, dynamic> json) => $PrintPaymentDataShippingOptionsFromJson(json);

  Map<String, dynamic> toJson() => $PrintPaymentDataShippingOptionsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintPaymentDataTotalDetails {
  @JSONField(name: "amount_discount")
  late int amountDiscount;
  @JSONField(name: "amount_shipping")
  late int amountShipping;
  @JSONField(name: "amount_tax")
  late int amountTax;

  PrintPaymentDataTotalDetails();

  factory PrintPaymentDataTotalDetails.fromJson(Map<String, dynamic> json) => $PrintPaymentDataTotalDetailsFromJson(json);

  Map<String, dynamic> toJson() => $PrintPaymentDataTotalDetailsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
