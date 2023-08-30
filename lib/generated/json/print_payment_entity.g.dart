import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/print_payment_entity.dart';

PrintPaymentEntity $PrintPaymentEntityFromJson(Map<String, dynamic> json) {
  final PrintPaymentEntity printPaymentEntity = PrintPaymentEntity();
  final PrintPaymentData? data = jsonConvert.convert<PrintPaymentData>(json['data']);
  if (data != null) {
    printPaymentEntity.data = data;
  }
  return printPaymentEntity;
}

Map<String, dynamic> $PrintPaymentEntityToJson(PrintPaymentEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['data'] = entity.data.toJson();
  return data;
}

PrintPaymentData $PrintPaymentDataFromJson(Map<String, dynamic> json) {
  final PrintPaymentData printPaymentData = PrintPaymentData();
  final String? id = jsonConvert.convert<String>(json['id']);
  if (id != null) {
    printPaymentData.id = id;
  }
  final String? object = jsonConvert.convert<String>(json['object']);
  if (object != null) {
    printPaymentData.object = object;
  }
  final dynamic afterExpiration = jsonConvert.convert<dynamic>(json['after_expiration']);
  if (afterExpiration != null) {
    printPaymentData.afterExpiration = afterExpiration;
  }
  final dynamic allowPromotionCodes = jsonConvert.convert<dynamic>(json['allow_promotion_codes']);
  if (allowPromotionCodes != null) {
    printPaymentData.allowPromotionCodes = allowPromotionCodes;
  }
  final int? amountSubtotal = jsonConvert.convert<int>(json['amount_subtotal']);
  if (amountSubtotal != null) {
    printPaymentData.amountSubtotal = amountSubtotal;
  }
  final int? amountTotal = jsonConvert.convert<int>(json['amount_total']);
  if (amountTotal != null) {
    printPaymentData.amountTotal = amountTotal;
  }
  final PrintPaymentDataAutomaticTax? automaticTax = jsonConvert.convert<PrintPaymentDataAutomaticTax>(json['automatic_tax']);
  if (automaticTax != null) {
    printPaymentData.automaticTax = automaticTax;
  }
  final dynamic billingAddressCollection = jsonConvert.convert<dynamic>(json['billing_address_collection']);
  if (billingAddressCollection != null) {
    printPaymentData.billingAddressCollection = billingAddressCollection;
  }
  final String? cancelUrl = jsonConvert.convert<String>(json['cancel_url']);
  if (cancelUrl != null) {
    printPaymentData.cancelUrl = cancelUrl;
  }
  final dynamic clientReferenceId = jsonConvert.convert<dynamic>(json['client_reference_id']);
  if (clientReferenceId != null) {
    printPaymentData.clientReferenceId = clientReferenceId;
  }
  final dynamic consent = jsonConvert.convert<dynamic>(json['consent']);
  if (consent != null) {
    printPaymentData.consent = consent;
  }
  final dynamic consentCollection = jsonConvert.convert<dynamic>(json['consent_collection']);
  if (consentCollection != null) {
    printPaymentData.consentCollection = consentCollection;
  }
  final int? created = jsonConvert.convert<int>(json['created']);
  if (created != null) {
    printPaymentData.created = created;
  }
  final String? currency = jsonConvert.convert<String>(json['currency']);
  if (currency != null) {
    printPaymentData.currency = currency;
  }
  final dynamic currencyConversion = jsonConvert.convert<dynamic>(json['currency_conversion']);
  if (currencyConversion != null) {
    printPaymentData.currencyConversion = currencyConversion;
  }
  final List<dynamic>? customFields = jsonConvert.convertListNotNull<dynamic>(json['custom_fields']);
  if (customFields != null) {
    printPaymentData.customFields = customFields;
  }
  final PrintPaymentDataCustomText? customText = jsonConvert.convert<PrintPaymentDataCustomText>(json['custom_text']);
  if (customText != null) {
    printPaymentData.customText = customText;
  }
  final dynamic customer = jsonConvert.convert<dynamic>(json['customer']);
  if (customer != null) {
    printPaymentData.customer = customer;
  }
  final String? customerCreation = jsonConvert.convert<String>(json['customer_creation']);
  if (customerCreation != null) {
    printPaymentData.customerCreation = customerCreation;
  }
  final dynamic customerDetails = jsonConvert.convert<dynamic>(json['customer_details']);
  if (customerDetails != null) {
    printPaymentData.customerDetails = customerDetails;
  }
  final dynamic customerEmail = jsonConvert.convert<dynamic>(json['customer_email']);
  if (customerEmail != null) {
    printPaymentData.customerEmail = customerEmail;
  }
  final int? expiresAt = jsonConvert.convert<int>(json['expires_at']);
  if (expiresAt != null) {
    printPaymentData.expiresAt = expiresAt;
  }
  final dynamic invoice = jsonConvert.convert<dynamic>(json['invoice']);
  if (invoice != null) {
    printPaymentData.invoice = invoice;
  }
  final PrintPaymentDataInvoiceCreation? invoiceCreation = jsonConvert.convert<PrintPaymentDataInvoiceCreation>(json['invoice_creation']);
  if (invoiceCreation != null) {
    printPaymentData.invoiceCreation = invoiceCreation;
  }
  final bool? livemode = jsonConvert.convert<bool>(json['livemode']);
  if (livemode != null) {
    printPaymentData.livemode = livemode;
  }
  final dynamic locale = jsonConvert.convert<dynamic>(json['locale']);
  if (locale != null) {
    printPaymentData.locale = locale;
  }
  final PrintPaymentDataMetadata? metadata = jsonConvert.convert<PrintPaymentDataMetadata>(json['metadata']);
  if (metadata != null) {
    printPaymentData.metadata = metadata;
  }
  final String? mode = jsonConvert.convert<String>(json['mode']);
  if (mode != null) {
    printPaymentData.mode = mode;
  }
  final String? paymentIntent = jsonConvert.convert<String>(json['payment_intent']);
  if (paymentIntent != null) {
    printPaymentData.paymentIntent = paymentIntent;
  }
  final dynamic paymentLink = jsonConvert.convert<dynamic>(json['payment_link']);
  if (paymentLink != null) {
    printPaymentData.paymentLink = paymentLink;
  }
  final String? paymentMethodCollection = jsonConvert.convert<String>(json['payment_method_collection']);
  if (paymentMethodCollection != null) {
    printPaymentData.paymentMethodCollection = paymentMethodCollection;
  }
  final PrintPaymentDataPaymentMethodOptions? paymentMethodOptions = jsonConvert.convert<PrintPaymentDataPaymentMethodOptions>(json['payment_method_options']);
  if (paymentMethodOptions != null) {
    printPaymentData.paymentMethodOptions = paymentMethodOptions;
  }
  final List<String>? paymentMethodTypes = jsonConvert.convertListNotNull<String>(json['payment_method_types']);
  if (paymentMethodTypes != null) {
    printPaymentData.paymentMethodTypes = paymentMethodTypes;
  }
  final String? paymentStatus = jsonConvert.convert<String>(json['payment_status']);
  if (paymentStatus != null) {
    printPaymentData.paymentStatus = paymentStatus;
  }
  final PrintPaymentDataPhoneNumberCollection? phoneNumberCollection = jsonConvert.convert<PrintPaymentDataPhoneNumberCollection>(json['phone_number_collection']);
  if (phoneNumberCollection != null) {
    printPaymentData.phoneNumberCollection = phoneNumberCollection;
  }
  final dynamic recoveredFrom = jsonConvert.convert<dynamic>(json['recovered_from']);
  if (recoveredFrom != null) {
    printPaymentData.recoveredFrom = recoveredFrom;
  }
  final dynamic setupIntent = jsonConvert.convert<dynamic>(json['setup_intent']);
  if (setupIntent != null) {
    printPaymentData.setupIntent = setupIntent;
  }
  final dynamic shipping = jsonConvert.convert<dynamic>(json['shipping']);
  if (shipping != null) {
    printPaymentData.shipping = shipping;
  }
  final dynamic shippingAddressCollection = jsonConvert.convert<dynamic>(json['shipping_address_collection']);
  if (shippingAddressCollection != null) {
    printPaymentData.shippingAddressCollection = shippingAddressCollection;
  }
  final List<PrintPaymentDataShippingOptions>? shippingOptions = jsonConvert.convertListNotNull<PrintPaymentDataShippingOptions>(json['shipping_options']);
  if (shippingOptions != null) {
    printPaymentData.shippingOptions = shippingOptions;
  }
  final dynamic shippingRate = jsonConvert.convert<dynamic>(json['shipping_rate']);
  if (shippingRate != null) {
    printPaymentData.shippingRate = shippingRate;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    printPaymentData.status = status;
  }
  final dynamic submitType = jsonConvert.convert<dynamic>(json['submit_type']);
  if (submitType != null) {
    printPaymentData.submitType = submitType;
  }
  final dynamic subscription = jsonConvert.convert<dynamic>(json['subscription']);
  if (subscription != null) {
    printPaymentData.subscription = subscription;
  }
  final String? successUrl = jsonConvert.convert<String>(json['success_url']);
  if (successUrl != null) {
    printPaymentData.successUrl = successUrl;
  }
  final PrintPaymentDataTotalDetails? totalDetails = jsonConvert.convert<PrintPaymentDataTotalDetails>(json['total_details']);
  if (totalDetails != null) {
    printPaymentData.totalDetails = totalDetails;
  }
  final String? url = jsonConvert.convert<String>(json['url']);
  if (url != null) {
    printPaymentData.url = url;
  }
  return printPaymentData;
}

