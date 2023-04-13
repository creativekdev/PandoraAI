import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'dart:convert';

import 'package:cartoonizer/generated/json/txt2img_style_entity.g.dart';

@JsonSerializable()
class Txt2imgStyleEntity {
  late String name;
  dynamic score;
  late String category;
  late String slug;
  String? url;

  Txt2imgStyleEntity({
    String? name,
    String? category,
    String? slug,
    String? hash,
  }) {
    this.name = name ?? '';
    this.category = category ?? '';
    this.slug = slug ?? '';
  }

  factory Txt2imgStyleEntity.fromJson(Map<String, dynamic> json) => $Txt2imgStyleEntityFromJson(json);

  Map<String, dynamic> toJson() => $Txt2imgStyleEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
