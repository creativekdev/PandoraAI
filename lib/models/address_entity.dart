import 'dart:convert';

import 'package:cartoonizer/generated/json/address_entity.g.dart';
import 'package:cartoonizer/generated/json/base/json_field.dart';

@JsonSerializable()
class AddressEntity {
  late AddressData data;

  AddressEntity();

  factory AddressEntity.fromJson(Map<String, dynamic> json) => $AddressEntityFromJson(json);

  Map<String, dynamic> toJson() => $AddressEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class AddressData {
  @JSONField(name: "customer_address")
  late AddressDataCustomerAddress customerAddress;

  AddressData();

  factory AddressData.fromJson(Map<String, dynamic> json) => $AddressDataFromJson(json);

  Map<String, dynamic> toJson() => $AddressDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class AddressDataCustomerAddress {
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
  late String city;
  dynamic province;
  late String country;
  late String zip;
  late String phone;
  late String name;
  @JSONField(name: "province_code")
  dynamic provinceCode;
  @JSONField(name: "country_code")
  String? countryCode;
  @JSONField(name: "country_name")
  String? countryName;
  @JSONField(name: "default")
  late bool xDefault;

  AddressDataCustomerAddress();

  factory AddressDataCustomerAddress.fromJson(Map<String, dynamic> json) => $AddressDataCustomerAddressFromJson(json);

  Map<String, dynamic> toJson() => $AddressDataCustomerAddressToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
