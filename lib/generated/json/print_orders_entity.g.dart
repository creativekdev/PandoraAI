import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/print_orders_entity.dart';

PrintOrdersEntity $PrintOrdersEntityFromJson(Map<String, dynamic> json) {
  final PrintOrdersEntity printOrdersEntity = PrintOrdersEntity();
  final PrintOrdersData? data = jsonConvert.convert<PrintOrdersData>(json['data']);
  if (data != null) {
    printOrdersEntity.data = data;
  }
  return printOrdersEntity;
}

Map<String, dynamic> $PrintOrdersEntityToJson(PrintOrdersEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['data'] = entity.data.toJson();
  return data;
}

PrintOrdersData $PrintOrdersDataFromJson(Map<String, dynamic> json) {
  final PrintOrdersData printOrdersData = PrintOrdersData();
  final List<PrintOrdersDataRows>? rows = jsonConvert.convertListNotNull<PrintOrdersDataRows>(json['rows']);
  if (rows != null) {
    printOrdersData.rows = rows;
  }
  final int? records = jsonConvert.convert<int>(json['records']);
  if (records != null) {
    printOrdersData.records = records;
  }
  final int? total = jsonConvert.convert<int>(json['total']);
  if (total != null) {
    printOrdersData.total = total;
  }
  final int? page = jsonConvert.convert<int>(json['page']);
  if (page != null) {
    printOrdersData.page = page;
  }
  return printOrdersData;
}

Map<String, dynamic> $PrintOrdersDataToJson(PrintOrdersData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['rows'] = entity.rows.map((v) => v.toJson()).toList();
  data['records'] = entity.records;
  data['total'] = entity.total;
  data['page'] = entity.page;
  return data;
}

PrintOrdersDataRows $PrintOrdersDataRowsFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRows printOrdersDataRows = PrintOrdersDataRows();
  final int? userId = jsonConvert.convert<int>(json['user_id']);
  if (userId != null) {
    printOrdersDataRows.userId = userId;
  }
  final int? price = jsonConvert.convert<int>(json['price']);
  if (price != null) {
    printOrdersDataRows.price = price;
  }
  final int? totalPrice = jsonConvert.convert<int>(json['total_price']);
  if (totalPrice != null) {
    printOrdersDataRows.totalPrice = totalPrice;
  }
  final String? eventTime = jsonConvert.convert<String>(json['event_time']);
  if (eventTime != null) {
    printOrdersDataRows.eventTime = eventTime;
  }
  final String? payload = jsonConvert.convert<String>(json['payload']);
  if (payload != null) {
    printOrdersDataRows.payload = payload;
  }
  final String? shopifyOrderId = jsonConvert.convert<String>(json['shopify_order_id']);
  if (shopifyOrderId != null) {
    printOrdersDataRows.shopifyOrderId = shopifyOrderId;
  }
  final dynamic stripeSessionId = jsonConvert.convert<dynamic>(json['stripe_session_id']);
  if (stripeSessionId != null) {
    printOrdersDataRows.stripeSessionId = stripeSessionId;
  }
  final String? financialStatus = jsonConvert.convert<String>(json['financial_status']);
  if (financialStatus != null) {
    printOrdersDataRows.financialStatus = financialStatus;
  }
  final dynamic fulfillmentStatus = jsonConvert.convert<dynamic>(json['fulfillment_status']);
  if (fulfillmentStatus != null) {
    printOrdersDataRows.fulfillmentStatus = fulfillmentStatus;
  }
  final dynamic userCanvaResourceId = jsonConvert.convert<dynamic>(json['user_canva_resource_id']);
  if (userCanvaResourceId != null) {
    printOrdersDataRows.userCanvaResourceId = userCanvaResourceId;
  }
  final String? psImage = jsonConvert.convert<String>(json['ps_image']);
  if (psImage != null) {
    printOrdersDataRows.psImage = psImage;
  }
  final String? psPreviewImage = jsonConvert.convert<String>(json['ps_preview_image']);
  if (psPreviewImage != null) {
    printOrdersDataRows.psPreviewImage = psPreviewImage;
  }
  final String? shippingMethod = jsonConvert.convert<String>(json['shipping_method']);
  if (shippingMethod != null) {
    printOrdersDataRows.shippingMethod = shippingMethod;
  }
  final dynamic shippingPrice = jsonConvert.convert<dynamic>(json['shipping_price']);
  if (shippingPrice != null) {
    printOrdersDataRows.shippingPrice = shippingPrice;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    printOrdersDataRows.name = name;
  }
  final String? created = jsonConvert.convert<String>(json['created']);
  if (created != null) {
    printOrdersDataRows.created = created;
  }
  final String? modified = jsonConvert.convert<String>(json['modified']);
  if (modified != null) {
    printOrdersDataRows.modified = modified;
  }
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    printOrdersDataRows.id = id;
  }
  return printOrdersDataRows;
}

Map<String, dynamic> $PrintOrdersDataRowsToJson(PrintOrdersDataRows entity) {
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
  data['user_canva_resource_id'] = entity.userCanvaResourceId;
  data['ps_image'] = entity.psImage;
  data['ps_preview_image'] = entity.psPreviewImage;
  data['shipping_method'] = entity.shippingMethod;
  data['shipping_price'] = entity.shippingPrice;
  data['name'] = entity.name;
  data['created'] = entity.created;
  data['modified'] = entity.modified;
  data['id'] = entity.id;
  return data;
}

PrintOrdersDataRowsPayload $PrintOrdersDataRowsPayloadFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayload printOrdersDataRowsPayload = PrintOrdersDataRowsPayload();
  final PrintOrdersDataRowsPayloadOrder? order = jsonConvert.convert<PrintOrdersDataRowsPayloadOrder>(json['order']);
  if (order != null) {
    printOrdersDataRowsPayload.order = order;
  }
  final PrintOrdersDataRowsPayloadRepay? repay = jsonConvert.convert<PrintOrdersDataRowsPayloadRepay>(json['repay']);
  if (repay != null) {
    printOrdersDataRowsPayload.repay = repay;
  }
  return printOrdersDataRowsPayload;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadToJson(PrintOrdersDataRowsPayload entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['order'] = entity.order.toJson();
  data['repay'] = entity.repay.toJson();
  return data;
}