Map<String, dynamic> $PrintPaymentDataToJson(PrintPaymentData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['object'] = entity.object;
  data['after_expiration'] = entity.afterExpiration;
  data['allow_promotion_codes'] = entity.allowPromotionCodes;
  data['amount_subtotal'] = entity.amountSubtotal;
  data['amount_total'] = entity.amountTotal;
  data['automatic_tax'] = entity.automaticTax.toJson();
  data['billing_address_collection'] = entity.billingAddressCollection;
  data['cancel_url'] = entity.cancelUrl;
  data['client_reference_id'] = entity.clientReferenceId;
  data['consent'] = entity.consent;
  data['consent_collection'] = entity.consentCollection;
  data['created'] = entity.created;
  data['currency'] = entity.currency;
  data['currency_conversion'] = entity.currencyConversion;
  data['custom_fields'] = entity.customFields;
  data['custom_text'] = entity.customText.toJson();
  data['customer'] = entity.customer;
  data['customer_creation'] = entity.customerCreation;
  data['customer_details'] = entity.customerDetails;
  data['customer_email'] = entity.customerEmail;
  data['expires_at'] = entity.expiresAt;
  data['invoice'] = entity.invoice;
  data['invoice_creation'] = entity.invoiceCreation.toJson();
  data['livemode'] = entity.livemode;
  data['locale'] = entity.locale;
  data['metadata'] = entity.metadata.toJson();
  data['mode'] = entity.mode;
  data['payment_intent'] = entity.paymentIntent;
  data['payment_link'] = entity.paymentLink;
  data['payment_method_collection'] = entity.paymentMethodCollection;
  data['payment_method_options'] = entity.paymentMethodOptions.toJson();
  data['payment_method_types'] = entity.paymentMethodTypes;
  data['payment_status'] = entity.paymentStatus;
  data['phone_number_collection'] = entity.phoneNumberCollection.toJson();
  data['recovered_from'] = entity.recoveredFrom;
  data['setup_intent'] = entity.setupIntent;
  data['shipping'] = entity.shipping;
  data['shipping_address_collection'] = entity.shippingAddressCollection;
  data['shipping_options'] = entity.shippingOptions.map((v) => v.toJson()).toList();
  data['shipping_rate'] = entity.shippingRate;
  data['status'] = entity.status;
  data['submit_type'] = entity.submitType;
  data['subscription'] = entity.subscription;
  data['success_url'] = entity.successUrl;
  data['total_details'] = entity.totalDetails.toJson();
  data['url'] = entity.url;
  return data;
}

