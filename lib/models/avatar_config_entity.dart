import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/avatar_config_entity.g.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:common_utils/common_utils.dart';

abstract class AvatarConfig {
  List<String> getRoles();

  List<Map<String, String>> getRoleList();

  Map<String, String> getRoleImages();

  String styleTitle(String role, String style);

  String originalImage(String style);

  List<String> goodImages(String style);

  List<String> examples(String style);

  List<String> badImages(String style);

  String goodHint(String role);

  String badHint(String role);

  String getName(String role);
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
  String originalImage(String style) {
    return data.roles[style]['original_image'];
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
      return locale[role]?['styles']?[style] ?? style;
    }
    String? result;
    for (var value in locale.values) {
      if (value is Map) {
        var res = value['styles']?[style];
        if (res != null) {
          result = res;
          break;
        }
      }
    }
    return result ?? style;
  }

  @override
  String goodHint(String role) {
    return locale[role]['good_hints'];
  }

  @override
  String badHint(String role) {
    return locale[role]['bad_hints'];
  }

  @override
  List<String> getRoles() {
    return data.roles.keys.toList();
  }

  @override
  String getName(String role) {
    return locale[role]['name'] ?? role;
  }

  @override
  List<Map<String, String>> getRoleList() {
    var roles = getRoles();
    List<Map<String, String>> result = [];
    for (var value in roles) {
      Map<String, String> kv;
      if (result.isEmpty || result.last.length == 2) {
        kv = {};
        result.add(kv);
      } else {
        kv = result.last;
      }
      kv[value] = originalImage(value);
    }
    return result;
  }

  @override
  Map<String, String> getRoleImages() {
    var roles = getRoles();
    Map<String, String> result = {};
    for (var value in roles) {
      result[value] = originalImage(value);
    }
    return result;
  }
}

@JsonSerializable()
class AvatarConfigData {
  @JSONField(name: 'pending_time')
  late int pendingTime = 120;
  late Map<String, dynamic> roles;
  @JSONField(name: 'face_check_ratio')
  late int faceCheckRatio = 36;
  @JSONField(name: 'max_image_count')
  late int maxImageCount = 8;
  @JSONField(name: 'min_image_count')
  late int minImageCount = 5;

  AvatarConfigData();

  factory AvatarConfigData.fromJson(Map<String, dynamic> json) => $AvatarConfigDataFromJson(json);

  Map<String, dynamic> toJson() => $AvatarConfigDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
