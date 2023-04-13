import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/txt2img_result_entity.g.dart';

@JsonSerializable()
class Txt2imgResultEntity {
  late List<String> images;
  late Map<String, dynamic> parameters;
  String? info;
  late String filePath;
  String? s;

  Txt2imgResultEntity({
    List<String>? images,
    Map<String, dynamic>? parameters,
    String? filePath,
  }) {
    this.images = images ?? [];
    this.parameters = parameters ?? {};
    this.filePath = filePath ?? '';
  }

  factory Txt2imgResultEntity.fromJson(Map<String, dynamic> json) => $Txt2imgResultEntityFromJson(json);

  Map<String, dynamic> toJson() => $Txt2imgResultEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
