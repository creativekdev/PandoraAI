import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/shipping_method_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class ShippingMethodEntity {
  @JSONField(name: "shipping_rate_data")
  late ShippingMethodShippingRateData shippingRateData;

  ShippingMethodEntity();

  factory ShippingMethodEntity.fromJson(Map<String, dynamic> json) => $ShippingMethodEntityFromJson(json);

  Map<String, dynamic> toJson() => $ShippingMethodEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class ShippingMethodShippingRateData {
  late String type;
  @JSONField(name: "fixed_amount")
  late ShippingMethodShippingRateDataFixedAmount fixedAmount;
  @JSONField(name: "display_name")
  late String displayName;

  ShippingMethodShippingRateData();

  factory ShippingMethodShippingRateData.fromJson(Map<String, dynamic> json) => $ShippingMethodShippingRateDataFromJson(json);

  Map<String, dynamic> toJson() => $ShippingMethodShippingRateDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class ShippingMethodShippingRateDataFixedAmount {
  late int amount;
  late String currency;

  ShippingMethodShippingRateDataFixedAmount();

  factory ShippingMethodShippingRateDataFixedAmount.fromJson(Map<String, dynamic> json) => $ShippingMethodShippingRateDataFixedAmountFromJson(json);

  Map<String, dynamic> toJson() => $ShippingMethodShippingRateDataFixedAmountToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
