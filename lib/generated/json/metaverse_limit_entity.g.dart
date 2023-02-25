import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/metaverse_limit_entity.dart';

MetaverseLimitEntity $MetaverseLimitEntityFromJson(Map<String, dynamic> json) {
	final MetaverseLimitEntity metaverseLimitEntity = MetaverseLimitEntity();
	final int? dailyLimit = jsonConvert.convert<int>(json['daily_limit']);
	if (dailyLimit != null) {
		metaverseLimitEntity.dailyLimit = dailyLimit;
	}
	final int? usedCount = jsonConvert.convert<int>(json['used_count']);
	if (usedCount != null) {
		metaverseLimitEntity.usedCount = usedCount;
	}
	return metaverseLimitEntity;
}

Map<String, dynamic> $MetaverseLimitEntityToJson(MetaverseLimitEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['daily_limit'] = entity.dailyLimit;
	data['used_count'] = entity.usedCount;
	return data;
}