import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/ai_server_entity.dart';

AiServerEntity $AiServerEntityFromJson(Map<String, dynamic> json) {
  final AiServerEntity aiServerEntity = AiServerEntity();
  final String? key = jsonConvert.convert<String>(json['key']);
  if (key != null) {
    aiServerEntity.key = key;
  }
  final int? anonymousDailyLimit = jsonConvert.convert<int>(json['anonymous_daily_limit']);
  if (anonymousDailyLimit != null) {
    aiServerEntity.anonymousDailyLimit = anonymousDailyLimit;
  }
  final int? userDailyLimit = jsonConvert.convert<int>(json['user_daily_limit']);
  if (userDailyLimit != null) {
    aiServerEntity.userDailyLimit = userDailyLimit;
  }
  final int? planDailyLimit = jsonConvert.convert<int>(json['plan_daily_limit']);
  if (planDailyLimit != null) {
    aiServerEntity.planDailyLimit = planDailyLimit;
  }
  final int? parentDailyLimit = jsonConvert.convert<int>(json['parent_daily_limit']);
  if (parentDailyLimit != null) {
    aiServerEntity.parentDailyLimit = parentDailyLimit;
  }
  final int? childDailyLimit = jsonConvert.convert<int>(json['child_daily_limit']);
  if (childDailyLimit != null) {
    aiServerEntity.childDailyLimit = childDailyLimit;
  }
  final String? server = jsonConvert.convert<String>(json['server']);
  if (server != null) {
    aiServerEntity.server = server;
  }
  final String? cnServer = jsonConvert.convert<String>(json['cn_server']);
  if (cnServer != null) {
    aiServerEntity.cnServer = cnServer;
  }
  final String? modified = jsonConvert.convert<String>(json['modified']);
  if (modified != null) {
    aiServerEntity.modified = modified;
  }
  final String? created = jsonConvert.convert<String>(json['created']);
  if (created != null) {
    aiServerEntity.created = created;
  }
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    aiServerEntity.id = id;
  }
  return aiServerEntity;
}

Map<String, dynamic> $AiServerEntityToJson(AiServerEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['key'] = entity.key;
  data['anonymous_daily_limit'] = entity.anonymousDailyLimit;
  data['user_daily_limit'] = entity.userDailyLimit;
  data['plan_daily_limit'] = entity.planDailyLimit;
  data['parent_daily_limit'] = entity.parentDailyLimit;
  data['child_daily_limit'] = entity.childDailyLimit;
  data['server'] = entity.server;
  data['cn_server'] = entity.cnServer;
  data['modified'] = entity.modified;
  data['created'] = entity.created;
  data['id'] = entity.id;
  return data;
}
