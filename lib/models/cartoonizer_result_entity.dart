import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/cartoonizer_result_entity.g.dart';

@JsonSerializable()
class CartoonizerResultEntity {
  late List<String> images;
  late Map<String, dynamic> parameters;
  String? info;
  late String filePath;
  String? s;

  CartoonizerResultEntity({
    List<String>? images,
    Map<String, dynamic>? parameters,
    String? filePath,
  }) {
    this.images = images ?? [];
    this.parameters = parameters ?? {};
    this.filePath = filePath ?? '';
  }

  factory CartoonizerResultEntity.fromJson(Map<String, dynamic> json) => $CartoonizerResultEntityFromJson(json);

  Map<String, dynamic> toJson() => $CartoonizerResultEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
