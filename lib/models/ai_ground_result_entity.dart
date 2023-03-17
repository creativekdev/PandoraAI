import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/ai_ground_result_entity.g.dart';

@JsonSerializable()
class AiGroundResultEntity {
  late List<String> images;
  late Map<String, dynamic> parameters;
  String? info;
  late String filePath;
  String? s;

  AiGroundResultEntity({
    List<String>? images,
    Map<String, dynamic>? parameters,
    String? filePath,
  }) {
    this.images = images ?? [];
    this.parameters = parameters ?? {};
    this.filePath = filePath ?? '';
  }

  factory AiGroundResultEntity.fromJson(Map<String, dynamic> json) => $AiGroundResultEntityFromJson(json);

  Map<String, dynamic> toJson() => $AiGroundResultEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