PrintPaymentDataAutomaticTax $PrintPaymentDataAutomaticTaxFromJson(Map<String, dynamic> json) {
  final PrintPaymentDataAutomaticTax printPaymentDataAutomaticTax = PrintPaymentDataAutomaticTax();
  final bool? enabled = jsonConvert.convert<bool>(json['enabled']);
  if (enabled != null) {
    printPaymentDataAutomaticTax.enabled = enabled;
  }
  final dynamic status = jsonConvert.convert<dynamic>(json['status']);
  if (status != null) {
    printPaymentDataAutomaticTax.status = status;
  }
  return printPaymentDataAutomaticTax;
}

Map<String, dynamic> $PrintPaymentDataAutomaticTaxToJson(PrintPaymentDataAutomaticTax entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['enabled'] = entity.enabled;
  data['status'] = entity.status;
  return data;
}

PrintPaymentDataCustomText $PrintPaymentDataCustomTextFromJson(Map<String, dynamic> json) {
  final PrintPaymentDataCustomText printPaymentDataCustomText = PrintPaymentDataCustomText();
  final dynamic shippingAddress = jsonConvert.convert<dynamic>(json['shipping_address']);
  if (shippingAddress != null) {
    printPaymentDataCustomText.shippingAddress = shippingAddress;
  }
  final dynamic submit = jsonConvert.convert<dynamic>(json['submit']);
  if (submit != null) {
    printPaymentDataCustomText.submit = submit;
  }
  return printPaymentDataCustomText;
}

