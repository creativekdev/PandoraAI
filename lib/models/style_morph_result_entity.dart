import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/style_morph_result_entity.g.dart';

@JsonSerializable()
class StyleMorphResultEntity {
  late List<String> images;
  late Map<String, dynamic> parameters;
  String? info;
  late String filePath;
  String? s;

  StyleMorphResultEntity({
    List<String>? images,
    Map<String, dynamic>? parameters,
    String? filePath,
  }) {
    this.images = images ?? [];
    this.parameters = parameters ?? {};
    this.filePath = filePath ?? '';
  }

  factory StyleMorphResultEntity.fromJson(Map<String, dynamic> json) => $StyleMorphResultEntityFromJson(json);

  Map<String, dynamic> toJson() => $StyleMorphResultEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
