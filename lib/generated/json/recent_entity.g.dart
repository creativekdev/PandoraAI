import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/recent_entity.dart';

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
	return recentEffectItem;
}

Map<String, dynamic> $RecentEffectItemToJson(RecentEffectItem entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['key'] = entity.key;
	data['createDt'] = entity.createDt;
	data['imageData'] = entity.imageData;
	data['isVideo'] = entity.isVideo;
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