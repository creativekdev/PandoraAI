import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/ai_ground_style_entity.dart';

AiGroundStyleEntity $AiGroundStyleEntityFromJson(Map<String, dynamic> json) {
	final AiGroundStyleEntity aiGroundStyleEntity = AiGroundStyleEntity();
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		aiGroundStyleEntity.name = name;
	}
	final dynamic? score = jsonConvert.convert<dynamic>(json['score']);
	if (score != null) {
		aiGroundStyleEntity.score = score;
	}
	final String? category = jsonConvert.convert<String>(json['category']);
	if (category != null) {
		aiGroundStyleEntity.category = category;
	}
	final String? slug = jsonConvert.convert<String>(json['slug']);
	if (slug != null) {
		aiGroundStyleEntity.slug = slug;
	}
	final String? url = jsonConvert.convert<String>(json['url']);
	if (url != null) {
		aiGroundStyleEntity.url = url;
	}
	return aiGroundStyleEntity;
}

Map<String, dynamic> $AiGroundStyleEntityToJson(AiGroundStyleEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['name'] = entity.name;
	data['score'] = entity.score;
	data['category'] = entity.category;
	data['slug'] = entity.slug;
	data['url'] = entity.url;
	return data;
}