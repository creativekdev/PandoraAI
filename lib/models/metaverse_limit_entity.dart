import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/metaverse_limit_entity.g.dart';

@JsonSerializable()
class MetaverseLimitEntity {

	@JSONField(name: "daily_limit")
	late int dailyLimit;
	@JSONField(name: "used_count")
	late int usedCount;
  
  MetaverseLimitEntity();

  factory MetaverseLimitEntity.fromJson(Map<String, dynamic> json) => $MetaverseLimitEntityFromJson(json);

  Map<String, dynamic> toJson() => $MetaverseLimitEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}