PrintOrdersDataRowsPayloadOrder $PrintOrdersDataRowsPayloadOrderFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrder printOrdersDataRowsPayloadOrder = PrintOrdersDataRowsPayloadOrder();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    printOrdersDataRowsPayloadOrder.id = id;
  }
  final String? adminGraphqlApiId = jsonConvert.convert<String>(json['admin_graphql_api_id']);
  if (adminGraphqlApiId != null) {
    printOrdersDataRowsPayloadOrder.adminGraphqlApiId = adminGraphqlApiId;
  }
  final int? appId = jsonConvert.convert<int>(json['app_id']);
  if (appId != null) {
    printOrdersDataRowsPayloadOrder.appId = appId;
  }
  final dynamic browserIp = jsonConvert.convert<dynamic>(json['browser_ip']);
  if (browserIp != null) {
    printOrdersDataRowsPayloadOrder.browserIp = browserIp;
  }
  final bool? buyerAcceptsMarketing = jsonConvert.convert<bool>(json['buyer_accepts_marketing']);
  if (buyerAcceptsMarketing != null) {
    printOrdersDataRowsPayloadOrder.buyerAcceptsMarketing = buyerAcceptsMarketing;
  }
  final dynamic cancelReason = jsonConvert.convert<dynamic>(json['cancel_reason']);
  if (cancelReason != null) {
    printOrdersDataRowsPayloadOrder.cancelReason = cancelReason;
  }
  final dynamic cancelledAt = jsonConvert.convert<dynamic>(json['cancelled_at']);
  if (cancelledAt != null) {
    printOrdersDataRowsPayloadOrder.cancelledAt = cancelledAt;
  }
  final dynamic cartToken = jsonConvert.convert<dynamic>(json['cart_token']);
  if (cartToken != null) {
    printOrdersDataRowsPayloadOrder.cartToken = cartToken;
  }
  final dynamic checkoutId = jsonConvert.convert<dynamic>(json['checkout_id']);
  if (checkoutId != null) {
    printOrdersDataRowsPayloadOrder.checkoutId = checkoutId;
  }
  final dynamic checkoutToken = jsonConvert.convert<dynamic>(json['checkout_token']);
  if (checkoutToken != null) {
    printOrdersDataRowsPayloadOrder.checkoutToken = checkoutToken;
  }
  final dynamic closedAt = jsonConvert.convert<dynamic>(json['closed_at']);
  if (closedAt != null) {
    printOrdersDataRowsPayloadOrder.closedAt = closedAt;
  }
  final bool? confirmed = jsonConvert.convert<bool>(json['confirmed']);
  if (confirmed != null) {
    printOrdersDataRowsPayloadOrder.confirmed = confirmed;
  }
  final dynamic contactEmail = jsonConvert.convert<dynamic>(json['contact_email']);
  if (contactEmail != null) {
    printOrdersDataRowsPayloadOrder.contactEmail = contactEmail;
  }
  final String? createdAt = jsonConvert.convert<String>(json['created_at']);
  if (createdAt != null) {
    printOrdersDataRowsPayloadOrder.createdAt = createdAt;
  }
  final String? currency = jsonConvert.convert<String>(json['currency']);
  if (currency != null) {
    printOrdersDataRowsPayloadOrder.currency = currency;
  }
  final String? currentSubtotalPrice = jsonConvert.convert<String>(json['current_subtotal_price']);
  if (currentSubtotalPrice != null) {
    printOrdersDataRowsPayloadOrder.currentSubtotalPrice = currentSubtotalPrice;
  }
  final PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSet? currentSubtotalPriceSet =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSet>(json['current_subtotal_price_set']);
  if (currentSubtotalPriceSet != null) {
    printOrdersDataRowsPayloadOrder.currentSubtotalPriceSet = currentSubtotalPriceSet;
  }
  final String? currentTotalDiscounts = jsonConvert.convert<String>(json['current_total_discounts']);
  if (currentTotalDiscounts != null) {
    printOrdersDataRowsPayloadOrder.currentTotalDiscounts = currentTotalDiscounts;
  }
  final PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSet? currentTotalDiscountsSet =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSet>(json['current_total_discounts_set']);
  if (currentTotalDiscountsSet != null) {
    printOrdersDataRowsPayloadOrder.currentTotalDiscountsSet = currentTotalDiscountsSet;
  }
  final dynamic currentTotalDutiesSet = jsonConvert.convert<dynamic>(json['current_total_duties_set']);
  if (currentTotalDutiesSet != null) {
    printOrdersDataRowsPayloadOrder.currentTotalDutiesSet = currentTotalDutiesSet;
  }
  final String? currentTotalPrice = jsonConvert.convert<String>(json['current_total_price']);
  if (currentTotalPrice != null) {
    printOrdersDataRowsPayloadOrder.currentTotalPrice = currentTotalPrice;
  }
  final PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSet? currentTotalPriceSet =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSet>(json['current_total_price_set']);
  if (currentTotalPriceSet != null) {
    printOrdersDataRowsPayloadOrder.currentTotalPriceSet = currentTotalPriceSet;
  }
  final String? currentTotalTax = jsonConvert.convert<String>(json['current_total_tax']);
  if (currentTotalTax != null) {
    printOrdersDataRowsPayloadOrder.currentTotalTax = currentTotalTax;
  }
  final PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSet? currentTotalTaxSet =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSet>(json['current_total_tax_set']);
  if (currentTotalTaxSet != null) {
    printOrdersDataRowsPayloadOrder.currentTotalTaxSet = currentTotalTaxSet;
  }
  final dynamic customerLocale = jsonConvert.convert<dynamic>(json['customer_locale']);
  if (customerLocale != null) {
    printOrdersDataRowsPayloadOrder.customerLocale = customerLocale;
  }
  final dynamic deviceId = jsonConvert.convert<dynamic>(json['device_id']);
  if (deviceId != null) {
    printOrdersDataRowsPayloadOrder.deviceId = deviceId;
  }
  final List<dynamic>? discountCodes = jsonConvert.convertListNotNull<dynamic>(json['discount_codes']);
  if (discountCodes != null) {
    printOrdersDataRowsPayloadOrder.discountCodes = discountCodes;
  }
  final String? email = jsonConvert.convert<String>(json['email']);
  if (email != null) {
    printOrdersDataRowsPayloadOrder.email = email;
  }
  final bool? estimatedTaxes = jsonConvert.convert<bool>(json['estimated_taxes']);
  if (estimatedTaxes != null) {
    printOrdersDataRowsPayloadOrder.estimatedTaxes = estimatedTaxes;
  }
  final String? financialStatus = jsonConvert.convert<String>(json['financial_status']);
  if (financialStatus != null) {
    printOrdersDataRowsPayloadOrder.financialStatus = financialStatus;
  }
  final dynamic fulfillmentStatus = jsonConvert.convert<dynamic>(json['fulfillment_status']);
  if (fulfillmentStatus != null) {
    printOrdersDataRowsPayloadOrder.fulfillmentStatus = fulfillmentStatus;
  }
  final String? gateway = jsonConvert.convert<String>(json['gateway']);
  if (gateway != null) {
    printOrdersDataRowsPayloadOrder.gateway = gateway;
  }
  final dynamic landingSite = jsonConvert.convert<dynamic>(json['landing_site']);
  if (landingSite != null) {
    printOrdersDataRowsPayloadOrder.landingSite = landingSite;
  }
  final dynamic landingSiteRef = jsonConvert.convert<dynamic>(json['landing_site_ref']);
  if (landingSiteRef != null) {
    printOrdersDataRowsPayloadOrder.landingSiteRef = landingSiteRef;
  }
  final dynamic locationId = jsonConvert.convert<dynamic>(json['location_id']);
  if (locationId != null) {
    printOrdersDataRowsPayloadOrder.locationId = locationId;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    printOrdersDataRowsPayloadOrder.name = name;
  }
  final String? note = jsonConvert.convert<String>(json['note']);
  if (note != null) {
    printOrdersDataRowsPayloadOrder.note = note;
  }
  final List<dynamic>? noteAttributes = jsonConvert.convertListNotNull<dynamic>(json['note_attributes']);
  if (noteAttributes != null) {
    printOrdersDataRowsPayloadOrder.noteAttributes = noteAttributes;
  }
  final int? number = jsonConvert.convert<int>(json['number']);
  if (number != null) {
    printOrdersDataRowsPayloadOrder.number = number;
  }
  final int? orderNumber = jsonConvert.convert<int>(json['order_number']);
  if (orderNumber != null) {
    printOrdersDataRowsPayloadOrder.orderNumber = orderNumber;
  }
  final String? orderStatusUrl = jsonConvert.convert<String>(json['order_status_url']);
  if (orderStatusUrl != null) {
    printOrdersDataRowsPayloadOrder.orderStatusUrl = orderStatusUrl;
  }
  final dynamic originalTotalDutiesSet = jsonConvert.convert<dynamic>(json['original_total_duties_set']);
  if (originalTotalDutiesSet != null) {
    printOrdersDataRowsPayloadOrder.originalTotalDutiesSet = originalTotalDutiesSet;
  }
  final List<dynamic>? paymentGatewayNames = jsonConvert.convertListNotNull<dynamic>(json['payment_gateway_names']);
  if (paymentGatewayNames != null) {
    printOrdersDataRowsPayloadOrder.paymentGatewayNames = paymentGatewayNames;
  }
  final dynamic phone = jsonConvert.convert<dynamic>(json['phone']);
  if (phone != null) {
    printOrdersDataRowsPayloadOrder.phone = phone;
  }
  final String? presentmentCurrency = jsonConvert.convert<String>(json['presentment_currency']);
  if (presentmentCurrency != null) {
    printOrdersDataRowsPayloadOrder.presentmentCurrency = presentmentCurrency;
  }
  final String? processedAt = jsonConvert.convert<String>(json['processed_at']);
  if (processedAt != null) {
    printOrdersDataRowsPayloadOrder.processedAt = processedAt;
  }
  final String? processingMethod = jsonConvert.convert<String>(json['processing_method']);
  if (processingMethod != null) {
    printOrdersDataRowsPayloadOrder.processingMethod = processingMethod;
  }
  final dynamic reference = jsonConvert.convert<dynamic>(json['reference']);
  if (reference != null) {
    printOrdersDataRowsPayloadOrder.reference = reference;
  }
  final dynamic referringSite = jsonConvert.convert<dynamic>(json['referring_site']);
  if (referringSite != null) {
    printOrdersDataRowsPayloadOrder.referringSite = referringSite;
  }
  final dynamic sourceIdentifier = jsonConvert.convert<dynamic>(json['source_identifier']);
  if (sourceIdentifier != null) {
    printOrdersDataRowsPayloadOrder.sourceIdentifier = sourceIdentifier;
  }
  final String? sourceName = jsonConvert.convert<String>(json['source_name']);
  if (sourceName != null) {
    printOrdersDataRowsPayloadOrder.sourceName = sourceName;
  }
  final dynamic sourceUrl = jsonConvert.convert<dynamic>(json['source_url']);
  if (sourceUrl != null) {
    printOrdersDataRowsPayloadOrder.sourceUrl = sourceUrl;
  }
  final String? subtotalPrice = jsonConvert.convert<String>(json['subtotal_price']);
  if (subtotalPrice != null) {
    printOrdersDataRowsPayloadOrder.subtotalPrice = subtotalPrice;
  }
  final PrintOrdersDataRowsPayloadOrderSubtotalPriceSet? subtotalPriceSet = jsonConvert.convert<PrintOrdersDataRowsPayloadOrderSubtotalPriceSet>(json['subtotal_price_set']);
  if (subtotalPriceSet != null) {
    printOrdersDataRowsPayloadOrder.subtotalPriceSet = subtotalPriceSet;
  }
  final String? tags = jsonConvert.convert<String>(json['tags']);
  if (tags != null) {
    printOrdersDataRowsPayloadOrder.tags = tags;
  }
  final List<dynamic>? taxLines = jsonConvert.convertListNotNull<dynamic>(json['tax_lines']);
  if (taxLines != null) {
    printOrdersDataRowsPayloadOrder.taxLines = taxLines;
  }
  final bool? taxesIncluded = jsonConvert.convert<bool>(json['taxes_included']);
  if (taxesIncluded != null) {
    printOrdersDataRowsPayloadOrder.taxesIncluded = taxesIncluded;
  }
  final bool? test = jsonConvert.convert<bool>(json['test']);
  if (test != null) {
    printOrdersDataRowsPayloadOrder.test = test;
  }
  final String? token = jsonConvert.convert<String>(json['token']);
  if (token != null) {
    printOrdersDataRowsPayloadOrder.token = token;
  }
  final String? totalDiscounts = jsonConvert.convert<String>(json['total_discounts']);
  if (totalDiscounts != null) {
    printOrdersDataRowsPayloadOrder.totalDiscounts = totalDiscounts;
  }
  final PrintOrdersDataRowsPayloadOrderTotalDiscountsSet? totalDiscountsSet = jsonConvert.convert<PrintOrdersDataRowsPayloadOrderTotalDiscountsSet>(json['total_discounts_set']);
  if (totalDiscountsSet != null) {
    printOrdersDataRowsPayloadOrder.totalDiscountsSet = totalDiscountsSet;
  }
  final String? totalLineItemsPrice = jsonConvert.convert<String>(json['total_line_items_price']);
  if (totalLineItemsPrice != null) {
    printOrdersDataRowsPayloadOrder.totalLineItemsPrice = totalLineItemsPrice;
  }
  final PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSet? totalLineItemsPriceSet =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSet>(json['total_line_items_price_set']);
  if (totalLineItemsPriceSet != null) {
    printOrdersDataRowsPayloadOrder.totalLineItemsPriceSet = totalLineItemsPriceSet;
  }
  final String? totalOutstanding = jsonConvert.convert<String>(json['total_outstanding']);
  if (totalOutstanding != null) {
    printOrdersDataRowsPayloadOrder.totalOutstanding = totalOutstanding;
  }
  final String? totalPrice = jsonConvert.convert<String>(json['total_price']);
  if (totalPrice != null) {
    printOrdersDataRowsPayloadOrder.totalPrice = totalPrice;
  }
  final PrintOrdersDataRowsPayloadOrderTotalPriceSet? totalPriceSet = jsonConvert.convert<PrintOrdersDataRowsPayloadOrderTotalPriceSet>(json['total_price_set']);
  if (totalPriceSet != null) {
    printOrdersDataRowsPayloadOrder.totalPriceSet = totalPriceSet;
  }
  final String? totalPriceUsd = jsonConvert.convert<String>(json['total_price_usd']);
  if (totalPriceUsd != null) {
    printOrdersDataRowsPayloadOrder.totalPriceUsd = totalPriceUsd;
  }
  final PrintOrdersDataRowsPayloadOrderTotalShippingPriceSet? totalShippingPriceSet =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderTotalShippingPriceSet>(json['total_shipping_price_set']);
  if (totalShippingPriceSet != null) {
    printOrdersDataRowsPayloadOrder.totalShippingPriceSet = totalShippingPriceSet;
  }
  final String? totalTax = jsonConvert.convert<String>(json['total_tax']);
  if (totalTax != null) {
    printOrdersDataRowsPayloadOrder.totalTax = totalTax;
  }
  final PrintOrdersDataRowsPayloadOrderTotalTaxSet? totalTaxSet = jsonConvert.convert<PrintOrdersDataRowsPayloadOrderTotalTaxSet>(json['total_tax_set']);
  if (totalTaxSet != null) {
    printOrdersDataRowsPayloadOrder.totalTaxSet = totalTaxSet;
  }
  final String? totalTipReceived = jsonConvert.convert<String>(json['total_tip_received']);
  if (totalTipReceived != null) {
    printOrdersDataRowsPayloadOrder.totalTipReceived = totalTipReceived;
  }
  final int? totalWeight = jsonConvert.convert<int>(json['total_weight']);
  if (totalWeight != null) {
    printOrdersDataRowsPayloadOrder.totalWeight = totalWeight;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updated_at']);
  if (updatedAt != null) {
    printOrdersDataRowsPayloadOrder.updatedAt = updatedAt;
  }
  final dynamic userId = jsonConvert.convert<dynamic>(json['user_id']);
  if (userId != null) {
    printOrdersDataRowsPayloadOrder.userId = userId;
  }
  final PrintOrdersDataRowsPayloadOrderCustomer? customer = jsonConvert.convert<PrintOrdersDataRowsPayloadOrderCustomer>(json['customer']);
  if (customer != null) {
    printOrdersDataRowsPayloadOrder.customer = customer;
  }
  final List<dynamic>? discountApplications = jsonConvert.convertListNotNull<dynamic>(json['discount_applications']);
  if (discountApplications != null) {
    printOrdersDataRowsPayloadOrder.discountApplications = discountApplications;
  }
  final List<dynamic>? fulfillments = jsonConvert.convertListNotNull<dynamic>(json['fulfillments']);
  if (fulfillments != null) {
    printOrdersDataRowsPayloadOrder.fulfillments = fulfillments;
  }
  final List<PrintOrdersDataRowsPayloadOrderLineItems>? lineItems = jsonConvert.convertListNotNull<PrintOrdersDataRowsPayloadOrderLineItems>(json['line_items']);
  if (lineItems != null) {
    printOrdersDataRowsPayloadOrder.lineItems = lineItems;
  }
  final dynamic paymentTerms = jsonConvert.convert<dynamic>(json['payment_terms']);
  if (paymentTerms != null) {
    printOrdersDataRowsPayloadOrder.paymentTerms = paymentTerms;
  }
  final List<dynamic>? refunds = jsonConvert.convertListNotNull<dynamic>(json['refunds']);
  if (refunds != null) {
    printOrdersDataRowsPayloadOrder.refunds = refunds;
  }
  final List<dynamic>? shippingLines = jsonConvert.convertListNotNull<dynamic>(json['shipping_lines']);
  if (shippingLines != null) {
    printOrdersDataRowsPayloadOrder.shippingLines = shippingLines;
  }
  return printOrdersDataRowsPayloadOrder;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderToJson(PrintOrdersDataRowsPayloadOrder entity) {
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

PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSet $PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSet printOrdersDataRowsPayloadOrderCurrentSubtotalPriceSet = PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSet();
  final PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoney? shopMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrdersDataRowsPayloadOrderCurrentSubtotalPriceSet.shopMoney = shopMoney;
  }
  final PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrdersDataRowsPayloadOrderCurrentSubtotalPriceSet.presentmentMoney = presentmentMoney;
  }
  return printOrdersDataRowsPayloadOrderCurrentSubtotalPriceSet;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetToJson(PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoney $PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoney printOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoney =
      PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoneyToJson(PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoney $PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoney printOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoney =
      PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoneyToJson(PrintOrdersDataRowsPayloadOrderCurrentSubtotalPriceSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSet $PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSet printOrdersDataRowsPayloadOrderCurrentTotalDiscountsSet = PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSet();
  final PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoney? shopMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalDiscountsSet.shopMoney = shopMoney;
  }
  final PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalDiscountsSet.presentmentMoney = presentmentMoney;
  }
  return printOrdersDataRowsPayloadOrderCurrentTotalDiscountsSet;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetToJson(PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoney $PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoney printOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoney =
      PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoneyToJson(PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoney $PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoneyFromJson(
    Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoney printOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoney =
      PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoneyToJson(
    PrintOrdersDataRowsPayloadOrderCurrentTotalDiscountsSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSet $PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSet printOrdersDataRowsPayloadOrderCurrentTotalPriceSet = PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSet();
  final PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoney? shopMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalPriceSet.shopMoney = shopMoney;
  }
  final PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalPriceSet.presentmentMoney = presentmentMoney;
  }
  return printOrdersDataRowsPayloadOrderCurrentTotalPriceSet;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetToJson(PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoney $PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoney printOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoney =
      PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoneyToJson(PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoney $PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoney printOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoney =
      PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoneyToJson(PrintOrdersDataRowsPayloadOrderCurrentTotalPriceSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSet $PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSet printOrdersDataRowsPayloadOrderCurrentTotalTaxSet = PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSet();
  final PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoney? shopMoney = jsonConvert.convert<PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalTaxSet.shopMoney = shopMoney;
  }
  final PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalTaxSet.presentmentMoney = presentmentMoney;
  }
  return printOrdersDataRowsPayloadOrderCurrentTotalTaxSet;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetToJson(PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoney $PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoney printOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoney =
      PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoneyToJson(PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoney $PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoney printOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoney =
      PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoneyToJson(PrintOrdersDataRowsPayloadOrderCurrentTotalTaxSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderSubtotalPriceSet $PrintOrdersDataRowsPayloadOrderSubtotalPriceSetFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderSubtotalPriceSet printOrdersDataRowsPayloadOrderSubtotalPriceSet = PrintOrdersDataRowsPayloadOrderSubtotalPriceSet();
  final PrintOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoney? shopMoney = jsonConvert.convert<PrintOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrdersDataRowsPayloadOrderSubtotalPriceSet.shopMoney = shopMoney;
  }
  final PrintOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrdersDataRowsPayloadOrderSubtotalPriceSet.presentmentMoney = presentmentMoney;
  }
  return printOrdersDataRowsPayloadOrderSubtotalPriceSet;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderSubtotalPriceSetToJson(PrintOrdersDataRowsPayloadOrderSubtotalPriceSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoney $PrintOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoney printOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoney =
      PrintOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoneyToJson(PrintOrdersDataRowsPayloadOrderSubtotalPriceSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoney $PrintOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoney printOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoney =
      PrintOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoneyToJson(PrintOrdersDataRowsPayloadOrderSubtotalPriceSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderTotalDiscountsSet $PrintOrdersDataRowsPayloadOrderTotalDiscountsSetFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderTotalDiscountsSet printOrdersDataRowsPayloadOrderTotalDiscountsSet = PrintOrdersDataRowsPayloadOrderTotalDiscountsSet();
  final PrintOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoney? shopMoney = jsonConvert.convert<PrintOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrdersDataRowsPayloadOrderTotalDiscountsSet.shopMoney = shopMoney;
  }
  final PrintOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrdersDataRowsPayloadOrderTotalDiscountsSet.presentmentMoney = presentmentMoney;
  }
  return printOrdersDataRowsPayloadOrderTotalDiscountsSet;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderTotalDiscountsSetToJson(PrintOrdersDataRowsPayloadOrderTotalDiscountsSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoney $PrintOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoney printOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoney =
      PrintOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoneyToJson(PrintOrdersDataRowsPayloadOrderTotalDiscountsSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoney $PrintOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoney printOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoney =
      PrintOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoneyToJson(PrintOrdersDataRowsPayloadOrderTotalDiscountsSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSet $PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSet printOrdersDataRowsPayloadOrderTotalLineItemsPriceSet = PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSet();
  final PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoney? shopMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrdersDataRowsPayloadOrderTotalLineItemsPriceSet.shopMoney = shopMoney;
  }
  final PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrdersDataRowsPayloadOrderTotalLineItemsPriceSet.presentmentMoney = presentmentMoney;
  }
  return printOrdersDataRowsPayloadOrderTotalLineItemsPriceSet;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetToJson(PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoney $PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoney printOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoney =
      PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoneyToJson(PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoney $PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoney printOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoney =
      PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoneyToJson(PrintOrdersDataRowsPayloadOrderTotalLineItemsPriceSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderTotalPriceSet $PrintOrdersDataRowsPayloadOrderTotalPriceSetFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderTotalPriceSet printOrdersDataRowsPayloadOrderTotalPriceSet = PrintOrdersDataRowsPayloadOrderTotalPriceSet();
  final PrintOrdersDataRowsPayloadOrderTotalPriceSetShopMoney? shopMoney = jsonConvert.convert<PrintOrdersDataRowsPayloadOrderTotalPriceSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrdersDataRowsPayloadOrderTotalPriceSet.shopMoney = shopMoney;
  }
  final PrintOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrdersDataRowsPayloadOrderTotalPriceSet.presentmentMoney = presentmentMoney;
  }
  return printOrdersDataRowsPayloadOrderTotalPriceSet;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderTotalPriceSetToJson(PrintOrdersDataRowsPayloadOrderTotalPriceSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrdersDataRowsPayloadOrderTotalPriceSetShopMoney $PrintOrdersDataRowsPayloadOrderTotalPriceSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderTotalPriceSetShopMoney printOrdersDataRowsPayloadOrderTotalPriceSetShopMoney = PrintOrdersDataRowsPayloadOrderTotalPriceSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderTotalPriceSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderTotalPriceSetShopMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderTotalPriceSetShopMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderTotalPriceSetShopMoneyToJson(PrintOrdersDataRowsPayloadOrderTotalPriceSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoney $PrintOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoney printOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoney =
      PrintOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoneyToJson(PrintOrdersDataRowsPayloadOrderTotalPriceSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderTotalShippingPriceSet $PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderTotalShippingPriceSet printOrdersDataRowsPayloadOrderTotalShippingPriceSet = PrintOrdersDataRowsPayloadOrderTotalShippingPriceSet();
  final PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoney? shopMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrdersDataRowsPayloadOrderTotalShippingPriceSet.shopMoney = shopMoney;
  }
  final PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrdersDataRowsPayloadOrderTotalShippingPriceSet.presentmentMoney = presentmentMoney;
  }
  return printOrdersDataRowsPayloadOrderTotalShippingPriceSet;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetToJson(PrintOrdersDataRowsPayloadOrderTotalShippingPriceSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoney $PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoney printOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoney =
      PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoneyToJson(PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoney $PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoney printOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoney =
      PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoneyToJson(PrintOrdersDataRowsPayloadOrderTotalShippingPriceSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderTotalTaxSet $PrintOrdersDataRowsPayloadOrderTotalTaxSetFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderTotalTaxSet printOrdersDataRowsPayloadOrderTotalTaxSet = PrintOrdersDataRowsPayloadOrderTotalTaxSet();
  final PrintOrdersDataRowsPayloadOrderTotalTaxSetShopMoney? shopMoney = jsonConvert.convert<PrintOrdersDataRowsPayloadOrderTotalTaxSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrdersDataRowsPayloadOrderTotalTaxSet.shopMoney = shopMoney;
  }
  final PrintOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrdersDataRowsPayloadOrderTotalTaxSet.presentmentMoney = presentmentMoney;
  }
  return printOrdersDataRowsPayloadOrderTotalTaxSet;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderTotalTaxSetToJson(PrintOrdersDataRowsPayloadOrderTotalTaxSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrdersDataRowsPayloadOrderTotalTaxSetShopMoney $PrintOrdersDataRowsPayloadOrderTotalTaxSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderTotalTaxSetShopMoney printOrdersDataRowsPayloadOrderTotalTaxSetShopMoney = PrintOrdersDataRowsPayloadOrderTotalTaxSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderTotalTaxSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderTotalTaxSetShopMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderTotalTaxSetShopMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderTotalTaxSetShopMoneyToJson(PrintOrdersDataRowsPayloadOrderTotalTaxSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoney $PrintOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoney printOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoney =
      PrintOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoneyToJson(PrintOrdersDataRowsPayloadOrderTotalTaxSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderCustomer $PrintOrdersDataRowsPayloadOrderCustomerFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderCustomer printOrdersDataRowsPayloadOrderCustomer = PrintOrdersDataRowsPayloadOrderCustomer();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    printOrdersDataRowsPayloadOrderCustomer.id = id;
  }
  final dynamic email = jsonConvert.convert<dynamic>(json['email']);
  if (email != null) {
    printOrdersDataRowsPayloadOrderCustomer.email = email;
  }
  final bool? acceptsMarketing = jsonConvert.convert<bool>(json['accepts_marketing']);
  if (acceptsMarketing != null) {
    printOrdersDataRowsPayloadOrderCustomer.acceptsMarketing = acceptsMarketing;
  }
  final String? createdAt = jsonConvert.convert<String>(json['created_at']);
  if (createdAt != null) {
    printOrdersDataRowsPayloadOrderCustomer.createdAt = createdAt;
  }
  final String? updatedAt = jsonConvert.convert<String>(json['updated_at']);
  if (updatedAt != null) {
    printOrdersDataRowsPayloadOrderCustomer.updatedAt = updatedAt;
  }
  final String? firstName = jsonConvert.convert<String>(json['first_name']);
  if (firstName != null) {
    printOrdersDataRowsPayloadOrderCustomer.firstName = firstName;
  }
  final String? lastName = jsonConvert.convert<String>(json['last_name']);
  if (lastName != null) {
    printOrdersDataRowsPayloadOrderCustomer.lastName = lastName;
  }
  final String? state = jsonConvert.convert<String>(json['state']);
  if (state != null) {
    printOrdersDataRowsPayloadOrderCustomer.state = state;
  }
  final dynamic note = jsonConvert.convert<dynamic>(json['note']);
  if (note != null) {
    printOrdersDataRowsPayloadOrderCustomer.note = note;
  }
  final bool? verifiedEmail = jsonConvert.convert<bool>(json['verified_email']);
  if (verifiedEmail != null) {
    printOrdersDataRowsPayloadOrderCustomer.verifiedEmail = verifiedEmail;
  }
  final dynamic multipassIdentifier = jsonConvert.convert<dynamic>(json['multipass_identifier']);
  if (multipassIdentifier != null) {
    printOrdersDataRowsPayloadOrderCustomer.multipassIdentifier = multipassIdentifier;
  }
  final bool? taxExempt = jsonConvert.convert<bool>(json['tax_exempt']);
  if (taxExempt != null) {
    printOrdersDataRowsPayloadOrderCustomer.taxExempt = taxExempt;
  }
  final dynamic phone = jsonConvert.convert<dynamic>(json['phone']);
  if (phone != null) {
    printOrdersDataRowsPayloadOrderCustomer.phone = phone;
  }
  final dynamic emailMarketingConsent = jsonConvert.convert<dynamic>(json['email_marketing_consent']);
  if (emailMarketingConsent != null) {
    printOrdersDataRowsPayloadOrderCustomer.emailMarketingConsent = emailMarketingConsent;
  }
  final dynamic smsMarketingConsent = jsonConvert.convert<dynamic>(json['sms_marketing_consent']);
  if (smsMarketingConsent != null) {
    printOrdersDataRowsPayloadOrderCustomer.smsMarketingConsent = smsMarketingConsent;
  }
  final String? tags = jsonConvert.convert<String>(json['tags']);
  if (tags != null) {
    printOrdersDataRowsPayloadOrderCustomer.tags = tags;
  }
  final String? currency = jsonConvert.convert<String>(json['currency']);
  if (currency != null) {
    printOrdersDataRowsPayloadOrderCustomer.currency = currency;
  }
  final String? acceptsMarketingUpdatedAt = jsonConvert.convert<String>(json['accepts_marketing_updated_at']);
  if (acceptsMarketingUpdatedAt != null) {
    printOrdersDataRowsPayloadOrderCustomer.acceptsMarketingUpdatedAt = acceptsMarketingUpdatedAt;
  }
  final dynamic marketingOptInLevel = jsonConvert.convert<dynamic>(json['marketing_opt_in_level']);
  if (marketingOptInLevel != null) {
    printOrdersDataRowsPayloadOrderCustomer.marketingOptInLevel = marketingOptInLevel;
  }
  final List<dynamic>? taxExemptions = jsonConvert.convertListNotNull<dynamic>(json['tax_exemptions']);
  if (taxExemptions != null) {
    printOrdersDataRowsPayloadOrderCustomer.taxExemptions = taxExemptions;
  }
  final String? adminGraphqlApiId = jsonConvert.convert<String>(json['admin_graphql_api_id']);
  if (adminGraphqlApiId != null) {
    printOrdersDataRowsPayloadOrderCustomer.adminGraphqlApiId = adminGraphqlApiId;
  }
  final PrintOrdersDataRowsPayloadOrderCustomerDefaultAddress? defaultAddress = jsonConvert.convert<PrintOrdersDataRowsPayloadOrderCustomerDefaultAddress>(json['default_address']);
  if (defaultAddress != null) {
    printOrdersDataRowsPayloadOrderCustomer.defaultAddress = defaultAddress;
  }
  return printOrdersDataRowsPayloadOrderCustomer;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderCustomerToJson(PrintOrdersDataRowsPayloadOrderCustomer entity) {
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

PrintOrdersDataRowsPayloadOrderCustomerDefaultAddress $PrintOrdersDataRowsPayloadOrderCustomerDefaultAddressFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderCustomerDefaultAddress printOrdersDataRowsPayloadOrderCustomerDefaultAddress = PrintOrdersDataRowsPayloadOrderCustomerDefaultAddress();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.id = id;
  }
  final int? customerId = jsonConvert.convert<int>(json['customer_id']);
  if (customerId != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.customerId = customerId;
  }
  final String? firstName = jsonConvert.convert<String>(json['first_name']);
  if (firstName != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.firstName = firstName;
  }
  final String? lastName = jsonConvert.convert<String>(json['last_name']);
  if (lastName != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.lastName = lastName;
  }
  final dynamic company = jsonConvert.convert<dynamic>(json['company']);
  if (company != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.company = company;
  }
  final String? address1 = jsonConvert.convert<String>(json['address1']);
  if (address1 != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.address1 = address1;
  }
  final String? address2 = jsonConvert.convert<String>(json['address2']);
  if (address2 != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.address2 = address2;
  }
  final dynamic city = jsonConvert.convert<dynamic>(json['city']);
  if (city != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.city = city;
  }
  final dynamic province = jsonConvert.convert<dynamic>(json['province']);
  if (province != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.province = province;
  }
  final dynamic country = jsonConvert.convert<dynamic>(json['country']);
  if (country != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.country = country;
  }
  final dynamic zip = jsonConvert.convert<dynamic>(json['zip']);
  if (zip != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.zip = zip;
  }
  final String? phone = jsonConvert.convert<String>(json['phone']);
  if (phone != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.phone = phone;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.name = name;
  }
  final dynamic provinceCode = jsonConvert.convert<dynamic>(json['province_code']);
  if (provinceCode != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.provinceCode = provinceCode;
  }
  final dynamic countryCode = jsonConvert.convert<dynamic>(json['country_code']);
  if (countryCode != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.countryCode = countryCode;
  }
  final dynamic countryName = jsonConvert.convert<dynamic>(json['country_name']);
  if (countryName != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.countryName = countryName;
  }
  final bool? xDefault = jsonConvert.convert<bool>(json['default']);
  if (xDefault != null) {
    printOrdersDataRowsPayloadOrderCustomerDefaultAddress.xDefault = xDefault;
  }
  return printOrdersDataRowsPayloadOrderCustomerDefaultAddress;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderCustomerDefaultAddressToJson(PrintOrdersDataRowsPayloadOrderCustomerDefaultAddress entity) {
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

PrintOrdersDataRowsPayloadOrderLineItems $PrintOrdersDataRowsPayloadOrderLineItemsFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderLineItems printOrdersDataRowsPayloadOrderLineItems = PrintOrdersDataRowsPayloadOrderLineItems();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    printOrdersDataRowsPayloadOrderLineItems.id = id;
  }
  final String? adminGraphqlApiId = jsonConvert.convert<String>(json['admin_graphql_api_id']);
  if (adminGraphqlApiId != null) {
    printOrdersDataRowsPayloadOrderLineItems.adminGraphqlApiId = adminGraphqlApiId;
  }
  final int? fulfillableQuantity = jsonConvert.convert<int>(json['fulfillable_quantity']);
  if (fulfillableQuantity != null) {
    printOrdersDataRowsPayloadOrderLineItems.fulfillableQuantity = fulfillableQuantity;
  }
  final String? fulfillmentService = jsonConvert.convert<String>(json['fulfillment_service']);
  if (fulfillmentService != null) {
    printOrdersDataRowsPayloadOrderLineItems.fulfillmentService = fulfillmentService;
  }
  final dynamic fulfillmentStatus = jsonConvert.convert<dynamic>(json['fulfillment_status']);
  if (fulfillmentStatus != null) {
    printOrdersDataRowsPayloadOrderLineItems.fulfillmentStatus = fulfillmentStatus;
  }
  final bool? giftCard = jsonConvert.convert<bool>(json['gift_card']);
  if (giftCard != null) {
    printOrdersDataRowsPayloadOrderLineItems.giftCard = giftCard;
  }
  final int? grams = jsonConvert.convert<int>(json['grams']);
  if (grams != null) {
    printOrdersDataRowsPayloadOrderLineItems.grams = grams;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    printOrdersDataRowsPayloadOrderLineItems.name = name;
  }
  final String? price = jsonConvert.convert<String>(json['price']);
  if (price != null) {
    printOrdersDataRowsPayloadOrderLineItems.price = price;
  }
  final PrintOrdersDataRowsPayloadOrderLineItemsPriceSet? priceSet = jsonConvert.convert<PrintOrdersDataRowsPayloadOrderLineItemsPriceSet>(json['price_set']);
  if (priceSet != null) {
    printOrdersDataRowsPayloadOrderLineItems.priceSet = priceSet;
  }
  final bool? productExists = jsonConvert.convert<bool>(json['product_exists']);
  if (productExists != null) {
    printOrdersDataRowsPayloadOrderLineItems.productExists = productExists;
  }
  final int? productId = jsonConvert.convert<int>(json['product_id']);
  if (productId != null) {
    printOrdersDataRowsPayloadOrderLineItems.productId = productId;
  }
  final List<dynamic>? properties = jsonConvert.convertListNotNull<dynamic>(json['properties']);
  if (properties != null) {
    printOrdersDataRowsPayloadOrderLineItems.properties = properties;
  }
  final int? quantity = jsonConvert.convert<int>(json['quantity']);
  if (quantity != null) {
    printOrdersDataRowsPayloadOrderLineItems.quantity = quantity;
  }
  final bool? requiresShipping = jsonConvert.convert<bool>(json['requires_shipping']);
  if (requiresShipping != null) {
    printOrdersDataRowsPayloadOrderLineItems.requiresShipping = requiresShipping;
  }
  final String? sku = jsonConvert.convert<String>(json['sku']);
  if (sku != null) {
    printOrdersDataRowsPayloadOrderLineItems.sku = sku;
  }
  final bool? taxable = jsonConvert.convert<bool>(json['taxable']);
  if (taxable != null) {
    printOrdersDataRowsPayloadOrderLineItems.taxable = taxable;
  }
  final String? title = jsonConvert.convert<String>(json['title']);
  if (title != null) {
    printOrdersDataRowsPayloadOrderLineItems.title = title;
  }
  final String? totalDiscount = jsonConvert.convert<String>(json['total_discount']);
  if (totalDiscount != null) {
    printOrdersDataRowsPayloadOrderLineItems.totalDiscount = totalDiscount;
  }
  final PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSet? totalDiscountSet =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSet>(json['total_discount_set']);
  if (totalDiscountSet != null) {
    printOrdersDataRowsPayloadOrderLineItems.totalDiscountSet = totalDiscountSet;
  }
  final int? variantId = jsonConvert.convert<int>(json['variant_id']);
  if (variantId != null) {
    printOrdersDataRowsPayloadOrderLineItems.variantId = variantId;
  }
  final String? variantInventoryManagement = jsonConvert.convert<String>(json['variant_inventory_management']);
  if (variantInventoryManagement != null) {
    printOrdersDataRowsPayloadOrderLineItems.variantInventoryManagement = variantInventoryManagement;
  }
  final String? variantTitle = jsonConvert.convert<String>(json['variant_title']);
  if (variantTitle != null) {
    printOrdersDataRowsPayloadOrderLineItems.variantTitle = variantTitle;
  }
  final String? vendor = jsonConvert.convert<String>(json['vendor']);
  if (vendor != null) {
    printOrdersDataRowsPayloadOrderLineItems.vendor = vendor;
  }
  final List<dynamic>? taxLines = jsonConvert.convertListNotNull<dynamic>(json['tax_lines']);
  if (taxLines != null) {
    printOrdersDataRowsPayloadOrderLineItems.taxLines = taxLines;
  }
  final List<dynamic>? duties = jsonConvert.convertListNotNull<dynamic>(json['duties']);
  if (duties != null) {
    printOrdersDataRowsPayloadOrderLineItems.duties = duties;
  }
  final List<dynamic>? discountAllocations = jsonConvert.convertListNotNull<dynamic>(json['discount_allocations']);
  if (discountAllocations != null) {
    printOrdersDataRowsPayloadOrderLineItems.discountAllocations = discountAllocations;
  }
  return printOrdersDataRowsPayloadOrderLineItems;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderLineItemsToJson(PrintOrdersDataRowsPayloadOrderLineItems entity) {
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

PrintOrdersDataRowsPayloadOrderLineItemsPriceSet $PrintOrdersDataRowsPayloadOrderLineItemsPriceSetFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderLineItemsPriceSet printOrdersDataRowsPayloadOrderLineItemsPriceSet = PrintOrdersDataRowsPayloadOrderLineItemsPriceSet();
  final PrintOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoney? shopMoney = jsonConvert.convert<PrintOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrdersDataRowsPayloadOrderLineItemsPriceSet.shopMoney = shopMoney;
  }
  final PrintOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrdersDataRowsPayloadOrderLineItemsPriceSet.presentmentMoney = presentmentMoney;
  }
  return printOrdersDataRowsPayloadOrderLineItemsPriceSet;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderLineItemsPriceSetToJson(PrintOrdersDataRowsPayloadOrderLineItemsPriceSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoney $PrintOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoney printOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoney =
      PrintOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoneyToJson(PrintOrdersDataRowsPayloadOrderLineItemsPriceSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoney $PrintOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoney printOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoney =
      PrintOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoneyToJson(PrintOrdersDataRowsPayloadOrderLineItemsPriceSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSet $PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSet printOrdersDataRowsPayloadOrderLineItemsTotalDiscountSet =
      PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSet();
  final PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoney? shopMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoney>(json['shop_money']);
  if (shopMoney != null) {
    printOrdersDataRowsPayloadOrderLineItemsTotalDiscountSet.shopMoney = shopMoney;
  }
  final PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoney? presentmentMoney =
      jsonConvert.convert<PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoney>(json['presentment_money']);
  if (presentmentMoney != null) {
    printOrdersDataRowsPayloadOrderLineItemsTotalDiscountSet.presentmentMoney = presentmentMoney;
  }
  return printOrdersDataRowsPayloadOrderLineItemsTotalDiscountSet;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetToJson(PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSet entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shop_money'] = entity.shopMoney.toJson();
  data['presentment_money'] = entity.presentmentMoney.toJson();
  return data;
}

PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoney $PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoneyFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoney printOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoney =
      PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoneyToJson(PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetShopMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoney $PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoneyFromJson(
    Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoney printOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoney =
      PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoney();
  final String? amount = jsonConvert.convert<String>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoney.amount = amount;
  }
  final String? currencyCode = jsonConvert.convert<String>(json['currency_code']);
  if (currencyCode != null) {
    printOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoney.currencyCode = currencyCode;
  }
  return printOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoney;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoneyToJson(
    PrintOrdersDataRowsPayloadOrderLineItemsTotalDiscountSetPresentmentMoney entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency_code'] = entity.currencyCode;
  return data;
}

PrintOrdersDataRowsPayloadRepay $PrintOrdersDataRowsPayloadRepayFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadRepay printOrdersDataRowsPayloadRepay = PrintOrdersDataRowsPayloadRepay();
  final PrintOrdersDataRowsPayloadRepayProductInfo? productInfo = jsonConvert.convert<PrintOrdersDataRowsPayloadRepayProductInfo>(json['productInfo']);
  if (productInfo != null) {
    printOrdersDataRowsPayloadRepay.productInfo = productInfo;
  }
  final PrintOrdersDataRowsPayloadRepayCustomer? customer = jsonConvert.convert<PrintOrdersDataRowsPayloadRepayCustomer>(json['customer']);
  if (customer != null) {
    printOrdersDataRowsPayloadRepay.customer = customer;
  }
  final PrintOrdersDataRowsPayloadRepayDelivery? delivery = jsonConvert.convert<PrintOrdersDataRowsPayloadRepayDelivery>(json['delivery']);
  if (delivery != null) {
    printOrdersDataRowsPayloadRepay.delivery = delivery;
  }
  final String? image = jsonConvert.convert<String>(json['image']);
  if (image != null) {
    printOrdersDataRowsPayloadRepay.image = image;
  }
  return printOrdersDataRowsPayloadRepay;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadRepayToJson(PrintOrdersDataRowsPayloadRepay entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['productInfo'] = entity.productInfo.toJson();
  data['customer'] = entity.customer.toJson();
  data['delivery'] = entity.delivery.toJson();
  data['image'] = entity.image;
  return data;
}

PrintOrdersDataRowsPayloadRepayProductInfo $PrintOrdersDataRowsPayloadRepayProductInfoFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadRepayProductInfo printOrdersDataRowsPayloadRepayProductInfo = PrintOrdersDataRowsPayloadRepayProductInfo();
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    printOrdersDataRowsPayloadRepayProductInfo.name = name;
  }
  final int? quantity = jsonConvert.convert<int>(json['quantity']);
  if (quantity != null) {
    printOrdersDataRowsPayloadRepayProductInfo.quantity = quantity;
  }
  final String? desc = jsonConvert.convert<String>(json['desc']);
  if (desc != null) {
    printOrdersDataRowsPayloadRepayProductInfo.desc = desc;
  }
  final int? price = jsonConvert.convert<int>(json['price']);
  if (price != null) {
    printOrdersDataRowsPayloadRepayProductInfo.price = price;
  }
  return printOrdersDataRowsPayloadRepayProductInfo;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadRepayProductInfoToJson(PrintOrdersDataRowsPayloadRepayProductInfo entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['name'] = entity.name;
  data['quantity'] = entity.quantity;
  data['desc'] = entity.desc;
  data['price'] = entity.price;
  return data;
}

PrintOrdersDataRowsPayloadRepayCustomer $PrintOrdersDataRowsPayloadRepayCustomerFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadRepayCustomer printOrdersDataRowsPayloadRepayCustomer = PrintOrdersDataRowsPayloadRepayCustomer();
  final String? phone = jsonConvert.convert<String>(json['phone']);
  if (phone != null) {
    printOrdersDataRowsPayloadRepayCustomer.phone = phone;
  }
  final String? firstName = jsonConvert.convert<String>(json['first_name']);
  if (firstName != null) {
    printOrdersDataRowsPayloadRepayCustomer.firstName = firstName;
  }
  final String? lastName = jsonConvert.convert<String>(json['last_name']);
  if (lastName != null) {
    printOrdersDataRowsPayloadRepayCustomer.lastName = lastName;
  }
  final List<PrintOrdersDataRowsPayloadRepayCustomerAddresses>? addresses = jsonConvert.convertListNotNull<PrintOrdersDataRowsPayloadRepayCustomerAddresses>(json['addresses']);
  if (addresses != null) {
    printOrdersDataRowsPayloadRepayCustomer.addresses = addresses;
  }
  return printOrdersDataRowsPayloadRepayCustomer;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadRepayCustomerToJson(PrintOrdersDataRowsPayloadRepayCustomer entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['phone'] = entity.phone;
  data['first_name'] = entity.firstName;
  data['last_name'] = entity.lastName;
  data['addresses'] = entity.addresses.map((v) => v.toJson()).toList();
  return data;
}

PrintOrdersDataRowsPayloadRepayCustomerAddresses $PrintOrdersDataRowsPayloadRepayCustomerAddressesFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadRepayCustomerAddresses printOrdersDataRowsPayloadRepayCustomerAddresses = PrintOrdersDataRowsPayloadRepayCustomerAddresses();
  final String? firstName = jsonConvert.convert<String>(json['first_name']);
  if (firstName != null) {
    printOrdersDataRowsPayloadRepayCustomerAddresses.firstName = firstName;
  }
  final String? lastName = jsonConvert.convert<String>(json['last_name']);
  if (lastName != null) {
    printOrdersDataRowsPayloadRepayCustomerAddresses.lastName = lastName;
  }
  final String? phone = jsonConvert.convert<String>(json['phone']);
  if (phone != null) {
    printOrdersDataRowsPayloadRepayCustomerAddresses.phone = phone;
  }
  final dynamic countryCode = jsonConvert.convert<dynamic>(json['country_code']);
  if (countryCode != null) {
    printOrdersDataRowsPayloadRepayCustomerAddresses.countryCode = countryCode;
  }
  final dynamic countryName = jsonConvert.convert<dynamic>(json['country_name']);
  if (countryName != null) {
    printOrdersDataRowsPayloadRepayCustomerAddresses.countryName = countryName;
  }
  final dynamic country = jsonConvert.convert<dynamic>(json['country']);
  if (country != null) {
    printOrdersDataRowsPayloadRepayCustomerAddresses.country = country;
  }
  final String? address1 = jsonConvert.convert<String>(json['address1']);
  if (address1 != null) {
    printOrdersDataRowsPayloadRepayCustomerAddresses.address1 = address1;
  }
  final String? address2 = jsonConvert.convert<String>(json['address2']);
  if (address2 != null) {
    printOrdersDataRowsPayloadRepayCustomerAddresses.address2 = address2;
  }
  return printOrdersDataRowsPayloadRepayCustomerAddresses;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadRepayCustomerAddressesToJson(PrintOrdersDataRowsPayloadRepayCustomerAddresses entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['first_name'] = entity.firstName;
  data['last_name'] = entity.lastName;
  data['phone'] = entity.phone;
  data['country_code'] = entity.countryCode;
  data['country_name'] = entity.countryName;
  data['country'] = entity.country;
  data['address1'] = entity.address1;
  data['address2'] = entity.address2;
  return data;
}

PrintOrdersDataRowsPayloadRepayDelivery $PrintOrdersDataRowsPayloadRepayDeliveryFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadRepayDelivery printOrdersDataRowsPayloadRepayDelivery = PrintOrdersDataRowsPayloadRepayDelivery();
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    printOrdersDataRowsPayloadRepayDelivery.type = type;
  }
  final PrintOrdersDataRowsPayloadRepayDeliveryFixedAmount? fixedAmount = jsonConvert.convert<PrintOrdersDataRowsPayloadRepayDeliveryFixedAmount>(json['fixed_amount']);
  if (fixedAmount != null) {
    printOrdersDataRowsPayloadRepayDelivery.fixedAmount = fixedAmount;
  }
  final String? displayName = jsonConvert.convert<String>(json['display_name']);
  if (displayName != null) {
    printOrdersDataRowsPayloadRepayDelivery.displayName = displayName;
  }
  return printOrdersDataRowsPayloadRepayDelivery;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadRepayDeliveryToJson(PrintOrdersDataRowsPayloadRepayDelivery entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['type'] = entity.type;
  data['fixed_amount'] = entity.fixedAmount.toJson();
  data['display_name'] = entity.displayName;
  return data;
}

PrintOrdersDataRowsPayloadRepayDeliveryFixedAmount $PrintOrdersDataRowsPayloadRepayDeliveryFixedAmountFromJson(Map<String, dynamic> json) {
  final PrintOrdersDataRowsPayloadRepayDeliveryFixedAmount printOrdersDataRowsPayloadRepayDeliveryFixedAmount = PrintOrdersDataRowsPayloadRepayDeliveryFixedAmount();
  final int? amount = jsonConvert.convert<int>(json['amount']);
  if (amount != null) {
    printOrdersDataRowsPayloadRepayDeliveryFixedAmount.amount = amount;
  }
  final String? currency = jsonConvert.convert<String>(json['currency']);
  if (currency != null) {
    printOrdersDataRowsPayloadRepayDeliveryFixedAmount.currency = currency;
  }
  return printOrdersDataRowsPayloadRepayDeliveryFixedAmount;
}

Map<String, dynamic> $PrintOrdersDataRowsPayloadRepayDeliveryFixedAmountToJson(PrintOrdersDataRowsPayloadRepayDeliveryFixedAmount entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency'] = entity.currency;
  return data;
}
