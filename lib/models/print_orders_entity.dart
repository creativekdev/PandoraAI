import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/print_orders_entity.g.dart';

@JsonSerializable()
class PrintOrdersEntity {
  late PrintOrdersData data;

  PrintOrdersEntity();

  factory PrintOrdersEntity.fromJson(Map<String, dynamic> json) => $PrintOrdersEntityFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersData {
  late List<PrintOrdersDataRows> rows;
  late int records;
  late int total;
  late int page;

  PrintOrdersData();

  factory PrintOrdersData.fromJson(Map<String, dynamic> json) => $PrintOrdersDataFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRows {
  @JSONField(name: "user_id")
  late int userId;
  late int price;
  @JSONField(name: "total_price")
  late double totalPrice;
  @JSONField(name: "event_time")
  late String eventTime;
  late String payload;
  @JSONField(name: "shopify_order_id")
  late String shopifyOrderId;
  @JSONField(name: "stripe_session_id")
  dynamic stripeSessionId;
  @JSONField(name: "financial_status")
  late String financialStatus;
  @JSONField(name: "fulfillment_status")
  dynamic fulfillmentStatus;
  @JSONField(name: "user_canva_resource_id")
  dynamic userCanvaResourceId;
  @JSONField(name: "ps_image")
  late String psImage;
  @JSONField(name: "ps_preview_image")
  late String psPreviewImage;
  @JSONField(name: "shipping_method")
  late String shippingMethod;
  @JSONField(name: "shipping_price")
  dynamic shippingPrice;
  late String name;
  late String created;
  late String modified;
  late int id;

  PrintOrdersDataRows();

  factory PrintOrdersDataRows.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayload {
  late PrintOrdersDataRowsPayloadOrder order;
  late PrintOrdersDataRowsPayloadRepay repay;

  PrintOrdersDataRowsPayload();

  factory PrintOrdersDataRowsPayload.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrder {
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
  late PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSet currentSubtotalPriceSet;
  @JSONField(name: "current_total_discounts")
  late String currentTotalDiscounts;
  @JSONField(name: "current_total_discounts_set")
  late PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSet currentTotalDiscountsSet;
  @JSONField(name: "current_total_duties_set")
  dynamic currentTotalDutiesSet;
  @JSONField(name: "current_total_price")
  late String currentTotalPrice;
  @JSONField(name: "current_total_price_set")
  late PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSet currentTotalPriceSet;
  @JSONField(name: "current_total_tax")
  late String currentTotalTax;
  @JSONField(name: "current_total_tax_set")
  late PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSet currentTotalTaxSet;
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
  late PrintOrdersDataRowsPayloadOrderSubtotalPriceSet subtotalPriceSet;
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
  late PrintOrdersDataRowsPayloadOrderTotalDiscountsSet totalDiscountsSet;
  @JSONField(name: "total_line_items_price")
  late String totalLineItemsPrice;
  @JSONField(name: "total_line_items_price_set")
  late PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSet totalLineItemsPriceSet;
  @JSONField(name: "total_outstanding")
  late String totalOutstanding;
  @JSONField(name: "total_price")
  late String totalPrice;
  @JSONField(name: "total_price_set")
  late PrintOrdersDataRowsPayloadOrderTotalPriceSet totalPriceSet;
  @JSONField(name: "total_price_usd")
  late String totalPriceUsd;
  @JSONField(name: "total_shipping_price_set")
  late PrintOrdersDataRowsPayloadOrderTotalShippingPriceSet totalShippingPriceSet;
  @JSONField(name: "total_tax")
  late String totalTax;
  @JSONField(name: "total_tax_set")
  late PrintOrdersDataRowsPayloadOrderTotalTaxSet totalTaxSet;
  @JSONField(name: "total_tip_received")
  late String totalTipReceived;
  @JSONField(name: "total_weight")
  late int totalWeight;
  @JSONField(name: "updated_at")
  late String updatedAt;
  @JSONField(name: "user_id")
  dynamic userId;
  late PrintOrdersDataRowsPayloadOrderCustomer customer;
  @JSONField(name: "discount_applications")
  late List<dynamic> discountApplications;
  late List<dynamic> fulfillments;
  @JSONField(name: "line_items")
  late List<PrintOrdersDataRowsPayloadOrderLineItems> lineItems;
  @JSONField(name: "payment_terms")
  dynamic paymentTerms;
  late List<dynamic> refunds;
  @JSONField(name: "shipping_lines")
  late List<dynamic> shippingLines;

  PrintOrdersDataRowsPayloadOrder();

  factory PrintOrdersDataRowsPayloadOrder.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSet {
  @JSONField(name: "shop_money")
  late PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoney presentmentMoney;

  PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSet();

  factory PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSet.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoney();

  factory PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoney();

  factory PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSet {
  @JSONField(name: "shop_money")
  late PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoney presentmentMoney;

  PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSet();

  factory PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSet.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoney();

  factory PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoney();

  factory PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSet {
  @JSONField(name: "shop_money")
  late PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoney presentmentMoney;

  PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSet();

  factory PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSet.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoney();

  factory PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoney();

  factory PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSet {
  @JSONField(name: "shop_money")
  late PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoney presentmentMoney;

  PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSet();

  factory PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSet.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoney();

  factory PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoney();

  factory PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderSubtotalPriceSet {
  @JSONField(name: "shop_money")
  late PrintOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoney presentmentMoney;

  PrintOrdersDataRowsPayloadOrderSubtotalPriceSet();

  factory PrintOrdersDataRowsPayloadOrderSubtotalPriceSet.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderSubtotalPriceSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderSubtotalPriceSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoney();

  factory PrintOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoney.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoney();

  factory PrintOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderTotalDiscountsSet {
  @JSONField(name: "shop_money")
  late PrintOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoney presentmentMoney;

  PrintOrdersDataRowsPayloadOrderTotalDiscountsSet();

  factory PrintOrdersDataRowsPayloadOrderTotalDiscountsSet.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderTotalDiscountsSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderTotalDiscountsSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoney();

  factory PrintOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoney.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoney();

  factory PrintOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSet {
  @JSONField(name: "shop_money")
  late PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoney presentmentMoney;

  PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSet();

  factory PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSet.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoney();

  factory PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoney();

  factory PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderTotalPriceSet {
  @JSONField(name: "shop_money")
  late PrintOrdersDataRowsPayloadOrderTotalPriceSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoney presentmentMoney;

  PrintOrdersDataRowsPayloadOrderTotalPriceSet();

  factory PrintOrdersDataRowsPayloadOrderTotalPriceSet.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderTotalPriceSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderTotalPriceSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderTotalPriceSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderTotalPriceSetShopMoney();

  factory PrintOrdersDataRowsPayloadOrderTotalPriceSetShopMoney.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderTotalPriceSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderTotalPriceSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoney();

  factory PrintOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderTotalShippingPriceSet {
  @JSONField(name: "shop_money")
  late PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoney presentmentMoney;

  PrintOrdersDataRowsPayloadOrderTotalShippingPriceSet();

  factory PrintOrdersDataRowsPayloadOrderTotalShippingPriceSet.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoney();

  factory PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoney();

  factory PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderTotalTaxSet {
  @JSONField(name: "shop_money")
  late PrintOrdersDataRowsPayloadOrderTotalTaxSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoney presentmentMoney;

  PrintOrdersDataRowsPayloadOrderTotalTaxSet();

  factory PrintOrdersDataRowsPayloadOrderTotalTaxSet.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderTotalTaxSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderTotalTaxSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderTotalTaxSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderTotalTaxSetShopMoney();

  factory PrintOrdersDataRowsPayloadOrderTotalTaxSetShopMoney.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderTotalTaxSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderTotalTaxSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoney();

  factory PrintOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderCustomer {
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
  late PrintOrdersDataRowsPayloadOrderCustomerDefaultAddress defaultAddress;

  PrintOrdersDataRowsPayloadOrderCustomer();

  factory PrintOrdersDataRowsPayloadOrderCustomer.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderCustomerFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderCustomerToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderCustomerDefaultAddress {
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

  PrintOrdersDataRowsPayloadOrderCustomerDefaultAddress();

  factory PrintOrdersDataRowsPayloadOrderCustomerDefaultAddress.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderCustomerDefaultAddressFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderCustomerDefaultAddressToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderLineItems {
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
  late PrintOrdersDataRowsPayloadOrderLineItemsPriceSet priceSet;
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
  late PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSet totalDiscountSet;
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

  PrintOrdersDataRowsPayloadOrderLineItems();

  factory PrintOrdersDataRowsPayloadOrderLineItems.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderLineItemsFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderLineItemsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderLineItemsPriceSet {
  @JSONField(name: "shop_money")
  late PrintOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoney presentmentMoney;

  PrintOrdersDataRowsPayloadOrderLineItemsPriceSet();

  factory PrintOrdersDataRowsPayloadOrderLineItemsPriceSet.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderLineItemsPriceSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderLineItemsPriceSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoney();

  factory PrintOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoney.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoney();

  factory PrintOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSet {
  @JSONField(name: "shop_money")
  late PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoney shopMoney;
  @JSONField(name: "presentment_money")
  late PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoney presentmentMoney;

  PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSet();

  factory PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSet.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoney();

  factory PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoney {
  late String amount;
  @JSONField(name: "currency_code")
  late String currencyCode;

  PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoney();

  factory PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoney.fromJson(Map<String, dynamic> json) =>
      $PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoneyFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoneyToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadRepay {
  late PrintOrdersDataRowsPayloadRepayProductInfo productInfo;
  late PrintOrdersDataRowsPayloadRepayCustomer customer;
  late PrintOrdersDataRowsPayloadRepayDelivery delivery;
  late String image;

  PrintOrdersDataRowsPayloadRepay();

  factory PrintOrdersDataRowsPayloadRepay.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadRepayFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadRepayToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadRepayProductInfo {
  late String name;
  late int quantity;
  late String desc;
  late int price;

  PrintOrdersDataRowsPayloadRepayProductInfo();

  factory PrintOrdersDataRowsPayloadRepayProductInfo.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadRepayProductInfoFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadRepayProductInfoToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadRepayCustomer {
  late String phone;
  @JSONField(name: "first_name")
  late String firstName;
  @JSONField(name: "last_name")
  late String lastName;
  late List<PrintOrdersDataRowsPayloadRepayCustomerAddresses> addresses;

  PrintOrdersDataRowsPayloadRepayCustomer();

  factory PrintOrdersDataRowsPayloadRepayCustomer.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadRepayCustomerFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadRepayCustomerToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadRepayCustomerAddresses {
  @JSONField(name: "first_name")
  late String firstName;
  @JSONField(name: "last_name")
  late String lastName;
  late String phone;
  @JSONField(name: "country_code")
  dynamic countryCode;
  @JSONField(name: "country_name")
  dynamic countryName;
  dynamic country;
  late String address1;
  late String address2;

  PrintOrdersDataRowsPayloadRepayCustomerAddresses();

  factory PrintOrdersDataRowsPayloadRepayCustomerAddresses.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadRepayCustomerAddressesFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadRepayCustomerAddressesToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadRepayDelivery {
  late String type;
  @JSONField(name: "fixed_amount")
  late PrintOrdersDataRowsPayloadRepayDeliveryFixedAmount fixedAmount;
  @JSONField(name: "display_name")
  late String displayName;

  PrintOrdersDataRowsPayloadRepayDelivery();

  factory PrintOrdersDataRowsPayloadRepayDelivery.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadRepayDeliveryFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadRepayDeliveryToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOrdersDataRowsPayloadRepayDeliveryFixedAmount {
  late int amount;
  late String currency;

  PrintOrdersDataRowsPayloadRepayDeliveryFixedAmount();

  factory PrintOrdersDataRowsPayloadRepayDeliveryFixedAmount.fromJson(Map<String, dynamic> json) => $PrintOrdersDataRowsPayloadRepayDeliveryFixedAmountFromJson(json);

  Map<String, dynamic> toJson() => $PrintOrdersDataRowsPayloadRepayDeliveryFixedAmountToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
