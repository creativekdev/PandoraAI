import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/print_order_entity.dart';

PrintOrderEntity $PrintOrderEntityFromJson(Map<String, dynamic> json) {
  final PrintOrderEntity printOrderEntity = PrintOrderEntity();
  final PrintOrderData? data = jsonConvert.convert<PrintOrderData>(json['data']);
  if (data != null) {
    printOrderEntity.data = data;
  }
  return printOrderEntity;
}

Map<String, dynamic> $PrintOrderEntityToJson(PrintOrderEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['data'] = entity.data.toJson();
  return data;
}

PrintOrderData $PrintOrderDataFromJson(Map<String, dynamic> json) {
  final PrintOrderData printOrderData = PrintOrderData();
  final int? userId = jsonConvert.convert<int>(json['user_id']);
  if (userId != null) {
    printOrderData.userId = userId;
  }
  final int? price = jsonConvert.convert<int>(json['price']);
  if (price != null) {
    printOrderData.price = price;
  }
  final double? totalPrice = jsonConvert.convert<double>(json['total_price']);
  if (totalPrice != null) {
    printOrderData.totalPrice = totalPrice;
  }
  final int? eventTime = jsonConvert.convert<int>(json['event_time']);
  if (eventTime != null) {
    printOrderData.eventTime = eventTime;
  }
  final String? payload = jsonConvert.convert<String>(json['payload']);
  if (payload != null) {
    printOrderData.payload = payload;
  }
  final int? shopifyOrderId = jsonConvert.convert<int>(json['shopify_order_id']);
  if (shopifyOrderId != null) {
    printOrderData.shopifyOrderId = shopifyOrderId;
  }
  final dynamic stripeSessionId = jsonConvert.convert<dynamic>(json['stripe_session_id']);
  if (stripeSessionId != null) {
    printOrderData.stripeSessionId = stripeSessionId;
  }
  final String? financialStatus = jsonConvert.convert<String>(json['financial_status']);
  if (financialStatus != null) {
    printOrderData.financialStatus = financialStatus;
  }
  final dynamic fulfillmentStatus = jsonConvert.convert<dynamic>(json['fulfillment_status']);
  if (fulfillmentStatus != null) {
    printOrderData.fulfillmentStatus = fulfillmentStatus;
  }
  final String? psImage = jsonConvert.convert<String>(json['ps_image']);
  if (psImage != null) {
    printOrderData.psImage = psImage;
  }
  final String? psPreviewImage = jsonConvert.convert<String>(json['ps_preview_image']);
  if (psPreviewImage != null) {
    printOrderData.psPreviewImage = psPreviewImage;
  }
  final String? shippingMethod = jsonConvert.convert<String>(json['shipping_method']);
  if (shippingMethod != null) {
    printOrderData.shippingMethod = shippingMethod;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    printOrderData.name = name;
  }
  final String? created = jsonConvert.convert<String>(json['created']);
  if (created != null) {
    printOrderData.created = created;
  }
  final String? modified = jsonConvert.convert<String>(json['modified']);
  if (modified != null) {
    printOrderData.modified = modified;
  }
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    printOrderData.id = id;
  }
  return printOrderData;
}

Map<String, dynamic> $PrintOrderDataToJson(PrintOrderData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['user_id'] = entity.userId;
  data['price'] = entity.price;
  data['total_price'] = entity.totalPrice;
  data['event_time'] = entity.eventTime;
  data['payload'] = entity.payload;
  data['shopify_order_id'] = entity.shopifyOrderId;
  data['stripe_session_id'] = entity.stripeSessionId;
  data['financial_status'] = entity.financialStatus;
  data['fulfillment_status'] = entity.fulfillmentStatus;
  data['ps_image'] = entity.psImage;
  data['ps_preview_image'] = entity.psPreviewImage;
  data['shipping_method'] = entity.shippingMethod;
  data['name'] = entity.name;
  data['created'] = entity.created;
  data['modified'] = entity.modified;
  data['id'] = entity.id;
  return data;
}

PrintOrderDataPayload $PrintOrderDataPayloadFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayload printOrderDataPayload = PrintOrderDataPayload();
  final PrintOrderDataPayloadOrder? order = jsonConvert.convert<PrintOrderDataPayloadOrder>(json['order']);
  if (order != null) {
    printOrderDataPayload.order = order;
  }
  return printOrderDataPayload;
}

Map<String, dynamic> $PrintOrderDataPayloadToJson(PrintOrderDataPayload entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['order'] = entity.order.toJson();
  return data;
}

