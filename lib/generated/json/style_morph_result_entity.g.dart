import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/style_morph_result_entity.dart';

StyleMorphResultEntity $StyleMorphResultEntityFromJson(Map<String, dynamic> json) {
	final StyleMorphResultEntity styleMorphResultEntity = StyleMorphResultEntity();
	final List<String>? images = jsonConvert.convertListNotNull<String>(json['images']);
	if (images != null) {
		styleMorphResultEntity.images = images;
	}
	final Map<String, dynamic>? parameters = jsonConvert.convert<Map<String, dynamic>>(json['parameters']);
	if (parameters != null) {
		styleMorphResultEntity.parameters = parameters;
	}
	final String? info = jsonConvert.convert<String>(json['info']);
	if (info != null) {
		styleMorphResultEntity.info = info;
	}
	final String? filePath = jsonConvert.convert<String>(json['filePath']);
	if (filePath != null) {
		styleMorphResultEntity.filePath = filePath;
	}
	final String? s = jsonConvert.convert<String>(json['s']);
	if (s != null) {
		styleMorphResultEntity.s = s;
	}
	return styleMorphResultEntity;
}

Map<String, dynamic> $StyleMorphResultEntityToJson(StyleMorphResultEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['images'] =  entity.images;
	data['parameters'] = entity.parameters;
	data['info'] = entity.info;
	data['filePath'] = entity.filePath;
	data['s'] = entity.s;
	return data;
}