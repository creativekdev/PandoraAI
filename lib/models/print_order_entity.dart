import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/print_order_entity.g.dart';
import 'package:cartoonizer/models/print_orders_entity.dart';

@JsonSerializable()
class PrintOrderEntity {
  late PrintOrderData data;

  PrintOrderEntity();

  factory PrintOrderEntity.fromJson(Map<String, dynamic> json) => $PrintOrderEntityFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderData {
  @JSONField(name: "user_id")
  late int userId;
  late int price;
  @JSONField(name: "total_price")
  late double totalPrice;
  @JSONField(name: "event_time")
  late int eventTime;
  late String payload;
  @JSONField(name: "shopify_order_id")
  late int shopifyOrderId;
  @JSONField(name: "stripe_session_id")
  dynamic stripeSessionId;
  @JSONField(name: "financial_status")
  late String financialStatus;
  @JSONField(name: "fulfillment_status")
  dynamic fulfillmentStatus;
  @JSONField(name: "ps_image")
  late String psImage;
  @JSONField(name: "ps_preview_image")
  late String psPreviewImage;
  @JSONField(name: "shipping_method")
  late String shippingMethod;
  late String name;
  late String created;
  late String modified;
  late int id;

  PrintOrderData();

  factory PrintOrderData.fromJson(Map<String, dynamic> json) => $PrintOrderDataFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayload {
  late PrintOrderDataPayloadOrder order;
  late PrintOrdersDataRowsPayloadRepay repay;

  PrintOrderDataPayload();

  factory PrintOrderDataPayload.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrder {
  late int id;
  @JSONField(name: "admin_graphql_api_id")
  late String adminGraphqlApiId;
  @JSONField(name: "app_id")
  late int appId;
  @JSONField(name: "browser_ip")
  dynamic browserIp;
  @JSONField(name: "buyer_accepts_marketing")
  late bool buyerAcceptsMarketing;
  @JSONField(name: "cancel_reason")
  dynamic cancelReason;
  @JSONField(name: "cancelled_at")
  dynamic cancelledAt;
  @JSONField(name: "cart_token")
  dynamic cartToken;
  @JSONField(name: "checkout_id")
  dynamic checkoutId;
  @JSONField(name: "checkout_token")
  dynamic checkoutToken;
  @JSONField(name: "closed_at")
  dynamic closedAt;
  late bool confirmed;
  @JSONField(name: "contact_email")
  dynamic contactEmail;
  @JSONField(name: "created_at")
  late String createdAt;
  late String currency;
  @JSONField(name: "current_subtotal_price")
  late String currentSubtotalPrice;
  @JSONField(name: "current_subtotal_price_set")
  late PrintOrderDataPayloadOrderCurrentSubtotalPriceSet currentSubtotalPriceSet;
  @JSONField(name: "current_total_discounts")
  late String currentTotalDiscounts;
  @JSONField(name: "current_total_discounts_set")
  late PrintOrderDataPayloadOrderCurrentTotalDiscountsSet currentTotalDiscountsSet;
  @JSONField(name: "current_total_duties_set")
  dynamic currentTotalDutiesSet;
  @JSONField(name: "current_total_price")
  late String currentTotalPrice;
  @JSONField(name: "current_total_price_set")
  late PrintOrderDataPayloadOrderCurrentTotalPriceSet currentTotalPriceSet;
  @JSONField(name: "current_total_tax")
  late String currentTotalTax;
  @JSONField(name: "current_total_tax_set")
  late PrintOrderDataPayloadOrderCurrentTotalTaxSet currentTotalTaxSet;
  @JSONField(name: "customer_locale")
  dynamic customerLocale;
  @JSONField(name: "device_id")
  dynamic deviceId;
  @JSONField(name: "discount_codes")
  late List<dynamic> discountCodes;
  late String email;
  @JSONField(name: "estimated_taxes")
  late bool estimatedTaxes;
  @JSONField(name: "financial_status")
  late String financialStatus;
  @JSONField(name: "fulfillment_status")
  dynamic fulfillmentStatus;
  late String gateway;
  @JSONField(name: "landing_site")
  dynamic landingSite;
  @JSONField(name: "landing_site_ref")
  dynamic landingSiteRef;
  @JSONField(name: "location_id")
  dynamic locationId;
  late String name;
  late String note;
  @JSONField(name: "note_attributes")
  late List<dynamic> noteAttributes;
  late int number;
  @JSONField(name: "order_number")
  late int orderNumber;
  @JSONField(name: "order_status_url")
  late String orderStatusUrl;
  @JSONField(name: "original_total_duties_set")
  dynamic originalTotalDutiesSet;
  @JSONField(name: "payment_gateway_names")
  late List<dynamic> paymentGatewayNames;
  dynamic phone;
  @JSONField(name: "presentment_currency")
  late String presentmentCurrency;
  @JSONField(name: "processed_at")
  late String processedAt;
  @JSONField(name: "processing_method")
  late String processingMethod;
  dynamic reference;
  @JSONField(name: "referring_site")
  dynamic referringSite;
  @JSONField(name: "source_identifier")
  dynamic sourceIdentifier;
  @JSONField(name: "source_name")
  late String sourceName;
  @JSONField(name: "source_url")
  dynamic sourceUrl;
  @JSONField(name: "subtotal_price")
  late String subtotalPrice;
  @JSONField(name: "subtotal_price_set")
  late PrintOrderDataPayloadOrderSubtotalPriceSet subtotalPriceSet;
  late String tags;
  @JSONField(name: "tax_lines")
  late List<dynamic> taxLines;
  @JSONField(name: "taxes_included")
  late bool taxesIncluded;
  late bool test;
  late String token;
  @JSONField(name: "total_discounts")
  late String totalDiscounts;
  @JSONField(name: "total_discounts_set")
  late PrintOrderDataPayloadOrderTotalDiscountsSet totalDiscountsSet;
  @JSONField(name: "total_line_items_price")
  late String totalLineItemsPrice;
  @JSONField(name: "total_line_items_price_set")
  late PrintOrderDataPayloadOrderTotalLineItemsPriceSet totalLineItemsPriceSet;
  @JSONField(name: "total_outstanding")
  late String totalOutstanding;
  @JSONField(name: "total_price")
  late String totalPrice;
  @JSONField(name: "total_price_set")
  late PrintOrderDataPayloadOrderTotalPriceSet totalPriceSet;
  @JSONField(name: "total_price_usd")
  late String totalPriceUsd;
  @JSONField(name: "total_shipping_price_set")
  late PrintOrderDataPayloadOrderTotalShippingPriceSet totalShippingPriceSet;
  @JSONField(name: "total_tax")
  late String totalTax;
  @JSONField(name: "total_tax_set")
  late PrintOrderDataPayloadOrderTotalTaxSet totalTaxSet;
  @JSONField(name: "total_tip_received")
  late String totalTipReceived;
  @JSONField(name: "total_weight")
  late int totalWeight;
  @JSONField(name: "updated_at")
  late String updatedAt;
  @JSONField(name: "user_id")
  dynamic userId;
  late PrintOrderDataPayloadOrderCustomer customer;
  @JSONField(name: "discount_applications")
  late List<dynamic> discountApplications;
  late List<dynamic> fulfillments;
  @JSONField(name: "line_items")
  late List<PrintOrderDataPayloadOrderLineItems> lineItems;
  @JSONField(name: "payment_terms")
  dynamic paymentTerms;
  late List<dynamic> refunds;
  @JSONField(name: "shipping_lines")
  late List<dynamic> shippingLines;

  PrintOrderDataPayloadOrder();

  factory PrintOrderDataPayloadOrder.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderCurrentSubtotalPriceSet {
  @JSONField(name: "shop_money")
  late PrintOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoney presentmentMoney;

  PrintOrderDataPayloadOrderCurrentSubtotalPriceSet();

  factory PrintOrderDataPayloadOrderCurrentSubtotalPriceSet.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderCurrentSubtotalPriceSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderCurrentSubtotalPriceSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoney();

  factory PrintOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoney();

  factory PrintOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderCurrentTotalDiscountsSet {
  @JSONField(name: "shop_money")
  late PrintOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoney presentmentMoney;

  PrintOrderDataPayloadOrderCurrentTotalDiscountsSet();

  factory PrintOrderDataPayloadOrderCurrentTotalDiscountsSet.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderCurrentTotalDiscountsSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderCurrentTotalDiscountsSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoney();

  factory PrintOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoney();

  factory PrintOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderCurrentTotalPriceSet {
  @JSONField(name: "shop_money")
  late PrintOrderDataPayloadOrderCurrentTotalPriceSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoney presentmentMoney;

  PrintOrderDataPayloadOrderCurrentTotalPriceSet();

  factory PrintOrderDataPayloadOrderCurrentTotalPriceSet.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderCurrentTotalPriceSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderCurrentTotalPriceSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderCurrentTotalPriceSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderCurrentTotalPriceSetShopMoney();

  factory PrintOrderDataPayloadOrderCurrentTotalPriceSetShopMoney.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderCurrentTotalPriceSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderCurrentTotalPriceSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoney();

  factory PrintOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderCurrentTotalTaxSet {
  @JSONField(name: "shop_money")
  late PrintOrderDataPayloadOrderCurrentTotalTaxSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoney presentmentMoney;

  PrintOrderDataPayloadOrderCurrentTotalTaxSet();

  factory PrintOrderDataPayloadOrderCurrentTotalTaxSet.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderCurrentTotalTaxSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderCurrentTotalTaxSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderCurrentTotalTaxSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderCurrentTotalTaxSetShopMoney();

  factory PrintOrderDataPayloadOrderCurrentTotalTaxSetShopMoney.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderCurrentTotalTaxSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderCurrentTotalTaxSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoney();

  factory PrintOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderSubtotalPriceSet {
  @JSONField(name: "shop_money")
  late PrintOrderDataPayloadOrderSubtotalPriceSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrderDataPayloadOrderSubtotalPriceSetPresentmentMoney presentmentMoney;

  PrintOrderDataPayloadOrderSubtotalPriceSet();

  factory PrintOrderDataPayloadOrderSubtotalPriceSet.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderSubtotalPriceSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderSubtotalPriceSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderSubtotalPriceSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderSubtotalPriceSetShopMoney();

  factory PrintOrderDataPayloadOrderSubtotalPriceSetShopMoney.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderSubtotalPriceSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderSubtotalPriceSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderSubtotalPriceSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderSubtotalPriceSetPresentmentMoney();

  factory PrintOrderDataPayloadOrderSubtotalPriceSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrderDataPayloadOrderSubtotalPriceSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderSubtotalPriceSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderTotalDiscountsSet {
  @JSONField(name: "shop_money")
  late PrintOrderDataPayloadOrderTotalDiscountsSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrderDataPayloadOrderTotalDiscountsSetPresentmentMoney presentmentMoney;

  PrintOrderDataPayloadOrderTotalDiscountsSet();

  factory PrintOrderDataPayloadOrderTotalDiscountsSet.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderTotalDiscountsSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderTotalDiscountsSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderTotalDiscountsSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderTotalDiscountsSetShopMoney();

  factory PrintOrderDataPayloadOrderTotalDiscountsSetShopMoney.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderTotalDiscountsSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderTotalDiscountsSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderTotalDiscountsSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderTotalDiscountsSetPresentmentMoney();

  factory PrintOrderDataPayloadOrderTotalDiscountsSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrderDataPayloadOrderTotalDiscountsSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderTotalDiscountsSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderTotalLineItemsPriceSet {
  @JSONField(name: "shop_money")
  late PrintOrderDataPayloadOrderTotalLineItemsPriceSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoney presentmentMoney;

  PrintOrderDataPayloadOrderTotalLineItemsPriceSet();

  factory PrintOrderDataPayloadOrderTotalLineItemsPriceSet.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderTotalLineItemsPriceSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderTotalLineItemsPriceSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderTotalLineItemsPriceSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderTotalLineItemsPriceSetShopMoney();

  factory PrintOrderDataPayloadOrderTotalLineItemsPriceSetShopMoney.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderTotalLineItemsPriceSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderTotalLineItemsPriceSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoney();

  factory PrintOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderTotalPriceSet {
  @JSONField(name: "shop_money")
  late PrintOrderDataPayloadOrderTotalPriceSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrderDataPayloadOrderTotalPriceSetPresentmentMoney presentmentMoney;

  PrintOrderDataPayloadOrderTotalPriceSet();

  factory PrintOrderDataPayloadOrderTotalPriceSet.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderTotalPriceSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderTotalPriceSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderTotalPriceSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderTotalPriceSetShopMoney();

  factory PrintOrderDataPayloadOrderTotalPriceSetShopMoney.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderTotalPriceSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderTotalPriceSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderTotalPriceSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderTotalPriceSetPresentmentMoney();

  factory PrintOrderDataPayloadOrderTotalPriceSetPresentmentMoney.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderTotalPriceSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderTotalPriceSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderTotalShippingPriceSet {
  @JSONField(name: "shop_money")
  late PrintOrderDataPayloadOrderTotalShippingPriceSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoney presentmentMoney;

  PrintOrderDataPayloadOrderTotalShippingPriceSet();

  factory PrintOrderDataPayloadOrderTotalShippingPriceSet.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderTotalShippingPriceSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderTotalShippingPriceSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderTotalShippingPriceSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderTotalShippingPriceSetShopMoney();

  factory PrintOrderDataPayloadOrderTotalShippingPriceSetShopMoney.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderTotalShippingPriceSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderTotalShippingPriceSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoney();

  factory PrintOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderTotalTaxSet {
  @JSONField(name: "shop_money")
  late PrintOrderDataPayloadOrderTotalTaxSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrderDataPayloadOrderTotalTaxSetPresentmentMoney presentmentMoney;

  PrintOrderDataPayloadOrderTotalTaxSet();

  factory PrintOrderDataPayloadOrderTotalTaxSet.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderTotalTaxSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderTotalTaxSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderTotalTaxSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderTotalTaxSetShopMoney();

  factory PrintOrderDataPayloadOrderTotalTaxSetShopMoney.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderTotalTaxSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderTotalTaxSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderTotalTaxSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderTotalTaxSetPresentmentMoney();

  factory PrintOrderDataPayloadOrderTotalTaxSetPresentmentMoney.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderTotalTaxSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderTotalTaxSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderCustomer {
  late int id;
  dynamic email;
  @JSONField(name: "accepts_marketing")
  late bool acceptsMarketing;
  @JSONField(name: "created_at")
  late String createdAt;
  @JSONField(name: "updated_at")
  late String updatedAt;
  @JSONField(name: "first_name")
  late String firstName;
  @JSONField(name: "last_name")
  late String lastName;
  late String state;
  dynamic note;
  @JSONField(name: "verified_email")
  late bool verifiedEmail;
  @JSONField(name: "multipass_identifier")
  dynamic multipassIdentifier;
  @JSONField(name: "tax_exempt")
  late bool taxExempt;
  dynamic phone;
  @JSONField(name: "email_marketing_consent")
  dynamic emailMarketingConsent;
  @JSONField(name: "sms_marketing_consent")
  dynamic smsMarketingConsent;
  late String tags;
  late String currency;
  @JSONField(name: "accepts_marketing_updated_at")
  late String acceptsMarketingUpdatedAt;
  @JSONField(name: "marketing_opt_in_level")
  dynamic marketingOptInLevel;
  @JSONField(name: "tax_exemptions")
  late List<dynamic> taxExemptions;
  @JSONField(name: "admin_graphql_api_id")
  late String adminGraphqlApiId;
  @JSONField(name: "default_address")
  late PrintOrderDataPayloadOrderCustomerDefaultAddress defaultAddress;

  PrintOrderDataPayloadOrderCustomer();

  factory PrintOrderDataPayloadOrderCustomer.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderCustomerFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderCustomerToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderCustomerDefaultAddress {
  late int id;
  @JSONField(name: "customer_id")
  late int customerId;
  @JSONField(name: "first_name")
  late String firstName;
  @JSONField(name: "last_name")
  late String lastName;
  dynamic company;
  late String address1;
  late String address2;
  dynamic city;
  dynamic province;
  dynamic country;
  dynamic zip;
  late String phone;
  late String name;
  @JSONField(name: "province_code")
  dynamic provinceCode;
  @JSONField(name: "country_code")
  dynamic countryCode;
  @JSONField(name: "country_name")
  dynamic countryName;
  @JSONField(name: "default")
  late bool xDefault;

  PrintOrderDataPayloadOrderCustomerDefaultAddress();

  factory PrintOrderDataPayloadOrderCustomerDefaultAddress.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderCustomerDefaultAddressFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderCustomerDefaultAddressToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderLineItems {
  late int id;
  @JSONField(name: "admin_graphql_api_id")
  late String adminGraphqlApiId;
  @JSONField(name: "fulfillable_quantity")
  late int fulfillableQuantity;
  @JSONField(name: "fulfillment_service")
  late String fulfillmentService;
  @JSONField(name: "fulfillment_status")
  dynamic fulfillmentStatus;
  @JSONField(name: "gift_card")
  late bool giftCard;
  late int grams;
  late String name;
  late String price;
  @JSONField(name: "price_set")
  late PrintOrderDataPayloadOrderLineItemsPriceSet priceSet;
  @JSONField(name: "product_exists")
  late bool productExists;
  @JSONField(name: "product_id")
  late int productId;
  late List<dynamic> properties;
  late int quantity;
  @JSONField(name: "requires_shipping")
  late bool requiresShipping;
  late String sku;
  late bool taxable;
  late String title;
  @JSONField(name: "total_discount")
  late String totalDiscount;
  @JSONField(name: "total_discount_set")
  late PrintOrderDataPayloadOrderLineItemsTotalDiscountSet totalDiscountSet;
  @JSONField(name: "variant_id")
  late int variantId;
  @JSONField(name: "variant_inventory_management")
  late String variantInventoryManagement;
  @JSONField(name: "variant_title")
  late String variantTitle;
  late String vendor;
  @JSONField(name: "tax_lines")
  late List<dynamic> taxLines;
  late List<dynamic> duties;
  @JSONField(name: "discount_allocations")
  late List<dynamic> discountAllocations;

  PrintOrderDataPayloadOrderLineItems();

  factory PrintOrderDataPayloadOrderLineItems.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderLineItemsFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderLineItemsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderLineItemsPriceSet {
  @JSONField(name: "shop_money")
  late PrintOrderDataPayloadOrderLineItemsPriceSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrderDataPayloadOrderLineItemsPriceSetPresentmentMoney presentmentMoney;

  PrintOrderDataPayloadOrderLineItemsPriceSet();

  factory PrintOrderDataPayloadOrderLineItemsPriceSet.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderLineItemsPriceSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderLineItemsPriceSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderLineItemsPriceSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderLineItemsPriceSetShopMoney();

  factory PrintOrderDataPayloadOrderLineItemsPriceSetShopMoney.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderLineItemsPriceSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderLineItemsPriceSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderLineItemsPriceSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderLineItemsPriceSetPresentmentMoney();

  factory PrintOrderDataPayloadOrderLineItemsPriceSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrderDataPayloadOrderLineItemsPriceSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderLineItemsPriceSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderLineItemsTotalDiscountSet {
  @JSONField(name: "shop_money")
  late PrintOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoney presentmentMoney;

  PrintOrderDataPayloadOrderLineItemsTotalDiscountSet();

  factory PrintOrderDataPayloadOrderLineItemsTotalDiscountSet.fromJson(Map<String, dynamic> json) => $PrintOrderDataPayloadOrderLineItemsTotalDiscountSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderLineItemsTotalDiscountSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoney();

  factory PrintOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoney();

  factory PrintOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
