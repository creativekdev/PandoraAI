import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/recent_entity.g.dart';
import 'package:cartoonizer/models/enums/adjust_function.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';

@JsonSerializable()
class RecentStyleMorphModel {
  int updateDt = 0;
  String? originalPath;
  late List<RecentEffectItem> itemList;

  RecentStyleMorphModel({List<RecentEffectItem>? itemList}) {
    this.itemList = itemList ?? [];
  }

  factory RecentStyleMorphModel.fromJson(Map<String, dynamic> json) => $RecentStyleMorphModelFromJson(json);

  Map<String, dynamic> toJson() => $RecentStyleMorphModelToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class RecentEffectModel {
  int updateDt = 0;
  String? originalPath;
  String category;
  late List<RecentEffectItem> itemList;

  RecentEffectModel({this.category = '', List<RecentEffectItem>? itemList}) {
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
  late Map<String, dynamic> parameters;

  RecentGroundEntity({Map<String, dynamic>? parameters}) {
    this.parameters = parameters ?? {};
  }

  factory RecentGroundEntity.fromJson(Map<String, dynamic> json) => $RecentGroundEntityFromJson(json);

  Map<String, dynamic> toJson() => $RecentGroundEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class RecentColoringEntity {
  int updateDt = 0;
  String? filePath;
  String? originFilePath;

  RecentColoringEntity();

  factory RecentColoringEntity.fromJson(Map<String, dynamic> json) => $RecentColoringEntityFromJson(json);

  Map<String, dynamic> toJson() => $RecentColoringEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class RecentImageEditionEntity {
  int updateDt = 0;
  String? filePath;
  String? originFilePath;
  @JSONField(isEnum: true)
  FilterEnum? filter;
  List<RecentAdjustData> adjustData = [];
  List<RecentEffectItem> itemList = [];

  RecentImageEditionEntity();

  factory RecentImageEditionEntity.fromJson(Map<String, dynamic> json) => $RecentImageEditionEntityFromJson(json);

  Map<String, dynamic> toJson() => $RecentImageEditionEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class RecentAdjustData {
  double value = 0;
  @JSONField(name: 'mAdjustFunction')
  String? mAdjustFunctionString;

  @JSONField(serialize: false, deserialize: false)
  AdjustFunction? _mAdjustFunction;

  AdjustFunction get mAdjustFunction {
    if (_mAdjustFunction == null) {
      _mAdjustFunction = AdjustFunctionUtils.build(mAdjustFunctionString);
    }
    return _mAdjustFunction!;
  }

  set mAdjustFunction(AdjustFunction type) {
    _mAdjustFunction = type;
    mAdjustFunctionString = _mAdjustFunction!.value();
  }

  RecentAdjustData();

  factory RecentAdjustData.fromJson(Map<String, dynamic> json) => $RecentAdjustDataFromJson(json);

  Map<String, dynamic> toJson() => $RecentAdjustDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
