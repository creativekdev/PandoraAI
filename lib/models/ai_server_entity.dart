import 'dart:convert';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/generated/json/ai_server_entity.g.dart';
import 'package:cartoonizer/generated/json/base/json_field.dart';

@JsonSerializable()
class AiServerEntity {
  late String key;
  @JSONField(name: 'anonymous_daily_limit')
  int anonymousDailyLimit = 0;
  @JSONField(name: 'user_daily_limit')
  int userDailyLimit = 0;
  @JSONField(name: 'plan_daily_limit')
  int planDailyLimit = 0;
  @JSONField(name: 'parent_daily_limit')
  int parentDailyLimit = 0;
  @JSONField(name: 'child_daily_limit')
  int childDailyLimit = 0;
  String? server;
  @JSONField(name: 'cn_server')
  String? cnServer;
  late String modified;
  late String created;
  late int id;

  AiServerEntity();

  factory AiServerEntity.fromJson(Map<String, dynamic> json) => $AiServerEntityFromJson(json);

  Map<String, dynamic> toJson() => $AiServerEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

extension AiServerEntityEx on AiServerEntity {
  String get serverUrl {
    if (AppContext.currentLocales == 'zh') {
      return cnServer ?? server ?? '';
    }
    return server ?? '';
  }
}
