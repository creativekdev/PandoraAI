import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/ai_ground_style_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class AiGroundStyleEntity {
  late String name;
  dynamic score;
  late String category;
  late String slug;
  String? url;

  AiGroundStyleEntity({
    String? name,
    String? category,
    String? slug,
    String? hash,
  }) {
    this.name = name ?? '';
    this.category = category ?? '';
    this.slug = slug ?? '';
  }

  factory AiGroundStyleEntity.fromJson(Map<String, dynamic> json) => $AiGroundStyleEntityFromJson(json);

  Map<String, dynamic> toJson() => $AiGroundStyleEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
