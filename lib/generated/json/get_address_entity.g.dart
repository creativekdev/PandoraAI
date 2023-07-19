import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/get_address_entity.dart';
import 'package:cartoonizer/models/address_entity.dart';


GetAddressEntity $GetAddressEntityFromJson(Map<String, dynamic> json) {
	final GetAddressEntity getAddressEntity = GetAddressEntity();
	final GetAddressData? data = jsonConvert.convert<GetAddressData>(json['data']);
	if (data != null) {
		getAddressEntity.data = data;
	}
	return getAddressEntity;
}

Map<String, dynamic> $GetAddressEntityToJson(GetAddressEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['data'] = entity.data.toJson();
	return data;
}

GetAddressData $GetAddressDataFromJson(Map<String, dynamic> json) {
	final GetAddressData getAddressData = GetAddressData();
	final GetAddressDataCustomer? customer = jsonConvert.convert<GetAddressDataCustomer>(json['customer']);
	if (customer != null) {
		getAddressData.customer = customer;
	}
	return getAddressData;
}

Map<String, dynamic> $GetAddressDataToJson(GetAddressData entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['customer'] = entity.customer.toJson();
	return data;
}

GetAddressDataCustomer $GetAddressDataCustomerFromJson(Map<String, dynamic> json) {
	final GetAddressDataCustomer getAddressDataCustomer = GetAddressDataCustomer();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		getAddressDataCustomer.id = id;
	}
	final dynamic email = jsonConvert.convert<dynamic>(json['email']);
	if (email != null) {
		getAddressDataCustomer.email = email;
	}
	final bool? acceptsMarketing = jsonConvert.convert<bool>(json['accepts_marketing']);
	if (acceptsMarketing != null) {
		getAddressDataCustomer.acceptsMarketing = acceptsMarketing;
	}
	final String? createdAt = jsonConvert.convert<String>(json['created_at']);
	if (createdAt != null) {
		getAddressDataCustomer.createdAt = createdAt;
	}
	final String? updatedAt = jsonConvert.convert<String>(json['updated_at']);
	if (updatedAt != null) {
		getAddressDataCustomer.updatedAt = updatedAt;
	}
	final String? firstName = jsonConvert.convert<String>(json['first_name']);
	if (firstName != null) {
		getAddressDataCustomer.firstName = firstName;
	}
	final String? lastName = jsonConvert.convert<String>(json['last_name']);
	if (lastName != null) {
		getAddressDataCustomer.lastName = lastName;
	}
	final int? ordersCount = jsonConvert.convert<int>(json['orders_count']);
	if (ordersCount != null) {
		getAddressDataCustomer.ordersCount = ordersCount;
	}
	final String? state = jsonConvert.convert<String>(json['state']);
	if (state != null) {
		getAddressDataCustomer.state = state;
	}
	final String? totalSpent = jsonConvert.convert<String>(json['total_spent']);
	if (totalSpent != null) {
		getAddressDataCustomer.totalSpent = totalSpent;
	}
	final int? lastOrderId = jsonConvert.convert<int>(json['last_order_id']);
	if (lastOrderId != null) {
		getAddressDataCustomer.lastOrderId = lastOrderId;
	}
	final dynamic note = jsonConvert.convert<dynamic>(json['note']);
	if (note != null) {
		getAddressDataCustomer.note = note;
	}
	final bool? verifiedEmail = jsonConvert.convert<bool>(json['verified_email']);
	if (verifiedEmail != null) {
		getAddressDataCustomer.verifiedEmail = verifiedEmail;
	}
	final dynamic multipassIdentifier = jsonConvert.convert<dynamic>(json['multipass_identifier']);
	if (multipassIdentifier != null) {
		getAddressDataCustomer.multipassIdentifier = multipassIdentifier;
	}
	final bool? taxExempt = jsonConvert.convert<bool>(json['tax_exempt']);
	if (taxExempt != null) {
		getAddressDataCustomer.taxExempt = taxExempt;
	}
	final String? tags = jsonConvert.convert<String>(json['tags']);
	if (tags != null) {
		getAddressDataCustomer.tags = tags;
	}
	final String? lastOrderName = jsonConvert.convert<String>(json['last_order_name']);
	if (lastOrderName != null) {
		getAddressDataCustomer.lastOrderName = lastOrderName;
	}
	final String? currency = jsonConvert.convert<String>(json['currency']);
	if (currency != null) {
		getAddressDataCustomer.currency = currency;
	}
	final dynamic phone = jsonConvert.convert<dynamic>(json['phone']);
	if (phone != null) {
		getAddressDataCustomer.phone = phone;
	}
	final List<AddressDataCustomerAddress>? addresses = jsonConvert.convertListNotNull<AddressDataCustomerAddress>(json['addresses']);
	if (addresses != null) {
		getAddressDataCustomer.addresses = addresses;
	}
	final String? acceptsMarketingUpdatedAt = jsonConvert.convert<String>(json['accepts_marketing_updated_at']);
	if (acceptsMarketingUpdatedAt != null) {
		getAddressDataCustomer.acceptsMarketingUpdatedAt = acceptsMarketingUpdatedAt;
	}
	final dynamic marketingOptInLevel = jsonConvert.convert<dynamic>(json['marketing_opt_in_level']);
	if (marketingOptInLevel != null) {
		getAddressDataCustomer.marketingOptInLevel = marketingOptInLevel;
	}
	final List<dynamic>? taxExemptions = jsonConvert.convertListNotNull<dynamic>(json['tax_exemptions']);
	if (taxExemptions != null) {
		getAddressDataCustomer.taxExemptions = taxExemptions;
	}
	final dynamic emailMarketingConsent = jsonConvert.convert<dynamic>(json['email_marketing_consent']);
	if (emailMarketingConsent != null) {
		getAddressDataCustomer.emailMarketingConsent = emailMarketingConsent;
	}
	final dynamic smsMarketingConsent = jsonConvert.convert<dynamic>(json['sms_marketing_consent']);
	if (smsMarketingConsent != null) {
		getAddressDataCustomer.smsMarketingConsent = smsMarketingConsent;
	}
	final String? adminGraphqlApiId = jsonConvert.convert<String>(json['admin_graphql_api_id']);
	if (adminGraphqlApiId != null) {
		getAddressDataCustomer.adminGraphqlApiId = adminGraphqlApiId;
	}
	final AddressDataCustomerAddress? defaultAddress = jsonConvert.convert<AddressDataCustomerAddress>(json['default_address']);
	if (defaultAddress != null) {
		getAddressDataCustomer.defaultAddress = defaultAddress;
	}
	return getAddressDataCustomer;
}

