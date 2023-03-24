import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/app_feature_entity.g.dart';

@JsonSerializable()
class AppFeatureEntity {
  String? name;
  String? content;
  String? url;
  String? role;
  bool public = false;
  String? payload;
  String? product;
  String? created;

  AppFeatureEntity();

  factory AppFeatureEntity.fromJson(Map<String, dynamic> json) => $AppFeatureEntityFromJson(json);

  Map<String, dynamic> toJson() => $AppFeatureEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

extension AppFeatureEntityEx on AppFeatureEntity {
  AppFeaturePayload? feature() {
    try {
      var decode = json.decode(payload ?? '');
      return jsonConvert.convert<AppFeaturePayload>(decode);
    } on FormatException catch (e) {
      return null;
    }
  }
}

@JsonSerializable()
class AppFeaturePayload {
  String? image;
  String? target;

  AppFeaturePayload();

  factory AppFeaturePayload.fromJson(Map<String, dynamic> json) => $AppFeaturePayloadFromJson(json);

  Map<String, dynamic> toJson() => $AppFeaturePayloadToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
