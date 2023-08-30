import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/generate_limit_entity.dart';

GenerateLimitEntity $GenerateLimitEntityFromJson(Map<String, dynamic> json) {
  final GenerateLimitEntity generateLimitEntity = GenerateLimitEntity();
  final int? dailyLimit = jsonConvert.convert<int>(json['daily_limit']);
  if (dailyLimit != null) {
    generateLimitEntity.dailyLimit = dailyLimit;
  }
  final int? usedCount = jsonConvert.convert<int>(json['used_count']);
  if (usedCount != null) {
    generateLimitEntity.usedCount = usedCount;
  }
  return generateLimitEntity;
}

Map<String, dynamic> $GenerateLimitEntityToJson(GenerateLimitEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['daily_limit'] = entity.dailyLimit;
  data['used_count'] = entity.usedCount;
  return data;
}
