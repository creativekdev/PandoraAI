import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'dart:ui';

import 'package:cartoonizer/models/enums/adjust_function.dart';

import 'package:cartoonizer/views/mine/filter/Filter.dart';


RecentStyleMorphModel $RecentStyleMorphModelFromJson(Map<String, dynamic> json) {
	final RecentStyleMorphModel recentStyleMorphModel = RecentStyleMorphModel();
	final int? updateDt = jsonConvert.convert<int>(json['updateDt']);
	if (updateDt != null) {
		recentStyleMorphModel.updateDt = updateDt;
	}
	final String? originalPath = jsonConvert.convert<String>(json['originalPath']);
	if (originalPath != null) {
		recentStyleMorphModel.originalPath = originalPath;
	}
	final List<RecentEffectItem>? itemList = jsonConvert.convertListNotNull<RecentEffectItem>(json['itemList']);
	if (itemList != null) {
		recentStyleMorphModel.itemList = itemList;
	}
	return recentStyleMorphModel;
}

Map<String, dynamic> $RecentStyleMorphModelToJson(RecentStyleMorphModel entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['updateDt'] = entity.updateDt;
	data['originalPath'] = entity.originalPath;
	data['itemList'] =  entity.itemList.map((v) => v.toJson()).toList();
	return data;
}

RecentEffectModel $RecentEffectModelFromJson(Map<String, dynamic> json) {
	final RecentEffectModel recentEffectModel = RecentEffectModel();
	final int? updateDt = jsonConvert.convert<int>(json['updateDt']);
	if (updateDt != null) {
		recentEffectModel.updateDt = updateDt;
	}
	final String? originalPath = jsonConvert.convert<String>(json['originalPath']);
	if (originalPath != null) {
		recentEffectModel.originalPath = originalPath;
	}
	final String? category = jsonConvert.convert<String>(json['category']);
	if (category != null) {
		recentEffectModel.category = category;
	}
	final List<RecentEffectItem>? itemList = jsonConvert.convertListNotNull<RecentEffectItem>(json['itemList']);
	if (itemList != null) {
		recentEffectModel.itemList = itemList;
	}
	return recentEffectModel;
}

Map<String, dynamic> $RecentEffectModelToJson(RecentEffectModel entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['updateDt'] = entity.updateDt;
	data['originalPath'] = entity.originalPath;
	data['category'] = entity.category;
	data['itemList'] =  entity.itemList.map((v) => v.toJson()).toList();
	return data;
}

RecentEffectItem $RecentEffectItemFromJson(Map<String, dynamic> json) {
	final RecentEffectItem recentEffectItem = RecentEffectItem();
	final String? key = jsonConvert.convert<String>(json['key']);
	if (key != null) {
		recentEffectItem.key = key;
	}
	final int? createDt = jsonConvert.convert<int>(json['createDt']);
	if (createDt != null) {
		recentEffectItem.createDt = createDt;
	}
	final String? imageData = jsonConvert.convert<String>(json['imageData']);
	if (imageData != null) {
		recentEffectItem.imageData = imageData;
	}
	final bool? isVideo = jsonConvert.convert<bool>(json['isVideo']);
	if (isVideo != null) {
		recentEffectItem.isVideo = isVideo;
	}
	final bool? hasWatermark = jsonConvert.convert<bool>(json['hasWatermark']);
	if (hasWatermark != null) {
		recentEffectItem.hasWatermark = hasWatermark;
	}
	return recentEffectItem;
}

Map<String, dynamic> $RecentEffectItemToJson(RecentEffectItem entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['key'] = entity.key;
	data['createDt'] = entity.createDt;
	data['imageData'] = entity.imageData;
	data['isVideo'] = entity.isVideo;
	data['hasWatermark'] = entity.hasWatermark;
	return data;
}

RecentMetaverseEntity $RecentMetaverseEntityFromJson(Map<String, dynamic> json) {
	final RecentMetaverseEntity recentMetaverseEntity = RecentMetaverseEntity();
	final int? updateDt = jsonConvert.convert<int>(json['updateDt']);
	if (updateDt != null) {
		recentMetaverseEntity.updateDt = updateDt;
	}
	final String? originalPath = jsonConvert.convert<String>(json['originalPath']);
	if (originalPath != null) {
		recentMetaverseEntity.originalPath = originalPath;
	}
	final List<String>? filePath = jsonConvert.convertListNotNull<String>(json['filePath']);
	if (filePath != null) {
		recentMetaverseEntity.filePath = filePath;
	}
	return recentMetaverseEntity;
}

Map<String, dynamic> $RecentMetaverseEntityToJson(RecentMetaverseEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['updateDt'] = entity.updateDt;
	data['originalPath'] = entity.originalPath;
	data['filePath'] =  entity.filePath;
	return data;
}

