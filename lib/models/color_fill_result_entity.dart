import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/color_fill_result_entity.g.dart';

@JsonSerializable()
class ColorFillResultEntity {
  late List<String> images;
  late Map<String, dynamic> parameters;
  String? info;
  late String filePath;
  String? s;

  ColorFillResultEntity({
    List<String>? images,
    Map<String, dynamic>? parameters,
    String? filePath,
  }) {
    this.images = images ?? [];
    this.parameters = parameters ?? {};
    this.filePath = filePath ?? '';
  }

  factory ColorFillResultEntity.fromJson(Map<String, dynamic> json) => $ColorFillResultEntityFromJson(json);

  Map<String, dynamic> toJson() => $ColorFillResultEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
