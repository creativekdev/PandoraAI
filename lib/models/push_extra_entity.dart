import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/push_extra_entity.g.dart';

@JsonSerializable()
class PushExtraEntity {

	late String tab;
	late String category;
	late String effect;
  
  PushExtraEntity();

  factory PushExtraEntity.fromJson(Map<String, dynamic> json) => $PushExtraEntityFromJson(json);

  Map<String, dynamic> toJson() => $PushExtraEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}