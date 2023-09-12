import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/txt2img_result_entity.dart';

Txt2imgResultEntity $Txt2imgResultEntityFromJson(Map<String, dynamic> json) {
	final Txt2imgResultEntity txt2imgResultEntity = Txt2imgResultEntity();
	final List<String>? images = jsonConvert.convertListNotNull<String>(json['images']);
	if (images != null) {
		txt2imgResultEntity.images = images;
	}
	final Map<String, dynamic>? parameters = jsonConvert.convert<Map<String, dynamic>>(json['parameters']);
	if (parameters != null) {
		txt2imgResultEntity.parameters = parameters;
	}
	final String? info = jsonConvert.convert<String>(json['info']);
	if (info != null) {
		txt2imgResultEntity.info = info;
	}
	final String? filePath = jsonConvert.convert<String>(json['filePath']);
	if (filePath != null) {
		txt2imgResultEntity.filePath = filePath;
	}
	final String? s = jsonConvert.convert<String>(json['s']);
	if (s != null) {
		txt2imgResultEntity.s = s;
	}
	return txt2imgResultEntity;
}

Map<String, dynamic> $Txt2imgResultEntityToJson(Txt2imgResultEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['images'] =  entity.images;
	data['parameters'] = entity.parameters;
	data['info'] = entity.info;
	data['filePath'] = entity.filePath;
	data['s'] = entity.s;
	return data;
}