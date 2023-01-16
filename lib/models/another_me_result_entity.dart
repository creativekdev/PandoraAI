import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/another_me_result_entity.g.dart';

@JsonSerializable()
class AnotherMeResultEntity {
  late List<String> images;
  Map<String, dynamic>? parameters;
  String? info;

  AnotherMeResultEntity({List<String>? images}) {
    this.images = images ?? [];
  }

  factory AnotherMeResultEntity.fromJson(Map<String, dynamic> json) => $AnotherMeResultEntityFromJson(json);

  Map<String, dynamic> toJson() => $AnotherMeResultEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
