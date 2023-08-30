import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/shipping_method_entity.dart';

ShippingMethodEntity $ShippingMethodEntityFromJson(Map<String, dynamic> json) {
  final ShippingMethodEntity shippingMethodEntity = ShippingMethodEntity();
  final ShippingMethodShippingRateData? shippingRateData = jsonConvert.convert<ShippingMethodShippingRateData>(json['shipping_rate_data']);
  if (shippingRateData != null) {
    shippingMethodEntity.shippingRateData = shippingRateData;
  }
  return shippingMethodEntity;
}

Map<String, dynamic> $ShippingMethodEntityToJson(ShippingMethodEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['shipping_rate_data'] = entity.shippingRateData.toJson();
  return data;
}

ShippingMethodShippingRateData $ShippingMethodShippingRateDataFromJson(Map<String, dynamic> json) {
  final ShippingMethodShippingRateData shippingMethodShippingRateData = ShippingMethodShippingRateData();
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    shippingMethodShippingRateData.type = type;
  }
  final ShippingMethodShippingRateDataFixedAmount? fixedAmount = jsonConvert.convert<ShippingMethodShippingRateDataFixedAmount>(json['fixed_amount']);
  if (fixedAmount != null) {
    shippingMethodShippingRateData.fixedAmount = fixedAmount;
  }
  final String? displayName = jsonConvert.convert<String>(json['display_name']);
  if (displayName != null) {
    shippingMethodShippingRateData.displayName = displayName;
  }
  return shippingMethodShippingRateData;
}

Map<String, dynamic> $ShippingMethodShippingRateDataToJson(ShippingMethodShippingRateData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['type'] = entity.type;
  data['fixed_amount'] = entity.fixedAmount.toJson();
  data['display_name'] = entity.displayName;
  return data;
}

ShippingMethodShippingRateDataFixedAmount $ShippingMethodShippingRateDataFixedAmountFromJson(Map<String, dynamic> json) {
  final ShippingMethodShippingRateDataFixedAmount shippingMethodShippingRateDataFixedAmount = ShippingMethodShippingRateDataFixedAmount();
  final int? amount = jsonConvert.convert<int>(json['amount']);
  if (amount != null) {
    shippingMethodShippingRateDataFixedAmount.amount = amount;
  }
  final String? currency = jsonConvert.convert<String>(json['currency']);
  if (currency != null) {
    shippingMethodShippingRateDataFixedAmount.currency = currency;
  }
  return shippingMethodShippingRateDataFixedAmount;
}

Map<String, dynamic> $ShippingMethodShippingRateDataFixedAmountToJson(ShippingMethodShippingRateDataFixedAmount entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['amount'] = entity.amount;
  data['currency'] = entity.currency;
  return data;
}
