import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/avatar_config_entity.g.dart';

abstract class AvatarConfig {
  List<String> getRoles();

  String styleTitle(String role, String style);

  List<String> goodImages(String style);

  List<String> examples(String style);

  List<String> badImages(String style);
}

@JsonSerializable()
class AvatarConfigEntity extends AvatarConfig {
  late AvatarConfigData data;
  late Map<String, dynamic> locale;

  AvatarConfigEntity();

  factory AvatarConfigEntity.fromJson(Map<String, dynamic> json) => $AvatarConfigEntityFromJson(json);

  Map<String, dynamic> toJson() => $AvatarConfigEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }

  @override
  List<String> badImages(String style) {
    var array = data.roles[style]['bad_images'] ?? [];
    var images = (array as List).map((e) => e.toString()).toList();
    return images;
  }

  @override
  List<String> goodImages(String style) {
    var array = data.roles[style]['good_images'] ?? [];
    var images = (array as List).map((e) => e.toString()).toList();
    return images;
  }

  @override
  List<String> examples(String style) {
    var array = data.roles[style]['sample_images'] ?? [];
    var images = (array as List).map((e) => e.toString()).toList();
    return images;
  }

  @override
  String styleTitle(String role, String style) {
    return locale[role]['styles'][style];
  }

  @override
  List<String> getRoles() {
    return data.roles.keys.toList();
  }
}

@JsonSerializable()
class AvatarConfigData {
  late Map<String, dynamic> roles;

  AvatarConfigData();

  factory AvatarConfigData.fromJson(Map<String, dynamic> json) => $AvatarConfigDataFromJson(json);

  Map<String, dynamic> toJson() => $AvatarConfigDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