RecentGroundEntity $RecentGroundEntityFromJson(Map<String, dynamic> json) {
	final RecentGroundEntity recentGroundEntity = RecentGroundEntity();
	final int? updateDt = jsonConvert.convert<int>(json['updateDt']);
	if (updateDt != null) {
		recentGroundEntity.updateDt = updateDt;
	}
	final String? prompt = jsonConvert.convert<String>(json['prompt']);
	if (prompt != null) {
		recentGroundEntity.prompt = prompt;
	}
	final String? filePath = jsonConvert.convert<String>(json['filePath']);
	if (filePath != null) {
		recentGroundEntity.filePath = filePath;
	}
	final String? styleKey = jsonConvert.convert<String>(json['styleKey']);
	if (styleKey != null) {
		recentGroundEntity.styleKey = styleKey;
	}
	final String? initImageFilePath = jsonConvert.convert<String>(json['initImageFilePath']);
	if (initImageFilePath != null) {
		recentGroundEntity.initImageFilePath = initImageFilePath;
	}
	final Map<String, dynamic>? parameters = jsonConvert.convert<Map<String, dynamic>>(json['parameters']);
	if (parameters != null) {
		recentGroundEntity.parameters = parameters;
	}
	return recentGroundEntity;
}

Map<String, dynamic> $RecentGroundEntityToJson(RecentGroundEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['updateDt'] = entity.updateDt;
	data['prompt'] = entity.prompt;
	data['filePath'] = entity.filePath;
	data['styleKey'] = entity.styleKey;
	data['initImageFilePath'] = entity.initImageFilePath;
	data['parameters'] = entity.parameters;
	return data;
}

RecentColoringEntity $RecentColoringEntityFromJson(Map<String, dynamic> json) {
	final RecentColoringEntity recentColoringEntity = RecentColoringEntity();
	final int? updateDt = jsonConvert.convert<int>(json['updateDt']);
	if (updateDt != null) {
		recentColoringEntity.updateDt = updateDt;
	}
	final String? filePath = jsonConvert.convert<String>(json['filePath']);
	if (filePath != null) {
		recentColoringEntity.filePath = filePath;
	}
	final String? originFilePath = jsonConvert.convert<String>(json['originFilePath']);
	if (originFilePath != null) {
		recentColoringEntity.originFilePath = originFilePath;
	}
	return recentColoringEntity;
}

Map<String, dynamic> $RecentColoringEntityToJson(RecentColoringEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['updateDt'] = entity.updateDt;
	data['filePath'] = entity.filePath;
	data['originFilePath'] = entity.originFilePath;
	return data;
}

RecentImageEditionEntity $RecentImageEditionEntityFromJson(Map<String, dynamic> json) {
	final RecentImageEditionEntity recentImageEditionEntity = RecentImageEditionEntity();
	final int? updateDt = jsonConvert.convert<int>(json['updateDt']);
	if (updateDt != null) {
		recentImageEditionEntity.updateDt = updateDt;
	}
	final String? filePath = jsonConvert.convert<String>(json['filePath']);
	if (filePath != null) {
		recentImageEditionEntity.filePath = filePath;
	}
	final String? originFilePath = jsonConvert.convert<String>(json['originFilePath']);
	if (originFilePath != null) {
		recentImageEditionEntity.originFilePath = originFilePath;
	}
	final FilterEnum? filter = jsonConvert.convert<FilterEnum>(json['filter'], enumConvert: (v) => FilterEnum.values.byName(v));
	if (filter != null) {
		recentImageEditionEntity.filter = filter;
	}
	final List<RecentAdjustData>? adjustData = jsonConvert.convertListNotNull<RecentAdjustData>(json['adjustData']);
	if (adjustData != null) {
		recentImageEditionEntity.adjustData = adjustData;
	}
	final List<RecentEffectItem>? itemList = jsonConvert.convertListNotNull<RecentEffectItem>(json['itemList']);
	if (itemList != null) {
		recentImageEditionEntity.itemList = itemList;
	}
	final double? l = jsonConvert.convert<double>(json['l']);
	if (l != null) {
		recentImageEditionEntity.l = l;
	}
	final double? t = jsonConvert.convert<double>(json['t']);
	if (t != null) {
		recentImageEditionEntity.t = t;
	}
	final double? r = jsonConvert.convert<double>(json['r']);
	if (r != null) {
		recentImageEditionEntity.r = r;
	}
	final double? b = jsonConvert.convert<double>(json['b']);
	if (b != null) {
		recentImageEditionEntity.b = b;
	}
	return recentImageEditionEntity;
}

Map<String, dynamic> $RecentImageEditionEntityToJson(RecentImageEditionEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['updateDt'] = entity.updateDt;
	data['filePath'] = entity.filePath;
	data['originFilePath'] = entity.originFilePath;
	data['filter'] = entity.filter?.name;
	data['adjustData'] =  entity.adjustData.map((v) => v.toJson()).toList();
	data['itemList'] =  entity.itemList.map((v) => v.toJson()).toList();
	data['l'] = entity.l;
	data['t'] = entity.t;
	data['r'] = entity.r;
	data['b'] = entity.b;
	return data;
}

RecentAdjustData $RecentAdjustDataFromJson(Map<String, dynamic> json) {
	final RecentAdjustData recentAdjustData = RecentAdjustData();
	final double? value = jsonConvert.convert<double>(json['value']);
	if (value != null) {
		recentAdjustData.value = value;
	}
	final String? mAdjustFunctionString = jsonConvert.convert<String>(json['mAdjustFunction']);
	if (mAdjustFunctionString != null) {
		recentAdjustData.mAdjustFunctionString = mAdjustFunctionString;
	}
	return recentAdjustData;
}

Map<String, dynamic> $RecentAdjustDataToJson(RecentAdjustData entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['value'] = entity.value;
	data['mAdjustFunction'] = entity.mAdjustFunctionString;
	return data;
}