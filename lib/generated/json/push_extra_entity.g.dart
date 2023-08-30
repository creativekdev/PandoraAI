import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/push_extra_entity.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';

PushModuleExtraEntity $PushModuleExtraEntityFromJson(Map<String, dynamic> json) {
  final PushModuleExtraEntity pushModuleExtraEntity = PushModuleExtraEntity();
  final String? typeString = jsonConvert.convert<String>(json['type']);
  if (typeString != null) {
    pushModuleExtraEntity.typeString = typeString;
  }
  final String? initKey = jsonConvert.convert<String>(json['initKey']);
  if (initKey != null) {
    pushModuleExtraEntity.initKey = initKey;
  }
  final String? url = jsonConvert.convert<String>(json['url']);
  if (url != null) {
    pushModuleExtraEntity.url = url;
  }
  return pushModuleExtraEntity;
}

Map<String, dynamic> $PushModuleExtraEntityToJson(PushModuleExtraEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['type'] = entity.typeString;
  data['initKey'] = entity.initKey;
  data['url'] = entity.url;
  return data;
}