Map<String, dynamic> $GetAddressDataCustomerToJson(GetAddressDataCustomer entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['email'] = entity.email;
	data['accepts_marketing'] = entity.acceptsMarketing;
	data['created_at'] = entity.createdAt;
	data['updated_at'] = entity.updatedAt;
	data['first_name'] = entity.firstName;
	data['last_name'] = entity.lastName;
	data['orders_count'] = entity.ordersCount;
	data['state'] = entity.state;
	data['total_spent'] = entity.totalSpent;
	data['last_order_id'] = entity.lastOrderId;
	data['note'] = entity.note;
	data['verified_email'] = entity.verifiedEmail;
	data['multipass_identifier'] = entity.multipassIdentifier;
	data['tax_exempt'] = entity.taxExempt;
	data['tags'] = entity.tags;
	data['last_order_name'] = entity.lastOrderName;
	data['currency'] = entity.currency;
	data['phone'] = entity.phone;
	data['addresses'] =  entity.addresses.map((v) => v.toJson()).toList();
	data['accepts_marketing_updated_at'] = entity.acceptsMarketingUpdatedAt;
	data['marketing_opt_in_level'] = entity.marketingOptInLevel;
	data['tax_exemptions'] =  entity.taxExemptions;
	data['email_marketing_consent'] = entity.emailMarketingConsent;
	data['sms_marketing_consent'] = entity.smsMarketingConsent;
	data['admin_graphql_api_id'] = entity.adminGraphqlApiId;
	data['default_address'] = entity.defaultAddress.toJson();
	return data;
}