Map<String, dynamic> $PrintPaymentDataCustomTextToJson(PrintPaymentDataCustomText entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shipping_address'] = entity.shippingAddress;
  data['submit'] = entity.submit;
  return data;
}

PrintPaymentDataInvoiceCreation $PrintPaymentDataInvoiceCreationFromJson(Map<String, dynamic> json) {
  final PrintPaymentDataInvoiceCreation printPaymentDataInvoiceCreation = PrintPaymentDataInvoiceCreation();
  final bool? enabled = jsonConvert.convert<bool>(json['enabled']);
  if (enabled != null) {
    printPaymentDataInvoiceCreation.enabled = enabled;
  }
  final PrintPaymentDataInvoiceCreationInvoiceData? invoiceData = jsonConvert.convert<PrintPaymentDataInvoiceCreationInvoiceData>(json['invoice_data']);
  if (invoiceData != null) {
    printPaymentDataInvoiceCreation.invoiceData = invoiceData;
  }
  return printPaymentDataInvoiceCreation;
}

Map<String, dynamic> $PrintPaymentDataInvoiceCreationToJson(PrintPaymentDataInvoiceCreation entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['enabled'] = entity.enabled;
  data['invoice_data'] = entity.invoiceData.toJson();
  return data;
}

PrintPaymentDataInvoiceCreationInvoiceData $PrintPaymentDataInvoiceCreationInvoiceDataFromJson(Map<String, dynamic> json) {
  final PrintPaymentDataInvoiceCreationInvoiceData printPaymentDataInvoiceCreationInvoiceData = PrintPaymentDataInvoiceCreationInvoiceData();
  final dynamic accountTaxIds = jsonConvert.convert<dynamic>(json['account_tax_ids']);
  if (accountTaxIds != null) {
    printPaymentDataInvoiceCreationInvoiceData.accountTaxIds = accountTaxIds;
  }
  final dynamic customFields = jsonConvert.convert<dynamic>(json['custom_fields']);
  if (customFields != null) {
    printPaymentDataInvoiceCreationInvoiceData.customFields = customFields;
  }
  final dynamic description = jsonConvert.convert<dynamic>(json['description']);
  if (description != null) {
    printPaymentDataInvoiceCreationInvoiceData.description = description;
  }
  final dynamic footer = jsonConvert.convert<dynamic>(json['footer']);
  if (footer != null) {
    printPaymentDataInvoiceCreationInvoiceData.footer = footer;
  }
  final PrintPaymentDataInvoiceCreationInvoiceDataMetadata? metadata = jsonConvert.convert<PrintPaymentDataInvoiceCreationInvoiceDataMetadata>(json['metadata']);
  if (metadata != null) {
    printPaymentDataInvoiceCreationInvoiceData.metadata = metadata;
  }
  final dynamic renderingOptions = jsonConvert.convert<dynamic>(json['rendering_options']);
  if (renderingOptions != null) {
    printPaymentDataInvoiceCreationInvoiceData.renderingOptions = renderingOptions;
  }
  return printPaymentDataInvoiceCreationInvoiceData;
}

Map<String, dynamic> $PrintPaymentDataInvoiceCreationInvoiceDataToJson(PrintPaymentDataInvoiceCreationInvoiceData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['account_tax_ids'] = entity.accountTaxIds;
  data['custom_fields'] = entity.customFields;
  data['description'] = entity.description;
  data['footer'] = entity.footer;
  data['metadata'] = entity.metadata.toJson();
  data['rendering_options'] = entity.renderingOptions;
  return data;
}

