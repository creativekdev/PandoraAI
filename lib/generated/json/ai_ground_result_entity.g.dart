import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/ai_ground_result_entity.dart';

AiGroundResultEntity $AiGroundResultEntityFromJson(Map<String, dynamic> json) {
	final AiGroundResultEntity aiGroundResultEntity = AiGroundResultEntity();
	final List<String>? images = jsonConvert.convertListNotNull<String>(json['images']);
	if (images != null) {
		aiGroundResultEntity.images = images;
	}
	final Map<String, dynamic>? parameters = jsonConvert.convert<Map<String, dynamic>>(json['parameters']);
	if (parameters != null) {
		aiGroundResultEntity.parameters = parameters;
	}
	final String? info = jsonConvert.convert<String>(json['info']);
	if (info != null) {
		aiGroundResultEntity.info = info;
	}
	final String? filePath = jsonConvert.convert<String>(json['filePath']);
	if (filePath != null) {
		aiGroundResultEntity.filePath = filePath;
	}
	final String? s = jsonConvert.convert<String>(json['s']);
	if (s != null) {
		aiGroundResultEntity.s = s;
	}
	return aiGroundResultEntity;
}

Map<String, dynamic> $AiGroundResultEntityToJson(AiGroundResultEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['images'] =  entity.images;
	data['parameters'] = entity.parameters;
	data['info'] = entity.info;
	data['filePath'] = entity.filePath;
	data['s'] = entity.s;
	return data;
}