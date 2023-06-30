import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/state_entity.dart';

StateEntity $StateEntityFromJson(Map<String, dynamic> json) {
  final StateEntity stateEntity = StateEntity();
  final String? code = jsonConvert.convert<String>(json['code']);
  if (code != null) {
    stateEntity.code = code;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    stateEntity.name = name;
  }
  return stateEntity;
}

Map<String, dynamic> $StateEntityToJson(StateEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['code'] = entity.code;
  data['name'] = entity.name;
  return data;
}
