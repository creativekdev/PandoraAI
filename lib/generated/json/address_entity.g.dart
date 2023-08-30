import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/address_entity.dart';

AddressEntity $AddressEntityFromJson(Map<String, dynamic> json) {
  final AddressEntity addressEntity = AddressEntity();
  final AddressData? data = jsonConvert.convert<AddressData>(json['data']);
  if (data != null) {
    addressEntity.data = data;
  }
  return addressEntity;
}

Map<String, dynamic> $AddressEntityToJson(AddressEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['data'] = entity.data.toJson();
  return data;
}

AddressData $AddressDataFromJson(Map<String, dynamic> json) {
  final AddressData addressData = AddressData();
  final AddressDataCustomerAddress? customerAddress = jsonConvert.convert<AddressDataCustomerAddress>(json['customer_address']);
  if (customerAddress != null) {
    addressData.customerAddress = customerAddress;
  }
  return addressData;
}

Map<String, dynamic> $AddressDataToJson(AddressData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['customer_address'] = entity.customerAddress.toJson();
  return data;
}

AddressDataCustomerAddress $AddressDataCustomerAddressFromJson(Map<String, dynamic> json) {
  final AddressDataCustomerAddress addressDataCustomerAddress = AddressDataCustomerAddress();
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    addressDataCustomerAddress.id = id;
  }
  final int? customerId = jsonConvert.convert<int>(json['customer_id']);
  if (customerId != null) {
    addressDataCustomerAddress.customerId = customerId;
  }
  final String? firstName = jsonConvert.convert<String>(json['first_name']);
  if (firstName != null) {
    addressDataCustomerAddress.firstName = firstName;
  }
  final String? lastName = jsonConvert.convert<String>(json['last_name']);
  if (lastName != null) {
    addressDataCustomerAddress.lastName = lastName;
  }
  final dynamic company = jsonConvert.convert<dynamic>(json['company']);
  if (company != null) {
    addressDataCustomerAddress.company = company;
  }
  final String? address1 = jsonConvert.convert<String>(json['address1']);
  if (address1 != null) {
    addressDataCustomerAddress.address1 = address1;
  }
  final String? address2 = jsonConvert.convert<String>(json['address2']);
  if (address2 != null) {
    addressDataCustomerAddress.address2 = address2;
  }
  final String? city = jsonConvert.convert<String>(json['city']);
  if (city != null) {
    addressDataCustomerAddress.city = city;
  }
  final dynamic province = jsonConvert.convert<dynamic>(json['province']);
  if (province != null) {
    addressDataCustomerAddress.province = province;
  }
  final String? country = jsonConvert.convert<String>(json['country']);
  if (country != null) {
    addressDataCustomerAddress.country = country;
  }
  final String? zip = jsonConvert.convert<String>(json['zip']);
  if (zip != null) {
    addressDataCustomerAddress.zip = zip;
  }
  final String? phone = jsonConvert.convert<String>(json['phone']);
  if (phone != null) {
    addressDataCustomerAddress.phone = phone;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    addressDataCustomerAddress.name = name;
  }
  final dynamic provinceCode = jsonConvert.convert<dynamic>(json['province_code']);
  if (provinceCode != null) {
    addressDataCustomerAddress.provinceCode = provinceCode;
  }
  final String? countryCode = jsonConvert.convert<String>(json['country_code']);
  if (countryCode != null) {
    addressDataCustomerAddress.countryCode = countryCode;
  }
  final String? countryName = jsonConvert.convert<String>(json['country_name']);
  if (countryName != null) {
    addressDataCustomerAddress.countryName = countryName;
  }
  final bool? xDefault = jsonConvert.convert<bool>(json['default']);
  if (xDefault != null) {
    addressDataCustomerAddress.xDefault = xDefault;
  }
  return addressDataCustomerAddress;
}

Map<String, dynamic> $AddressDataCustomerAddressToJson(AddressDataCustomerAddress entity) {
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
