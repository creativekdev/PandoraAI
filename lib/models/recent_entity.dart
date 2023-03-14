import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/recent_entity.g.dart';

@JsonSerializable()
class RecentEffectModel {
  int updateDt = 0;
  String? originalPath;
  late List<RecentEffectItem> itemList;

  RecentEffectModel({List<RecentEffectItem>? itemList}) {
    this.itemList = itemList ?? [];
  }

  factory RecentEffectModel.fromJson(Map<String, dynamic> json) => $RecentEffectModelFromJson(json);

  Map<String, dynamic> toJson() => $RecentEffectModelToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class RecentEffectItem {
  String? key;
  int createDt = 0;
  String? imageData;
  bool isVideo = false;
  bool hasWatermark = false;

  RecentEffectItem();

  factory RecentEffectItem.fromJson(Map<String, dynamic> json) => $RecentEffectItemFromJson(json);

  Map<String, dynamic> toJson() => $RecentEffectItemToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class RecentMetaverseEntity {
  int updateDt = 0;
  String? originalPath;
  late List<String> filePath;

  RecentMetaverseEntity({List<String>? filePath}) {
    this.filePath = filePath ?? [];
  }

  factory RecentMetaverseEntity.fromJson(Map<String, dynamic> json) => $RecentMetaverseEntityFromJson(json);

  Map<String, dynamic> toJson() => $RecentMetaverseEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class RecentGroundEntity {
  int updateDt = 0;
  String? prompt;
  String? filePath;
  String? styleKey;
  String? initImageFilePath;

  RecentGroundEntity();

  factory RecentGroundEntity.fromJson(Map<String, dynamic> json) => $RecentGroundEntityFromJson(json);

  Map<String, dynamic> toJson() => $RecentGroundEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