PrintPaymentDataInvoiceCreationInvoiceDataMetadata $PrintPaymentDataInvoiceCreationInvoiceDataMetadataFromJson(Map<String, dynamic> json) {
  final PrintPaymentDataInvoiceCreationInvoiceDataMetadata printPaymentDataInvoiceCreationInvoiceDataMetadata = PrintPaymentDataInvoiceCreationInvoiceDataMetadata();
  return printPaymentDataInvoiceCreationInvoiceDataMetadata;
}

Map<String, dynamic> $PrintPaymentDataInvoiceCreationInvoiceDataMetadataToJson(PrintPaymentDataInvoiceCreationInvoiceDataMetadata entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  return data;
}

PrintPaymentDataMetadata $PrintPaymentDataMetadataFromJson(Map<String, dynamic> json) {
  final PrintPaymentDataMetadata printPaymentDataMetadata = PrintPaymentDataMetadata();
  return printPaymentDataMetadata;
}

Map<String, dynamic> $PrintPaymentDataMetadataToJson(PrintPaymentDataMetadata entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  return data;
}

PrintPaymentDataPaymentMethodOptions $PrintPaymentDataPaymentMethodOptionsFromJson(Map<String, dynamic> json) {
  final PrintPaymentDataPaymentMethodOptions printPaymentDataPaymentMethodOptions = PrintPaymentDataPaymentMethodOptions();
  return printPaymentDataPaymentMethodOptions;
}

Map<String, dynamic> $PrintPaymentDataPaymentMethodOptionsToJson(PrintPaymentDataPaymentMethodOptions entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  return data;
}

PrintPaymentDataPhoneNumberCollection $PrintPaymentDataPhoneNumberCollectionFromJson(Map<String, dynamic> json) {
  final PrintPaymentDataPhoneNumberCollection printPaymentDataPhoneNumberCollection = PrintPaymentDataPhoneNumberCollection();
  final bool? enabled = jsonConvert.convert<bool>(json['enabled']);
  if (enabled != null) {
    printPaymentDataPhoneNumberCollection.enabled = enabled;
  }
  return printPaymentDataPhoneNumberCollection;
}

Map<String, dynamic> $PrintPaymentDataPhoneNumberCollectionToJson(PrintPaymentDataPhoneNumberCollection entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['enabled'] = entity.enabled;
  return data;
}

PrintPaymentDataShippingOptions $PrintPaymentDataShippingOptionsFromJson(Map<String, dynamic> json) {
  final PrintPaymentDataShippingOptions printPaymentDataShippingOptions = PrintPaymentDataShippingOptions();
  final int? shippingAmount = jsonConvert.convert<int>(json['shipping_amount']);
  if (shippingAmount != null) {
    printPaymentDataShippingOptions.shippingAmount = shippingAmount;
  }
  final String? shippingRate = jsonConvert.convert<String>(json['shipping_rate']);
  if (shippingRate != null) {
    printPaymentDataShippingOptions.shippingRate = shippingRate;
  }
  return printPaymentDataShippingOptions;
}

Map<String, dynamic> $PrintPaymentDataShippingOptionsToJson(PrintPaymentDataShippingOptions entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shipping_amount'] = entity.shippingAmount;
  data['shipping_rate'] = entity.shippingRate;
  return data;
}

PrintPaymentDataTotalDetails $PrintPaymentDataTotalDetailsFromJson(Map<String, dynamic> json) {
  final PrintPaymentDataTotalDetails printPaymentDataTotalDetails = PrintPaymentDataTotalDetails();
  final int? amountDiscount = jsonConvert.convert<int>(json['amount_discount']);
  if (amountDiscount != null) {
    printPaymentDataTotalDetails.amountDiscount = amountDiscount;
  }
  final int? amountShipping = jsonConvert.convert<int>(json['amount_shipping']);
  if (amountShipping != null) {
    printPaymentDataTotalDetails.amountShipping = amountShipping;
  }
  final int? amountTax = jsonConvert.convert<int>(json['amount_tax']);
  if (amountTax != null) {
    printPaymentDataTotalDetails.amountTax = amountTax;
  }
  return printPaymentDataTotalDetails;
}

Map<String, dynamic> $PrintPaymentDataTotalDetailsToJson(PrintPaymentDataTotalDetails entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount_discount'] = entity.amountDiscount;
  data['amount_shipping'] = entity.amountShipping;
  data['amount_tax'] = entity.amountTax;
  return data;
}
