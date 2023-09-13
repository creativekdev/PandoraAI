import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/rate_config_entity.dart';

RateConfigEntity $RateConfigEntityFromJson(Map<String, dynamic> json) {
	final RateConfigEntity rateConfigEntity = RateConfigEntity();
	final int? switchCount = jsonConvert.convert<int>(json['switch_count']);
	if (switchCount != null) {
		rateConfigEntity.switchCount = switchCount;
	}
	final bool? isShowed = jsonConvert.convert<bool>(json['is_showed']);
	if (isShowed != null) {
		rateConfigEntity.isShowed = isShowed;
	}
	return rateConfigEntity;
}

Map<String, dynamic> $RateConfigEntityToJson(RateConfigEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['switch_count'] = entity.switchCount;
	data['is_showed'] = entity.isShowed;
	return data;
}