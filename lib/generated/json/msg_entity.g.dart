import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/msg_entity.dart';

MsgEntity $MsgEntityFromJson(Map<String, dynamic> json) {
	final MsgEntity msgEntity = MsgEntity();
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		msgEntity.id = id;
	}
	final String? title = jsonConvert.convert<String>(json['title']);
	if (title != null) {
		msgEntity.title = title;
	}
	final bool? read = jsonConvert.convert<bool>(json['read']);
	if (read != null) {
		msgEntity.read = read;
	}
	final String? msgType = jsonConvert.convert<String>(json['msgType']);
	if (msgType != null) {
		msgEntity.msgType = msgType;
	}
	return msgEntity;
}

Map<String, dynamic> $MsgEntityToJson(MsgEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['title'] = entity.title;
	data['read'] = entity.read;
	data['msgType'] = entity.msgType;
	return data;
}