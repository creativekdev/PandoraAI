import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/generate_limit_entity.g.dart';

@JsonSerializable()
class GenerateLimitEntity {
  @JSONField(name: "daily_limit")
  late int dailyLimit;
  @JSONField(name: "used_count")
  late int usedCount;

  GenerateLimitEntity();

  factory GenerateLimitEntity.fromJson(Map<String, dynamic> json) => $GenerateLimitEntityFromJson(json);

  Map<String, dynamic> toJson() => $GenerateLimitEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
