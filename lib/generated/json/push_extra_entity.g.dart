import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/push_extra_entity.dart';

PushExtraEntity $PushExtraEntityFromJson(Map<String, dynamic> json) {
	final PushExtraEntity pushExtraEntity = PushExtraEntity();
	final String? tab = jsonConvert.convert<String>(json['tab']);
	if (tab != null) {
		pushExtraEntity.tab = tab;
	}
	final String? category = jsonConvert.convert<String>(json['category']);
	if (category != null) {
		pushExtraEntity.category = category;
	}
	final String? effect = jsonConvert.convert<String>(json['effect']);
	if (effect != null) {
		pushExtraEntity.effect = effect;
	}
	return pushExtraEntity;
}

Map<String, dynamic> $PushExtraEntityToJson(PushExtraEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['tab'] = entity.tab;
	data['category'] = entity.category;
	data['effect'] = entity.effect;
	return data;
}