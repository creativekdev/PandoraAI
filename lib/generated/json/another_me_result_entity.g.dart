import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/another_me_result_entity.dart';

AnotherMeResultEntity $AnotherMeResultEntityFromJson(Map<String, dynamic> json) {
	final AnotherMeResultEntity anotherMeResultEntity = AnotherMeResultEntity();
	final List<String>? images = jsonConvert.convertListNotNull<String>(json['images']);
	if (images != null) {
		anotherMeResultEntity.images = images;
	}
	final Map<String, dynamic>? parameters = jsonConvert.convert<Map<String, dynamic>>(json['parameters']);
	if (parameters != null) {
		anotherMeResultEntity.parameters = parameters;
	}
	final String? info = jsonConvert.convert<String>(json['info']);
	if (info != null) {
		anotherMeResultEntity.info = info;
	}
	return anotherMeResultEntity;
}

Map<String, dynamic> $AnotherMeResultEntityToJson(AnotherMeResultEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['images'] =  entity.images;
	data['parameters'] = entity.parameters;
	data['info'] = entity.info;
	return data;
}