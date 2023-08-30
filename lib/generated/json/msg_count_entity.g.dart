import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/msg_count_entity.dart';

MsgCountEntity $MsgCountEntityFromJson(Map<String, dynamic> json) {
  final MsgCountEntity msgCountEntity = MsgCountEntity();
  final String? action = jsonConvert.convert<String>(json['action']);
  if (action != null) {
    msgCountEntity.action = action;
  }
  final int? count = jsonConvert.convert<int>(json['count']);
  if (count != null) {
    msgCountEntity.count = count;
  }
  return msgCountEntity;
}

Map<String, dynamic> $MsgCountEntityToJson(MsgCountEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['action'] = entity.action;
  data['count'] = entity.count;
  return data;
}
