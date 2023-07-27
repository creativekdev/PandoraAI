import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/get_address_entity.g.dart';
import 'package:cartoonizer/models/address_entity.dart';

@JsonSerializable()
class GetAddressEntity {
  GetAddressData? data;

  GetAddressEntity();

  factory GetAddressEntity.fromJson(Map<String, dynamic> json) => $GetAddressEntityFromJson(json);

  Map<String, dynamic> toJson() => $GetAddressEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class GetAddressData {
  late GetAddressDataCustomer customer;

  GetAddressData();

  factory GetAddressData.fromJson(Map<String, dynamic> json) => $GetAddressDataFromJson(json);

  Map<String, dynamic> toJson() => $GetAddressDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class GetAddressDataCustomer {
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
  @JSONField(name: "orders_count")
  late int ordersCount;
  late String state;
  @JSONField(name: "total_spent")
  late String totalSpent;
  @JSONField(name: "last_order_id")
  late int lastOrderId;
  dynamic note;
  @JSONField(name: "verified_email")
  late bool verifiedEmail;
  @JSONField(name: "multipass_identifier")
  dynamic multipassIdentifier;
  @JSONField(name: "tax_exempt")
  late bool taxExempt;
  late String tags;
  @JSONField(name: "last_order_name")
  late String lastOrderName;
  late String currency;
  dynamic phone;
  late List<AddressDataCustomerAddress> addresses;
  @JSONField(name: "accepts_marketing_updated_at")
  late String acceptsMarketingUpdatedAt;
  @JSONField(name: "marketing_opt_in_level")
  dynamic marketingOptInLevel;
  @JSONField(name: "tax_exemptions")
  late List<dynamic> taxExemptions;
  @JSONField(name: "email_marketing_consent")
  dynamic emailMarketingConsent;
  @JSONField(name: "sms_marketing_consent")
  dynamic smsMarketingConsent;
  @JSONField(name: "admin_graphql_api_id")
  late String adminGraphqlApiId;
  @JSONField(name: "default_address")
  late AddressDataCustomerAddress defaultAddress;

  GetAddressDataCustomer();

  factory GetAddressDataCustomer.fromJson(Map<String, dynamic> json) => $GetAddressDataCustomerFromJson(json);

  Map<String, dynamic> toJson() => $GetAddressDataCustomerToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
