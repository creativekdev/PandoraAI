import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/home_card_entity.dart';

HomeCardEntity $HomeCardEntityFromJson(Map<String, dynamic> json) {
	final HomeCardEntity homeCardEntity = HomeCardEntity();
	final String? type = jsonConvert.convert<String>(json['type']);
	if (type != null) {
		homeCardEntity.type = type;
	}
	final String? url = jsonConvert.convert<String>(json['cover_image']);
	if (url != null) {
		homeCardEntity.url = url;
	}
	return homeCardEntity;
}

Map<String, dynamic> $HomeCardEntityToJson(HomeCardEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['type'] = entity.type;
	data['cover_image'] = entity.url;
	return data;
}