PrintOrderDataPayloadOrder $PrintOrderDataPayloadOrderFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrder printOrderDataPayloadOrder = PrintOrderDataPayloadOrder();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    printOrderDataPayloadOrder.id = id;
  }
  final String? adminGraphqlApiId = jsonConvert.convert<String>(json['admin_graphql_api_id']);
  if (adminGraphqlApiId != null) {
    printOrderDataPayloadOrder.adminGraphqlApiId = adminGraphqlApiId;
  }
  final int? appId = jsonConvert.convert<int>(json['app_id']);
  if (appId != null) {
    printOrderDataPayloadOrder.appId = appId;
  }
  final dynamic browserIp = jsonConvert.convert<dynamic>(json['browser_ip']);
  if (browserIp != null) {
    printOrderDataPayloadOrder.browserIp = browserIp;
  }
  final bool? buyerAcceptsMarketing = jsonConvert.convert<bool>(json['buyer_accepts_marketing']);
  if (buyerAcceptsMarketing != null) {
    printOrderDataPayloadOrder.buyerAcceptsMarketing = buyerAcceptsMarketing;
  }
  final dynamic cancelReason = jsonConvert.convert<dynamic>(json['cancel_reason']);
  if (cancelReason != null) {
    printOrderDataPayloadOrder.cancelReason = cancelReason;
  }
  final dynamic cancelledAt = jsonConvert.convert<dynamic>(json['cancelled_at']);
  if (cancelledAt != null) {
    printOrderDataPayloadOrder.cancelledAt = cancelledAt;
  }
  final dynamic cartToken = jsonConvert.convert<dynamic>(json['cart_token']);
  if (cartToken != null) {
    printOrderDataPayloadOrder.cartToken = cartToken;
  }
  final dynamic checkoutId = jsonConvert.convert<dynamic>(json['checkout_id']);
  if (checkoutId != null) {
    printOrderDataPayloadOrder.checkoutId = checkoutId;
  }
  final dynamic checkoutToken = jsonConvert.convert<dynamic>(json['checkout_token']);
  if (checkoutToken != null) {
    printOrderDataPayloadOrder.checkoutToken = checkoutToken;
  }
  final dynamic closedAt = jsonConvert.convert<dynamic>(json['closed_at']);
  if (closedAt != null) {
    printOrderDataPayloadOrder.closedAt = closedAt;
  }
  final bool? confirmed = jsonConvert.convert<bool>(json['confirmed']);
  if (confirmed != null) {
    printOrderDataPayloadOrder.confirmed = confirmed;
  }
  final dynamic contactEmail = jsonConvert.convert<dynamic>(json['contact_email']);
  if (contactEmail != null) {
    printOrderDataPayloadOrder.contactEmail = contactEmail;
  }
  final String? createdAt = jsonConvert.convert<String>(json['created_at']);
  if (createdAt != null) {
    printOrderDataPayloadOrder.createdAt = createdAt;
  }
  final String? currency = jsonConvert.convert<String>(json['currency']);
  if (currency != null) {
    printOrderDataPayloadOrder.currency = currency;
  }
  final String? currentSubtotalPrice = jsonConvert.convert<String>(json['current_subtotal_price']);
  if (currentSubtotalPrice != null) {
    printOrderDataPayloadOrder.currentSubtotalPrice = currentSubtotalPrice;
  }
  final PrintOrderDataPayloadOrderCurrentSubtotalPriceSet? currentSubtotalPriceSet =
      jsonConvert.convert<PrintOrderDataPayloadOrderCurrentSubtotalPriceSet>(json['current_subtotal_price_set']);
  if (currentSubtotalPriceSet != null) {
    printOrderDataPayloadOrder.currentSubtotalPriceSet = currentSubtotalPriceSet;
  }
  final String? currentTotalDiscounts = jsonConvert.convert<String>(json['current_total_discounts']);
  if (currentTotalDiscounts != null) {
    printOrderDataPayloadOrder.currentTotalDiscounts = currentTotalDiscounts;
  }
  final PrintOrderDataPayloadOrderCurrentTotalDiscountsSet? currentTotalDiscountsSet =
      jsonConvert.convert<PrintOrderDataPayloadOrderCurrentTotalDiscountsSet>(json['current_total_discounts_set']);
  if (currentTotalDiscountsSet != null) {
    printOrderDataPayloadOrder.currentTotalDiscountsSet = currentTotalDiscountsSet;
  }
  final dynamic currentTotalDutiesSet = jsonConvert.convert<dynamic>(json['current_total_duties_set']);
  if (currentTotalDutiesSet != null) {
    printOrderDataPayloadOrder.currentTotalDutiesSet = currentTotalDutiesSet;
  }
  final String? currentTotalPrice = jsonConvert.convert<String>(json['current_total_price']);
  if (currentTotalPrice != null) {
    printOrderDataPayloadOrder.currentTotalPrice = currentTotalPrice;
  }
  final PrintOrderDataPayloadOrderCurrentTotalPriceSet? currentTotalPriceSet = jsonConvert.convert<PrintOrderDataPayloadOrderCurrentTotalPriceSet>(json['current_total_price_set']);
  if (currentTotalPriceSet != null) {
    printOrderDataPayloadOrder.currentTotalPriceSet = currentTotalPriceSet;
  }
  final String? currentTotalTax = jsonConvert.convert<String>(json['current_total_tax']);
  if (currentTotalTax != null) {
    printOrderDataPayloadOrder.currentTotalTax = currentTotalTax;
  }
  final PrintOrderDataPayloadOrderCurrentTotalTaxSet? currentTotalTaxSet = jsonConvert.convert<PrintOrderDataPayloadOrderCurrentTotalTaxSet>(json['current_total_tax_set']);
  if (currentTotalTaxSet != null) {
    printOrderDataPayloadOrder.currentTotalTaxSet = currentTotalTaxSet;
  }
  final dynamic customerLocale = jsonConvert.convert<dynamic>(json['customer_locale']);
  if (customerLocale != null) {
    printOrderDataPayloadOrder.customerLocale = customerLocale;
  }
  final dynamic deviceId = jsonConvert.convert<dynamic>(json['device_id']);
  if (deviceId != null) {
    printOrderDataPayloadOrder.deviceId = deviceId;
  }
  final List<dynamic>? discountCodes = jsonConvert.convertListNotNull<dynamic>(json['discount_codes']);
  if (discountCodes != null) {
    printOrderDataPayloadOrder.discountCodes = discountCodes;
  }
  final String? email = jsonConvert.convert<String>(json['email']);
  if (email != null) {
    printOrderDataPayloadOrder.email = email;
  }
  final bool? estimatedTaxes = jsonConvert.convert<bool>(json['estimated_taxes']);
  if (estimatedTaxes != null) {
    printOrderDataPayloadOrder.estimatedTaxes = estimatedTaxes;
  }
  final String? financialStatus = jsonConvert.convert<String>(json['financial_status']);
  if (financialStatus != null) {
    printOrderDataPayloadOrder.financialStatus = financialStatus;
  }
  final dynamic fulfillmentStatus = jsonConvert.convert<dynamic>(json['fulfillment_status']);
  if (fulfillmentStatus != null) {
    printOrderDataPayloadOrder.fulfillmentStatus = fulfillmentStatus;
  }
  final String? gateway = jsonConvert.convert<String>(json['gateway']);
  if (gateway != null) {
    printOrderDataPayloadOrder.gateway = gateway;
  }
  final dynamic landingSite = jsonConvert.convert<dynamic>(json['landing_site']);
  if (landingSite != null) {
    printOrderDataPayloadOrder.landingSite = landingSite;
  }
  final dynamic landingSiteRef = jsonConvert.convert<dynamic>(json['landing_site_ref']);
  if (landingSiteRef != null) {
    printOrderDataPayloadOrder.landingSiteRef = landingSiteRef;
  }
  final dynamic locationId = jsonConvert.convert<dynamic>(json['location_id']);
  if (locationId != null) {
    printOrderDataPayloadOrder.locationId = locationId;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    printOrderDataPayloadOrder.name = name;
  }
  final String? note = jsonConvert.convert<String>(json['note']);
  if (note != null) {
    printOrderDataPayloadOrder.note = note;
  }
  final List<dynamic>? noteAttributes = jsonConvert.convertListNotNull<dynamic>(json['note_attributes']);
  if (noteAttributes != null) {
    printOrderDataPayloadOrder.noteAttributes = noteAttributes;
  }
  final int? number = jsonConvert.convert<int>(json['number']);
  if (number != null) {
    printOrderDataPayloadOrder.number = number;
  }
  final int? orderNumber = jsonConvert.convert<int>(json['order_number']);
  if (orderNumber != null) {
    printOrderDataPayloadOrder.orderNumber = orderNumber;
  }
  final String? orderStatusUrl = jsonConvert.convert<String>(json['order_status_url']);
  if (orderStatusUrl != null) {
    printOrderDataPayloadOrder.orderStatusUrl = orderStatusUrl;
  }
  final dynamic originalTotalDutiesSet = jsonConvert.convert<dynamic>(json['original_total_duties_set']);
  if (originalTotalDutiesSet != null) {
    printOrderDataPayloadOrder.originalTotalDutiesSet = originalTotalDutiesSet;
  }
  final List<dynamic>? paymentGatewayNames = jsonConvert.convertListNotNull<dynamic>(json['payment_gateway_names']);
  if (paymentGatewayNames != null) {
    printOrderDataPayloadOrder.paymentGatewayNames = paymentGatewayNames;
  }
  final dynamic phone = jsonConvert.convert<dynamic>(json['phone']);
  if (phone != null) {
    printOrderDataPayloadOrder.phone = phone;
  }
  final String? presentmentCurrency = jsonConvert.convert<String>(json['presentment_currency']);
  if (presentmentCurrency != null) {
    printOrderDataPayloadOrder.presentmentCurrency = presentmentCurrency;
  }
  final String? processedAt = jsonConvert.convert<String>(json['processed_at']);
  if (processedAt != null) {
    printOrderDataPayloadOrder.processedAt = processedAt;
  }
  final String? processingMethod = jsonConvert.convert<String>(json['processing_method']);
  if (processingMethod != null) {
    printOrderDataPayloadOrder.processingMethod = processingMethod;
  }
  final dynamic reference = jsonConvert.convert<dynamic>(json['reference']);
  if (reference != null) {
    printOrderDataPayloadOrder.reference = reference;
  }
  final dynamic referringSite = jsonConvert.convert<dynamic>(json['referring_site']);
  if (referringSite != null) {
    printOrderDataPayloadOrder.referringSite = referringSite;
  }
  final dynamic sourceIdentifier = jsonConvert.convert<dynamic>(json['source_identifier']);
  if (sourceIdentifier != null) {
    printOrderDataPayloadOrder.sourceIdentifier = sourceIdentifier;
  }
  final String? sourceName = jsonConvert.convert<String>(json['source_name']);
  if (sourceName != null) {
    printOrderDataPayloadOrder.sourceName = sourceName;
  }
  final dynamic sourceUrl = jsonConvert.convert<dynamic>(json['source_url']);
  if (sourceUrl != null) {
    printOrderDataPayloadOrder.sourceUrl = sourceUrl;
  }
  final String? subtotalPrice = jsonConvert.convert<String>(json['subtotal_price']);
  if (subtotalPrice != null) {
    printOrderDataPayloadOrder.subtotalPrice = subtotalPrice;
  }
  final PrintOrderDataPayloadOrderSubtotalPriceSet? subtotalPriceSet = jsonConvert.convert<PrintOrderDataPayloadOrderSubtotalPriceSet>(json['subtotal_price_set']);
  if (subtotalPriceSet != null) {
    printOrderDataPayloadOrder.subtotalPriceSet = subtotalPriceSet;
  }
  final String? tags = jsonConvert.convert<String>(json['tags']);
  if (tags != null) {
    printOrderDataPayloadOrder.tags = tags;
  }
  final List<dynamic>? taxLines = jsonConvert.convertListNotNull<dynamic>(json['tax_lines']);
  if (taxLines != null) {
    printOrderDataPayloadOrder.taxLines = taxLines;
  }
  final bool? taxesIncluded = jsonConvert.convert<bool>(json['taxes_included']);
  if (taxesIncluded != null) {
    printOrderDataPayloadOrder.taxesIncluded = taxesIncluded;
  }
  final bool? test = jsonConvert.convert<bool>(json['test']);
  if (test != null) {
    printOrderDataPayloadOrder.test = test;
  }
  final String? token = jsonConvert.convert<String>(json['token']);
  if (token != null) {
    printOrderDataPayloadOrder.token = token;
  }
  final String? totalDiscounts = jsonConvert.convert<String>(json['total_discounts']);
  if (totalDiscounts != null) {
    printOrderDataPayloadOrder.totalDiscounts = totalDiscounts;
  }
  final PrintOrderDataPayloadOrderTotalDiscountsSet? totalDiscountsSet = jsonConvert.convert<PrintOrderDataPayloadOrderTotalDiscountsSet>(json['total_discounts_set']);
  if (totalDiscountsSet != null) {
    printOrderDataPayloadOrder.totalDiscountsSet = totalDiscountsSet;
  }
  final String? totalLineItemsPrice = jsonConvert.convert<String>(json['total_line_items_price']);
  if (totalLineItemsPrice != null) {
    printOrderDataPayloadOrder.totalLineItemsPrice = totalLineItemsPrice;
  }
  final PrintOrderDataPayloadOrderTotalLineItemsPriceSet? totalLineItemsPriceSet =
      jsonConvert.convert<PrintOrderDataPayloadOrderTotalLineItemsPriceSet>(json['total_line_items_price_set']);
  if (totalLineItemsPriceSet != null) {
    printOrderDataPayloadOrder.totalLineItemsPriceSet = totalLineItemsPriceSet;
  }
  final String? totalOutstanding = jsonConvert.convert<String>(json['total_outstanding']);
  if (totalOutstanding != null) {
    printOrderDataPayloadOrder.totalOutstanding = totalOutstanding;
  }
  final String? totalPrice = jsonConvert.convert<String>(json['total_price']);
  if (totalPrice != null) {
    printOrderDataPayloadOrder.totalPrice = totalPrice;
  }
  final PrintOrderDataPayloadOrderTotalPriceSet? totalPriceSet = jsonConvert.convert<PrintOrderDataPayloadOrderTotalPriceSet>(json['total_price_set']);
  if (totalPriceSet != null) {
    printOrderDataPayloadOrder.totalPriceSet = totalPriceSet;
  }
  final String? totalPriceUsd = jsonConvert.convert<String>(json['total_price_usd']);
  if (totalPriceUsd != null) {
    printOrderDataPayloadOrder.totalPriceUsd = totalPriceUsd;
  }
  final PrintOrderDataPayloadOrderTotalShippingPriceSet? totalShippingPriceSet =
      jsonConvert.convert<PrintOrderDataPayloadOrderTotalShippingPriceSet>(json['total_shipping_price_set']);
  if (totalShippingPriceSet != null) {
    printOrderDataPayloadOrder.totalShippingPriceSet = totalShippingPriceSet;
  }
  final String? totalTax = jsonConvert.convert<String>(json['total_tax']);
  if (totalTax != null) {
    printOrderDataPayloadOrder.totalTax = totalTax;
  }
  final PrintOrderDataPayloadOrderTotalTaxSet? totalTaxSet = jsonConvert.convert<PrintOrderDataPayloadOrderTotalTaxSet>(json['total_tax_set']);
  if (totalTaxSet != null) {
    printOrderDataPayloadOrder.totalTaxSet = totalTaxSet;
  }
  final String? totalTipReceived = jsonConvert.convert<String>(json['total_tip_received']);
  if (totalTipReceived != null) {
    printOrderDataPayloadOrder.totalTipReceived = totalTipReceived;
  }
  final int? totalWeight = jsonConvert.convert<int>(json['total_weight']);
  if (totalWeight != null) {
    printOrderDataPayloadOrder.totalWeight = totalWeight;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updated_at']);
  if (updatedAt != null) {
    printOrderDataPayloadOrder.updatedAt = updatedAt;
  }
  final dynamic userId = jsonConvert.convert<dynamic>(json['user_id']);
  if (userId != null) {
    printOrderDataPayloadOrder.userId = userId;
  }
  final PrintOrderDataPayloadOrderCustomer? customer = jsonConvert.convert<PrintOrderDataPayloadOrderCustomer>(json['customer']);
  if (customer != null) {
    printOrderDataPayloadOrder.customer = customer;
  }
  final List<dynamic>? discountApplications = jsonConvert.convertListNotNull<dynamic>(json['discount_applications']);
  if (discountApplications != null) {
    printOrderDataPayloadOrder.discountApplications = discountApplications;
  }
  final List<dynamic>? fulfillments = jsonConvert.convertListNotNull<dynamic>(json['fulfillments']);
  if (fulfillments != null) {
    printOrderDataPayloadOrder.fulfillments = fulfillments;
  }
  final List<PrintOrderDataPayloadOrderLineItems>? lineItems = jsonConvert.convertListNotNull<PrintOrderDataPayloadOrderLineItems>(json['line_items']);
  if (lineItems != null) {
    printOrderDataPayloadOrder.lineItems = lineItems;
  }
  final dynamic paymentTerms = jsonConvert.convert<dynamic>(json['payment_terms']);
  if (paymentTerms != null) {
    printOrderDataPayloadOrder.paymentTerms = paymentTerms;
  }
  final List<dynamic>? refunds = jsonConvert.convertListNotNull<dynamic>(json['refunds']);
  if (refunds != null) {
    printOrderDataPayloadOrder.refunds = refunds;
  }
  final List<dynamic>? shippingLines = jsonConvert.convertListNotNull<dynamic>(json['shipping_lines']);
  if (shippingLines != null) {
    printOrderDataPayloadOrder.shippingLines = shippingLines;
  }
  return printOrderDataPayloadOrder;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderToJson(PrintOrderDataPayloadOrder entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['admin_graphql_api_id'] = entity.adminGraphqlApiId;
  data['app_id'] = entity.appId;
  data['browser_ip'] = entity.browserIp;
  data['buyer_accepts_marketing'] = entity.buyerAcceptsMarketing;
  data['cancel_reason'] = entity.cancelReason;
  data['cancelled_at'] = entity.cancelledAt;
  data['cart_token'] = entity.cartToken;
  data['checkout_id'] = entity.checkoutId;
  data['checkout_token'] = entity.checkoutToken;
  data['closed_at'] = entity.closedAt;
  data['confirmed'] = entity.confirmed;
  data['contact_email'] = entity.contactEmail;
  data['created_at'] = entity.createdAt;
  data['currency'] = entity.currency;
  data['current_subtotal_price'] = entity.currentSubtotalPrice;
  data['current_subtotal_price_set'] = entity.currentSubtotalPriceSet.toJson();
  data['current_total_discounts'] = entity.currentTotalDiscounts;
  data['current_total_discounts_set'] = entity.currentTotalDiscountsSet.toJson();
  data['current_total_duties_set'] = entity.currentTotalDutiesSet;
  data['current_total_price'] = entity.currentTotalPrice;
  data['current_total_price_set'] = entity.currentTotalPriceSet.toJson();
  data['current_total_tax'] = entity.currentTotalTax;
  data['current_total_tax_set'] = entity.currentTotalTaxSet.toJson();
  data['customer_locale'] = entity.customerLocale;
  data['device_id'] = entity.deviceId;
  data['discount_codes'] = entity.discountCodes;
  data['email'] = entity.email;
  data['estimated_taxes'] = entity.estimatedTaxes;
  data['financial_status'] = entity.financialStatus;
  data['fulfillment_status'] = entity.fulfillmentStatus;
  data['gateway'] = entity.gateway;
  data['landing_site'] = entity.landingSite;
  data['landing_site_ref'] = entity.landingSiteRef;
  data['location_id'] = entity.locationId;
  data['name'] = entity.name;
  data['note'] = entity.note;
  data['note_attributes'] = entity.noteAttributes;
  data['number'] = entity.number;
  data['order_number'] = entity.orderNumber;
  data['order_status_url'] = entity.orderStatusUrl;
  data['original_total_duties_set'] = entity.originalTotalDutiesSet;
  data['payment_gateway_names'] = entity.paymentGatewayNames;
  data['phone'] = entity.phone;
  data['presentment_currency'] = entity.presentmentCurrency;
  data['processed_at'] = entity.processedAt;
  data['processing_method'] = entity.processingMethod;
  data['reference'] = entity.reference;
  data['referring_site'] = entity.referringSite;
  data['source_identifier'] = entity.sourceIdentifier;
  data['source_name'] = entity.sourceName;
  data['source_url'] = entity.sourceUrl;
  data['subtotal_price'] = entity.subtotalPrice;
  data['subtotal_price_set'] = entity.subtotalPriceSet.toJson();
  data['tags'] = entity.tags;
  data['tax_lines'] = entity.taxLines;
  data['taxes_included'] = entity.taxesIncluded;
  data['test'] = entity.test;
  data['token'] = entity.token;
  data['total_discounts'] = entity.totalDiscounts;
  data['total_discounts_set'] = entity.totalDiscountsSet.toJson();
  data['total_line_items_price'] = entity.totalLineItemsPrice;
  data['total_line_items_price_set'] = entity.totalLineItemsPriceSet.toJson();
  data['total_outstanding'] = entity.totalOutstanding;
  data['total_price'] = entity.totalPrice;
  data['total_price_set'] = entity.totalPriceSet.toJson();
  data['total_price_usd'] = entity.totalPriceUsd;
  data['total_shipping_price_set'] = entity.totalShippingPriceSet.toJson();
  data['total_tax'] = entity.totalTax;
  data['total_tax_set'] = entity.totalTaxSet.toJson();
  data['total_tip_received'] = entity.totalTipReceived;
  data['total_weight'] = entity.totalWeight;
  data['updated_at'] = entity.updatedAt;
  data['user_id'] = entity.userId;
  data['customer'] = entity.customer.toJson();
  data['discount_applications'] = entity.discountApplications;
  data['fulfillments'] = entity.fulfillments;
  data['line_items'] = entity.lineItems.map((v) => v.toJson()).toList();
  data['payment_terms'] = entity.paymentTerms;
  data['refunds'] = entity.refunds;
  data['shipping_lines'] = entity.shippingLines;
  return data;
}

PrintOrderDataPayloadOrderCurrentSubtotalPriceSet $PrintOrderDataPayloadOrderCurrentSubtotalPriceSetFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderCurrentSubtotalPriceSet printOrderDataPayloadOrderCurrentSubtotalPriceSet = PrintOrderDataPayloadOrderCurrentSubtotalPriceSet();
  final PrintOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoney? shopMoney = jsonConvert.convert<PrintOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrderDataPayloadOrderCurrentSubtotalPriceSet.shopMoney = shopMoney;
  }
  final PrintOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrderDataPayloadOrderCurrentSubtotalPriceSet.presentmentMoney = presentmentMoney;
  }
  return printOrderDataPayloadOrderCurrentSubtotalPriceSet;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderCurrentSubtotalPriceSetToJson(PrintOrderDataPayloadOrderCurrentSubtotalPriceSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoney $PrintOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoney printOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoney =
      PrintOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoneyToJson(PrintOrderDataPayloadOrderCurrentSubtotalPriceSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoney $PrintOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoney printOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoney =
      PrintOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoneyToJson(PrintOrderDataPayloadOrderCurrentSubtotalPriceSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderCurrentTotalDiscountsSet $PrintOrderDataPayloadOrderCurrentTotalDiscountsSetFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderCurrentTotalDiscountsSet printOrderDataPayloadOrderCurrentTotalDiscountsSet = PrintOrderDataPayloadOrderCurrentTotalDiscountsSet();
  final PrintOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoney? shopMoney =
      jsonConvert.convert<PrintOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrderDataPayloadOrderCurrentTotalDiscountsSet.shopMoney = shopMoney;
  }
  final PrintOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrderDataPayloadOrderCurrentTotalDiscountsSet.presentmentMoney = presentmentMoney;
  }
  return printOrderDataPayloadOrderCurrentTotalDiscountsSet;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderCurrentTotalDiscountsSetToJson(PrintOrderDataPayloadOrderCurrentTotalDiscountsSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoney $PrintOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoney printOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoney =
      PrintOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoneyToJson(PrintOrderDataPayloadOrderCurrentTotalDiscountsSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoney $PrintOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoney printOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoney =
      PrintOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoneyToJson(PrintOrderDataPayloadOrderCurrentTotalDiscountsSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderCurrentTotalPriceSet $PrintOrderDataPayloadOrderCurrentTotalPriceSetFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderCurrentTotalPriceSet printOrderDataPayloadOrderCurrentTotalPriceSet = PrintOrderDataPayloadOrderCurrentTotalPriceSet();
  final PrintOrderDataPayloadOrderCurrentTotalPriceSetShopMoney? shopMoney = jsonConvert.convert<PrintOrderDataPayloadOrderCurrentTotalPriceSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrderDataPayloadOrderCurrentTotalPriceSet.shopMoney = shopMoney;
  }
  final PrintOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrderDataPayloadOrderCurrentTotalPriceSet.presentmentMoney = presentmentMoney;
  }
  return printOrderDataPayloadOrderCurrentTotalPriceSet;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderCurrentTotalPriceSetToJson(PrintOrderDataPayloadOrderCurrentTotalPriceSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrderDataPayloadOrderCurrentTotalPriceSetShopMoney $PrintOrderDataPayloadOrderCurrentTotalPriceSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderCurrentTotalPriceSetShopMoney printOrderDataPayloadOrderCurrentTotalPriceSetShopMoney = PrintOrderDataPayloadOrderCurrentTotalPriceSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderCurrentTotalPriceSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderCurrentTotalPriceSetShopMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderCurrentTotalPriceSetShopMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderCurrentTotalPriceSetShopMoneyToJson(PrintOrderDataPayloadOrderCurrentTotalPriceSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoney $PrintOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoney printOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoney =
      PrintOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoneyToJson(PrintOrderDataPayloadOrderCurrentTotalPriceSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderCurrentTotalTaxSet $PrintOrderDataPayloadOrderCurrentTotalTaxSetFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderCurrentTotalTaxSet printOrderDataPayloadOrderCurrentTotalTaxSet = PrintOrderDataPayloadOrderCurrentTotalTaxSet();
  final PrintOrderDataPayloadOrderCurrentTotalTaxSetShopMoney? shopMoney = jsonConvert.convert<PrintOrderDataPayloadOrderCurrentTotalTaxSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrderDataPayloadOrderCurrentTotalTaxSet.shopMoney = shopMoney;
  }
  final PrintOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrderDataPayloadOrderCurrentTotalTaxSet.presentmentMoney = presentmentMoney;
  }
  return printOrderDataPayloadOrderCurrentTotalTaxSet;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderCurrentTotalTaxSetToJson(PrintOrderDataPayloadOrderCurrentTotalTaxSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrderDataPayloadOrderCurrentTotalTaxSetShopMoney $PrintOrderDataPayloadOrderCurrentTotalTaxSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderCurrentTotalTaxSetShopMoney printOrderDataPayloadOrderCurrentTotalTaxSetShopMoney = PrintOrderDataPayloadOrderCurrentTotalTaxSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderCurrentTotalTaxSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderCurrentTotalTaxSetShopMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderCurrentTotalTaxSetShopMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderCurrentTotalTaxSetShopMoneyToJson(PrintOrderDataPayloadOrderCurrentTotalTaxSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoney $PrintOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoney printOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoney =
      PrintOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoneyToJson(PrintOrderDataPayloadOrderCurrentTotalTaxSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderSubtotalPriceSet $PrintOrderDataPayloadOrderSubtotalPriceSetFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderSubtotalPriceSet printOrderDataPayloadOrderSubtotalPriceSet = PrintOrderDataPayloadOrderSubtotalPriceSet();
  final PrintOrderDataPayloadOrderSubtotalPriceSetShopMoney? shopMoney = jsonConvert.convert<PrintOrderDataPayloadOrderSubtotalPriceSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrderDataPayloadOrderSubtotalPriceSet.shopMoney = shopMoney;
  }
  final PrintOrderDataPayloadOrderSubtotalPriceSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrderDataPayloadOrderSubtotalPriceSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrderDataPayloadOrderSubtotalPriceSet.presentmentMoney = presentmentMoney;
  }
  return printOrderDataPayloadOrderSubtotalPriceSet;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderSubtotalPriceSetToJson(PrintOrderDataPayloadOrderSubtotalPriceSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrderDataPayloadOrderSubtotalPriceSetShopMoney $PrintOrderDataPayloadOrderSubtotalPriceSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderSubtotalPriceSetShopMoney printOrderDataPayloadOrderSubtotalPriceSetShopMoney = PrintOrderDataPayloadOrderSubtotalPriceSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderSubtotalPriceSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderSubtotalPriceSetShopMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderSubtotalPriceSetShopMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderSubtotalPriceSetShopMoneyToJson(PrintOrderDataPayloadOrderSubtotalPriceSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderSubtotalPriceSetPresentmentMoney $PrintOrderDataPayloadOrderSubtotalPriceSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderSubtotalPriceSetPresentmentMoney printOrderDataPayloadOrderSubtotalPriceSetPresentmentMoney =
      PrintOrderDataPayloadOrderSubtotalPriceSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderSubtotalPriceSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderSubtotalPriceSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderSubtotalPriceSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderSubtotalPriceSetPresentmentMoneyToJson(PrintOrderDataPayloadOrderSubtotalPriceSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderTotalDiscountsSet $PrintOrderDataPayloadOrderTotalDiscountsSetFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderTotalDiscountsSet printOrderDataPayloadOrderTotalDiscountsSet = PrintOrderDataPayloadOrderTotalDiscountsSet();
  final PrintOrderDataPayloadOrderTotalDiscountsSetShopMoney? shopMoney = jsonConvert.convert<PrintOrderDataPayloadOrderTotalDiscountsSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrderDataPayloadOrderTotalDiscountsSet.shopMoney = shopMoney;
  }
  final PrintOrderDataPayloadOrderTotalDiscountsSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrderDataPayloadOrderTotalDiscountsSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrderDataPayloadOrderTotalDiscountsSet.presentmentMoney = presentmentMoney;
  }
  return printOrderDataPayloadOrderTotalDiscountsSet;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderTotalDiscountsSetToJson(PrintOrderDataPayloadOrderTotalDiscountsSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrderDataPayloadOrderTotalDiscountsSetShopMoney $PrintOrderDataPayloadOrderTotalDiscountsSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderTotalDiscountsSetShopMoney printOrderDataPayloadOrderTotalDiscountsSetShopMoney = PrintOrderDataPayloadOrderTotalDiscountsSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderTotalDiscountsSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderTotalDiscountsSetShopMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderTotalDiscountsSetShopMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderTotalDiscountsSetShopMoneyToJson(PrintOrderDataPayloadOrderTotalDiscountsSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderTotalDiscountsSetPresentmentMoney $PrintOrderDataPayloadOrderTotalDiscountsSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderTotalDiscountsSetPresentmentMoney printOrderDataPayloadOrderTotalDiscountsSetPresentmentMoney =
      PrintOrderDataPayloadOrderTotalDiscountsSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderTotalDiscountsSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderTotalDiscountsSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderTotalDiscountsSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderTotalDiscountsSetPresentmentMoneyToJson(PrintOrderDataPayloadOrderTotalDiscountsSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderTotalLineItemsPriceSet $PrintOrderDataPayloadOrderTotalLineItemsPriceSetFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderTotalLineItemsPriceSet printOrderDataPayloadOrderTotalLineItemsPriceSet = PrintOrderDataPayloadOrderTotalLineItemsPriceSet();
  final PrintOrderDataPayloadOrderTotalLineItemsPriceSetShopMoney? shopMoney = jsonConvert.convert<PrintOrderDataPayloadOrderTotalLineItemsPriceSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrderDataPayloadOrderTotalLineItemsPriceSet.shopMoney = shopMoney;
  }
  final PrintOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrderDataPayloadOrderTotalLineItemsPriceSet.presentmentMoney = presentmentMoney;
  }
  return printOrderDataPayloadOrderTotalLineItemsPriceSet;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderTotalLineItemsPriceSetToJson(PrintOrderDataPayloadOrderTotalLineItemsPriceSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrderDataPayloadOrderTotalLineItemsPriceSetShopMoney $PrintOrderDataPayloadOrderTotalLineItemsPriceSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderTotalLineItemsPriceSetShopMoney printOrderDataPayloadOrderTotalLineItemsPriceSetShopMoney =
      PrintOrderDataPayloadOrderTotalLineItemsPriceSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderTotalLineItemsPriceSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderTotalLineItemsPriceSetShopMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderTotalLineItemsPriceSetShopMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderTotalLineItemsPriceSetShopMoneyToJson(PrintOrderDataPayloadOrderTotalLineItemsPriceSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoney $PrintOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoney printOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoney =
      PrintOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoneyToJson(PrintOrderDataPayloadOrderTotalLineItemsPriceSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderTotalPriceSet $PrintOrderDataPayloadOrderTotalPriceSetFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderTotalPriceSet printOrderDataPayloadOrderTotalPriceSet = PrintOrderDataPayloadOrderTotalPriceSet();
  final PrintOrderDataPayloadOrderTotalPriceSetShopMoney? shopMoney = jsonConvert.convert<PrintOrderDataPayloadOrderTotalPriceSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrderDataPayloadOrderTotalPriceSet.shopMoney = shopMoney;
  }
  final PrintOrderDataPayloadOrderTotalPriceSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrderDataPayloadOrderTotalPriceSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrderDataPayloadOrderTotalPriceSet.presentmentMoney = presentmentMoney;
  }
  return printOrderDataPayloadOrderTotalPriceSet;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderTotalPriceSetToJson(PrintOrderDataPayloadOrderTotalPriceSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrderDataPayloadOrderTotalPriceSetShopMoney $PrintOrderDataPayloadOrderTotalPriceSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderTotalPriceSetShopMoney printOrderDataPayloadOrderTotalPriceSetShopMoney = PrintOrderDataPayloadOrderTotalPriceSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderTotalPriceSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderTotalPriceSetShopMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderTotalPriceSetShopMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderTotalPriceSetShopMoneyToJson(PrintOrderDataPayloadOrderTotalPriceSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderTotalPriceSetPresentmentMoney $PrintOrderDataPayloadOrderTotalPriceSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderTotalPriceSetPresentmentMoney printOrderDataPayloadOrderTotalPriceSetPresentmentMoney = PrintOrderDataPayloadOrderTotalPriceSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderTotalPriceSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderTotalPriceSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderTotalPriceSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderTotalPriceSetPresentmentMoneyToJson(PrintOrderDataPayloadOrderTotalPriceSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderTotalShippingPriceSet $PrintOrderDataPayloadOrderTotalShippingPriceSetFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderTotalShippingPriceSet printOrderDataPayloadOrderTotalShippingPriceSet = PrintOrderDataPayloadOrderTotalShippingPriceSet();
  final PrintOrderDataPayloadOrderTotalShippingPriceSetShopMoney? shopMoney = jsonConvert.convert<PrintOrderDataPayloadOrderTotalShippingPriceSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrderDataPayloadOrderTotalShippingPriceSet.shopMoney = shopMoney;
  }
  final PrintOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrderDataPayloadOrderTotalShippingPriceSet.presentmentMoney = presentmentMoney;
  }
  return printOrderDataPayloadOrderTotalShippingPriceSet;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderTotalShippingPriceSetToJson(PrintOrderDataPayloadOrderTotalShippingPriceSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrderDataPayloadOrderTotalShippingPriceSetShopMoney $PrintOrderDataPayloadOrderTotalShippingPriceSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderTotalShippingPriceSetShopMoney printOrderDataPayloadOrderTotalShippingPriceSetShopMoney =
      PrintOrderDataPayloadOrderTotalShippingPriceSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderTotalShippingPriceSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderTotalShippingPriceSetShopMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderTotalShippingPriceSetShopMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderTotalShippingPriceSetShopMoneyToJson(PrintOrderDataPayloadOrderTotalShippingPriceSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoney $PrintOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoney printOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoney =
      PrintOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoneyToJson(PrintOrderDataPayloadOrderTotalShippingPriceSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderTotalTaxSet $PrintOrderDataPayloadOrderTotalTaxSetFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderTotalTaxSet printOrderDataPayloadOrderTotalTaxSet = PrintOrderDataPayloadOrderTotalTaxSet();
  final PrintOrderDataPayloadOrderTotalTaxSetShopMoney? shopMoney = jsonConvert.convert<PrintOrderDataPayloadOrderTotalTaxSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrderDataPayloadOrderTotalTaxSet.shopMoney = shopMoney;
  }
  final PrintOrderDataPayloadOrderTotalTaxSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrderDataPayloadOrderTotalTaxSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrderDataPayloadOrderTotalTaxSet.presentmentMoney = presentmentMoney;
  }
  return printOrderDataPayloadOrderTotalTaxSet;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderTotalTaxSetToJson(PrintOrderDataPayloadOrderTotalTaxSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrderDataPayloadOrderTotalTaxSetShopMoney $PrintOrderDataPayloadOrderTotalTaxSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderTotalTaxSetShopMoney printOrderDataPayloadOrderTotalTaxSetShopMoney = PrintOrderDataPayloadOrderTotalTaxSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderTotalTaxSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderTotalTaxSetShopMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderTotalTaxSetShopMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderTotalTaxSetShopMoneyToJson(PrintOrderDataPayloadOrderTotalTaxSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderTotalTaxSetPresentmentMoney $PrintOrderDataPayloadOrderTotalTaxSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderTotalTaxSetPresentmentMoney printOrderDataPayloadOrderTotalTaxSetPresentmentMoney = PrintOrderDataPayloadOrderTotalTaxSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderTotalTaxSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderTotalTaxSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderTotalTaxSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderTotalTaxSetPresentmentMoneyToJson(PrintOrderDataPayloadOrderTotalTaxSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderCustomer $PrintOrderDataPayloadOrderCustomerFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderCustomer printOrderDataPayloadOrderCustomer = PrintOrderDataPayloadOrderCustomer();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    printOrderDataPayloadOrderCustomer.id = id;
  }
  final dynamic email = jsonConvert.convert<dynamic>(json['email']);
  if (email != null) {
    printOrderDataPayloadOrderCustomer.email = email;
  }
  final bool? acceptsMarketing = jsonConvert.convert<bool>(json['accepts_marketing']);
  if (acceptsMarketing != null) {
    printOrderDataPayloadOrderCustomer.acceptsMarketing = acceptsMarketing;
  }
  final String? createdAt = jsonConvert.convert<String>(json['created_at']);
  if (createdAt != null) {
    printOrderDataPayloadOrderCustomer.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updated_at']);
  if (updatedAt != null) {
    printOrderDataPayloadOrderCustomer.updatedAt = updatedAt;
  }
  final String? firstName = jsonConvert.convert<String>(json['first_name']);
  if (firstName != null) {
    printOrderDataPayloadOrderCustomer.firstName = firstName;
  }
  final String? lastName = jsonConvert.convert<String>(json['last_name']);
  if (lastName != null) {
    printOrderDataPayloadOrderCustomer.lastName = lastName;
  }
  final String? state = jsonConvert.convert<String>(json['state']);
  if (state != null) {
    printOrderDataPayloadOrderCustomer.state = state;
  }
  final dynamic note = jsonConvert.convert<dynamic>(json['note']);
  if (note != null) {
    printOrderDataPayloadOrderCustomer.note = note;
  }
  final bool? verifiedEmail = jsonConvert.convert<bool>(json['verified_email']);
  if (verifiedEmail != null) {
    printOrderDataPayloadOrderCustomer.verifiedEmail = verifiedEmail;
  }
  final dynamic multipassIdentifier = jsonConvert.convert<dynamic>(json['multipass_identifier']);
  if (multipassIdentifier != null) {
    printOrderDataPayloadOrderCustomer.multipassIdentifier = multipassIdentifier;
  }
  final bool? taxExempt = jsonConvert.convert<bool>(json['tax_exempt']);
  if (taxExempt != null) {
    printOrderDataPayloadOrderCustomer.taxExempt = taxExempt;
  }
  final dynamic phone = jsonConvert.convert<dynamic>(json['phone']);
  if (phone != null) {
    printOrderDataPayloadOrderCustomer.phone = phone;
  }
  final dynamic emailMarketingConsent = jsonConvert.convert<dynamic>(json['email_marketing_consent']);
  if (emailMarketingConsent != null) {
    printOrderDataPayloadOrderCustomer.emailMarketingConsent = emailMarketingConsent;
  }
  final dynamic smsMarketingConsent = jsonConvert.convert<dynamic>(json['sms_marketing_consent']);
  if (smsMarketingConsent != null) {
    printOrderDataPayloadOrderCustomer.smsMarketingConsent = smsMarketingConsent;
  }
  final String? tags = jsonConvert.convert<String>(json['tags']);
  if (tags != null) {
    printOrderDataPayloadOrderCustomer.tags = tags;
  }
  final String? currency = jsonConvert.convert<String>(json['currency']);
  if (currency != null) {
    printOrderDataPayloadOrderCustomer.currency = currency;
  }
  final String? acceptsMarketingUpdatedAt = jsonConvert.convert<String>(json['accepts_marketing_updated_at']);
  if (acceptsMarketingUpdatedAt != null) {
    printOrderDataPayloadOrderCustomer.acceptsMarketingUpdatedAt = acceptsMarketingUpdatedAt;
  }
  final dynamic marketingOptInLevel = jsonConvert.convert<dynamic>(json['marketing_opt_in_level']);
  if (marketingOptInLevel != null) {
    printOrderDataPayloadOrderCustomer.marketingOptInLevel = marketingOptInLevel;
  }
  final List<dynamic>? taxExemptions = jsonConvert.convertListNotNull<dynamic>(json['tax_exemptions']);
  if (taxExemptions != null) {
    printOrderDataPayloadOrderCustomer.taxExemptions = taxExemptions;
  }
  final String? adminGraphqlApiId = jsonConvert.convert<String>(json['admin_graphql_api_id']);
  if (adminGraphqlApiId != null) {
    printOrderDataPayloadOrderCustomer.adminGraphqlApiId = adminGraphqlApiId;
  }
  final PrintOrderDataPayloadOrderCustomerDefaultAddress? defaultAddress = jsonConvert.convert<PrintOrderDataPayloadOrderCustomerDefaultAddress>(json['default_address']);
  if (defaultAddress != null) {
    printOrderDataPayloadOrderCustomer.defaultAddress = defaultAddress;
  }
  return printOrderDataPayloadOrderCustomer;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderCustomerToJson(PrintOrderDataPayloadOrderCustomer entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['email'] = entity.email;
  data['accepts_marketing'] = entity.acceptsMarketing;
  data['created_at'] = entity.createdAt;
  data['updated_at'] = entity.updatedAt;
  data['first_name'] = entity.firstName;
  data['last_name'] = entity.lastName;
  data['state'] = entity.state;
  data['note'] = entity.note;
  data['verified_email'] = entity.verifiedEmail;
  data['multipass_identifier'] = entity.multipassIdentifier;
  data['tax_exempt'] = entity.taxExempt;
  data['phone'] = entity.phone;
  data['email_marketing_consent'] = entity.emailMarketingConsent;
  data['sms_marketing_consent'] = entity.smsMarketingConsent;
  data['tags'] = entity.tags;
  data['currency'] = entity.currency;
  data['accepts_marketing_updated_at'] = entity.acceptsMarketingUpdatedAt;
  data['marketing_opt_in_level'] = entity.marketingOptInLevel;
  data['tax_exemptions'] = entity.taxExemptions;
  data['admin_graphql_api_id'] = entity.adminGraphqlApiId;
  data['default_address'] = entity.defaultAddress.toJson();
  return data;
}

PrintOrderDataPayloadOrderCustomerDefaultAddress $PrintOrderDataPayloadOrderCustomerDefaultAddressFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderCustomerDefaultAddress printOrderDataPayloadOrderCustomerDefaultAddress = PrintOrderDataPayloadOrderCustomerDefaultAddress();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.id = id;
  }
  final int? customerId = jsonConvert.convert<int>(json['customer_id']);
  if (customerId != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.customerId = customerId;
  }
  final String? firstName = jsonConvert.convert<String>(json['first_name']);
  if (firstName != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.firstName = firstName;
  }
  final String? lastName = jsonConvert.convert<String>(json['last_name']);
  if (lastName != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.lastName = lastName;
  }
  final dynamic company = jsonConvert.convert<dynamic>(json['company']);
  if (company != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.company = company;
  }
  final String? address1 = jsonConvert.convert<String>(json['address1']);
  if (address1 != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.address1 = address1;
  }
  final String? address2 = jsonConvert.convert<String>(json['address2']);
  if (address2 != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.address2 = address2;
  }
  final dynamic city = jsonConvert.convert<dynamic>(json['city']);
  if (city != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.city = city;
  }
  final dynamic province = jsonConvert.convert<dynamic>(json['province']);
  if (province != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.province = province;
  }
  final dynamic country = jsonConvert.convert<dynamic>(json['country']);
  if (country != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.country = country;
  }
  final dynamic zip = jsonConvert.convert<dynamic>(json['zip']);
  if (zip != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.zip = zip;
  }
  final String? phone = jsonConvert.convert<String>(json['phone']);
  if (phone != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.phone = phone;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.name = name;
  }
  final dynamic provinceCode = jsonConvert.convert<dynamic>(json['province_code']);
  if (provinceCode != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.provinceCode = provinceCode;
  }
  final dynamic countryCode = jsonConvert.convert<dynamic>(json['country_code']);
  if (countryCode != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.countryCode = countryCode;
  }
  final dynamic countryName = jsonConvert.convert<dynamic>(json['country_name']);
  if (countryName != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.countryName = countryName;
  }
  final bool? xDefault = jsonConvert.convert<bool>(json['default']);
  if (xDefault != null) {
    printOrderDataPayloadOrderCustomerDefaultAddress.xDefault = xDefault;
  }
  return printOrderDataPayloadOrderCustomerDefaultAddress;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderCustomerDefaultAddressToJson(PrintOrderDataPayloadOrderCustomerDefaultAddress entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['customer_id'] = entity.customerId;
  data['first_name'] = entity.firstName;
  data['last_name'] = entity.lastName;
  data['company'] = entity.company;
  data['address1'] = entity.address1;
  data['address2'] = entity.address2;
  data['city'] = entity.city;
  data['province'] = entity.province;
  data['country'] = entity.country;
  data['zip'] = entity.zip;
  data['phone'] = entity.phone;
  data['name'] = entity.name;
  data['province_code'] = entity.provinceCode;
  data['country_code'] = entity.countryCode;
  data['country_name'] = entity.countryName;
  data['default'] = entity.xDefault;
  return data;
}

PrintOrderDataPayloadOrderLineItems $PrintOrderDataPayloadOrderLineItemsFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderLineItems printOrderDataPayloadOrderLineItems = PrintOrderDataPayloadOrderLineItems();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    printOrderDataPayloadOrderLineItems.id = id;
  }
  final String? adminGraphqlApiId = jsonConvert.convert<String>(json['admin_graphql_api_id']);
  if (adminGraphqlApiId != null) {
    printOrderDataPayloadOrderLineItems.adminGraphqlApiId = adminGraphqlApiId;
  }
  final int? fulfillableQuantity = jsonConvert.convert<int>(json['fulfillable_quantity']);
  if (fulfillableQuantity != null) {
    printOrderDataPayloadOrderLineItems.fulfillableQuantity = fulfillableQuantity;
  }
  final String? fulfillmentService = jsonConvert.convert<String>(json['fulfillment_service']);
  if (fulfillmentService != null) {
    printOrderDataPayloadOrderLineItems.fulfillmentService = fulfillmentService;
  }
  final dynamic fulfillmentStatus = jsonConvert.convert<dynamic>(json['fulfillment_status']);
  if (fulfillmentStatus != null) {
    printOrderDataPayloadOrderLineItems.fulfillmentStatus = fulfillmentStatus;
  }
  final bool? giftCard = jsonConvert.convert<bool>(json['gift_card']);
  if (giftCard != null) {
    printOrderDataPayloadOrderLineItems.giftCard = giftCard;
  }
  final int? grams = jsonConvert.convert<int>(json['grams']);
  if (grams != null) {
    printOrderDataPayloadOrderLineItems.grams = grams;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    printOrderDataPayloadOrderLineItems.name = name;
  }
  final String? price = jsonConvert.convert<String>(json['price']);
  if (price != null) {
    printOrderDataPayloadOrderLineItems.price = price;
  }
  final PrintOrderDataPayloadOrderLineItemsPriceSet? priceSet = jsonConvert.convert<PrintOrderDataPayloadOrderLineItemsPriceSet>(json['price_set']);
  if (priceSet != null) {
    printOrderDataPayloadOrderLineItems.priceSet = priceSet;
  }
  final bool? productExists = jsonConvert.convert<bool>(json['product_exists']);
  if (productExists != null) {
    printOrderDataPayloadOrderLineItems.productExists = productExists;
  }
  final int? productId = jsonConvert.convert<int>(json['product_id']);
  if (productId != null) {
    printOrderDataPayloadOrderLineItems.productId = productId;
  }
  final List<dynamic>? properties = jsonConvert.convertListNotNull<dynamic>(json['properties']);
  if (properties != null) {
    printOrderDataPayloadOrderLineItems.properties = properties;
  }
  final int? quantity = jsonConvert.convert<int>(json['quantity']);
  if (quantity != null) {
    printOrderDataPayloadOrderLineItems.quantity = quantity;
  }
  final bool? requiresShipping = jsonConvert.convert<bool>(json['requires_shipping']);
  if (requiresShipping != null) {
    printOrderDataPayloadOrderLineItems.requiresShipping = requiresShipping;
  }
  final String? sku = jsonConvert.convert<String>(json['sku']);
  if (sku != null) {
    printOrderDataPayloadOrderLineItems.sku = sku;
  }
  final bool? taxable = jsonConvert.convert<bool>(json['taxable']);
  if (taxable != null) {
    printOrderDataPayloadOrderLineItems.taxable = taxable;
  }
  final String? title = jsonConvert.convert<String>(json['title']);
  if (title != null) {
    printOrderDataPayloadOrderLineItems.title = title;
  }
  final String? totalDiscount = jsonConvert.convert<String>(json['total_discount']);
  if (totalDiscount != null) {
    printOrderDataPayloadOrderLineItems.totalDiscount = totalDiscount;
  }
  final PrintOrderDataPayloadOrderLineItemsTotalDiscountSet? totalDiscountSet =
      jsonConvert.convert<PrintOrderDataPayloadOrderLineItemsTotalDiscountSet>(json['total_discount_set']);
  if (totalDiscountSet != null) {
    printOrderDataPayloadOrderLineItems.totalDiscountSet = totalDiscountSet;
  }
  final int? variantId = jsonConvert.convert<int>(json['variant_id']);
  if (variantId != null) {
    printOrderDataPayloadOrderLineItems.variantId = variantId;
  }
  final String? variantInventoryManagement = jsonConvert.convert<String>(json['variant_inventory_management']);
  if (variantInventoryManagement != null) {
    printOrderDataPayloadOrderLineItems.variantInventoryManagement = variantInventoryManagement;
  }
  final String? variantTitle = jsonConvert.convert<String>(json['variant_title']);
  if (variantTitle != null) {
    printOrderDataPayloadOrderLineItems.variantTitle = variantTitle;
  }
  final String? vendor = jsonConvert.convert<String>(json['vendor']);
  if (vendor != null) {
    printOrderDataPayloadOrderLineItems.vendor = vendor;
  }
  final List<dynamic>? taxLines = jsonConvert.convertListNotNull<dynamic>(json['tax_lines']);
  if (taxLines != null) {
    printOrderDataPayloadOrderLineItems.taxLines = taxLines;
  }
  final List<dynamic>? duties = jsonConvert.convertListNotNull<dynamic>(json['duties']);
  if (duties != null) {
    printOrderDataPayloadOrderLineItems.duties = duties;
  }
  final List<dynamic>? discountAllocations = jsonConvert.convertListNotNull<dynamic>(json['discount_allocations']);
  if (discountAllocations != null) {
    printOrderDataPayloadOrderLineItems.discountAllocations = discountAllocations;
  }
  return printOrderDataPayloadOrderLineItems;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderLineItemsToJson(PrintOrderDataPayloadOrderLineItems entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['admin_graphql_api_id'] = entity.adminGraphqlApiId;
  data['fulfillable_quantity'] = entity.fulfillableQuantity;
  data['fulfillment_service'] = entity.fulfillmentService;
  data['fulfillment_status'] = entity.fulfillmentStatus;
  data['gift_card'] = entity.giftCard;
  data['grams'] = entity.grams;
  data['name'] = entity.name;
  data['price'] = entity.price;
  data['price_set'] = entity.priceSet.toJson();
  data['product_exists'] = entity.productExists;
  data['product_id'] = entity.productId;
  data['properties'] = entity.properties;
  data['quantity'] = entity.quantity;
  data['requires_shipping'] = entity.requiresShipping;
  data['sku'] = entity.sku;
  data['taxable'] = entity.taxable;
  data['title'] = entity.title;
  data['total_discount'] = entity.totalDiscount;
  data['total_discount_set'] = entity.totalDiscountSet.toJson();
  data['variant_id'] = entity.variantId;
  data['variant_inventory_management'] = entity.variantInventoryManagement;
  data['variant_title'] = entity.variantTitle;
  data['vendor'] = entity.vendor;
  data['tax_lines'] = entity.taxLines;
  data['duties'] = entity.duties;
  data['discount_allocations'] = entity.discountAllocations;
  return data;
}

PrintOrderDataPayloadOrderLineItemsPriceSet $PrintOrderDataPayloadOrderLineItemsPriceSetFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderLineItemsPriceSet printOrderDataPayloadOrderLineItemsPriceSet = PrintOrderDataPayloadOrderLineItemsPriceSet();
  final PrintOrderDataPayloadOrderLineItemsPriceSetShopMoney? shopMoney = jsonConvert.convert<PrintOrderDataPayloadOrderLineItemsPriceSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrderDataPayloadOrderLineItemsPriceSet.shopMoney = shopMoney;
  }
  final PrintOrderDataPayloadOrderLineItemsPriceSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrderDataPayloadOrderLineItemsPriceSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrderDataPayloadOrderLineItemsPriceSet.presentmentMoney = presentmentMoney;
  }
  return printOrderDataPayloadOrderLineItemsPriceSet;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderLineItemsPriceSetToJson(PrintOrderDataPayloadOrderLineItemsPriceSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrderDataPayloadOrderLineItemsPriceSetShopMoney $PrintOrderDataPayloadOrderLineItemsPriceSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderLineItemsPriceSetShopMoney printOrderDataPayloadOrderLineItemsPriceSetShopMoney = PrintOrderDataPayloadOrderLineItemsPriceSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderLineItemsPriceSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderLineItemsPriceSetShopMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderLineItemsPriceSetShopMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderLineItemsPriceSetShopMoneyToJson(PrintOrderDataPayloadOrderLineItemsPriceSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderLineItemsPriceSetPresentmentMoney $PrintOrderDataPayloadOrderLineItemsPriceSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderLineItemsPriceSetPresentmentMoney printOrderDataPayloadOrderLineItemsPriceSetPresentmentMoney =
      PrintOrderDataPayloadOrderLineItemsPriceSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderLineItemsPriceSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderLineItemsPriceSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderLineItemsPriceSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderLineItemsPriceSetPresentmentMoneyToJson(PrintOrderDataPayloadOrderLineItemsPriceSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderLineItemsTotalDiscountSet $PrintOrderDataPayloadOrderLineItemsTotalDiscountSetFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderLineItemsTotalDiscountSet printOrderDataPayloadOrderLineItemsTotalDiscountSet = PrintOrderDataPayloadOrderLineItemsTotalDiscountSet();
  final PrintOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoney? shopMoney =
      jsonConvert.convert<PrintOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrderDataPayloadOrderLineItemsTotalDiscountSet.shopMoney = shopMoney;
  }
  final PrintOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrderDataPayloadOrderLineItemsTotalDiscountSet.presentmentMoney = presentmentMoney;
  }
  return printOrderDataPayloadOrderLineItemsTotalDiscountSet;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderLineItemsTotalDiscountSetToJson(PrintOrderDataPayloadOrderLineItemsTotalDiscountSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoney $PrintOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoney printOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoney =
      PrintOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoneyToJson(PrintOrderDataPayloadOrderLineItemsTotalDiscountSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoney $PrintOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoney printOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoney =
      PrintOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoneyToJson(PrintOrderDataPayloadOrderLineItemsTotalDiscountSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}
