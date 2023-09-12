import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/cartoonizer_result_entity.dart';

CartoonizerResultEntity $CartoonizerResultEntityFromJson(Map<String, dynamic> json) {
	final CartoonizerResultEntity cartoonizerResultEntity = CartoonizerResultEntity();
	final List<String>? images = jsonConvert.convertListNotNull<String>(json['images']);
	if (images != null) {
		cartoonizerResultEntity.images = images;
	}
	final Map<String, dynamic>? parameters = jsonConvert.convert<Map<String, dynamic>>(json['parameters']);
	if (parameters != null) {
		cartoonizerResultEntity.parameters = parameters;
	}
	final String? info = jsonConvert.convert<String>(json['info']);
	if (info != null) {
		cartoonizerResultEntity.info = info;
	}
	final String? filePath = jsonConvert.convert<String>(json['filePath']);
	if (filePath != null) {
		cartoonizerResultEntity.filePath = filePath;
	}
	final String? s = jsonConvert.convert<String>(json['s']);
	if (s != null) {
		cartoonizerResultEntity.s = s;
	}
	return cartoonizerResultEntity;
}

Map<String, dynamic> $CartoonizerResultEntityToJson(CartoonizerResultEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['images'] =  entity.images;
	data['parameters'] = entity.parameters;
	data['info'] = entity.info;
	data['filePath'] = entity.filePath;
	data['s'] = entity.s;
	return data;
}