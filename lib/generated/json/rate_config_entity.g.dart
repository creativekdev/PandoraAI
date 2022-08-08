import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/rate_config_entity.dart';

RateConfigEntity $RateConfigEntityFromJson(Map<String, dynamic> json) {
	final RateConfigEntity rateConfigEntity = RateConfigEntity();
	final int? firstLoginDate = jsonConvert.convert<int>(json['first_login_date']);
	if (firstLoginDate != null) {
		rateConfigEntity.firstLoginDate = firstLoginDate;
	}
	final int? switchCount = jsonConvert.convert<int>(json['switch_count']);
	if (switchCount != null) {
		rateConfigEntity.switchCount = switchCount;
	}
	final int? nextActivateDate = jsonConvert.convert<int>(json['next_activate_date']);
	if (nextActivateDate != null) {
		rateConfigEntity.nextActivateDate = nextActivateDate;
	}
	return rateConfigEntity;
}

Map<String, dynamic> $RateConfigEntityToJson(RateConfigEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['first_login_date'] = entity.firstLoginDate;
	data['switch_count'] = entity.switchCount;
	data['next_activate_date'] = entity.nextActivateDate;
	return data;
}