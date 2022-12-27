import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/avatar_config_entity.g.dart';
import 'package:common_utils/common_utils.dart';

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
    if (!TextUtil.isEmpty(role)) {
      return locale[role]['styles'][style] ?? style;
    }
    String? result;
    for (var value in locale.values) {
      var res = value['styles'][style];
      if (res != null) {
        result = res;
        break;
      }
    }
    return result ?? style;
  }

  @override
  List<String> getRoles() {
    return data.roles.keys.toList();
  }
}

@JsonSerializable()
class AvatarConfigData {
  @JSONField(name: 'pending_time')
  late int pendingTime = 120;
  late Map<String, dynamic> roles;

  AvatarConfigData();

  factory AvatarConfigData.fromJson(Map<String, dynamic> json) => $AvatarConfigDataFromJson(json);

  Map<String, dynamic> toJson() => $AvatarConfigDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
