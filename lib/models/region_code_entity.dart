import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/region_code_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class RegionCodeEntity {
  String? regionName;
  String? callingCode;
  String? regionCode;
  String? regionFlag;
  List<String> regionSyllables = [];

  RegionCodeEntity();

  factory RegionCodeEntity.fromJson(Map<String, dynamic> json) => $RegionCodeEntityFromJson(json);

  Map<String, dynamic> toJson() => $RegionCodeEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
