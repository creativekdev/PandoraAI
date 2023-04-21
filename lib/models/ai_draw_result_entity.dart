import 'dart:convert';
import 'package:cartoonizer/generated/json/ai_draw_result_entity.g.dart';
import 'package:cartoonizer/generated/json/base/json_field.dart';

@JsonSerializable()
class AiDrawResultEntity {
  late List<String> images;
  late Map<String, dynamic> parameters;
  String? info;
  late List<String> filePath;
  String? s;

  AiDrawResultEntity({
    List<String>? images,
    Map<String, dynamic>? parameters,
    List<String>? filePath,
  }) {
    this.images = images ?? [];
    this.parameters = parameters ?? {};
    this.filePath = filePath ?? [];
  }

  factory AiDrawResultEntity.fromJson(Map<String, dynamic> json) => $AiDrawResultEntityFromJson(json);

  Map<String, dynamic> toJson() => $AiDrawResultEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
