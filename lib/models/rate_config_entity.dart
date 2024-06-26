import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/rate_config_entity.g.dart';

///
/// RateConfigEntity
/// firstLoginDate: if is 0, not included to judgement.
/// switchCount: if great than 10, clear
/// nextActivateDate: if is 0, means not notice yet.
@JsonSerializable()
class RateConfigEntity {
  @JSONField(name: "switch_count")
  late int switchCount;
  @JSONField(name: "is_showed")
  late bool isShowed;


  RateConfigEntity({
    this.switchCount = 0,
    this.isShowed = false,
  });

  factory RateConfigEntity.fromJson(Map<String, dynamic> json) => $RateConfigEntityFromJson(json);

  Map<String, dynamic> toJson() => $RateConfigEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }

  String print() {
    return 'switchCount: $switchCount, '
        'isShowed: $isShowed';
  }
}
