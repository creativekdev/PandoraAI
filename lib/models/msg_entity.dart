import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/msg_entity.g.dart';
import 'package:cartoonizer/models/enums/msg_type.dart';

@JsonSerializable()
class MsgEntity {
  late int id;
  late String title;
  late bool read;
  late String msgType;

  MsgType get type => MsgTypeUtils.build(msgType);

  MsgEntity({
    this.id = 0,
    this.title = '',
    this.read = false,
    this.msgType = 'notice',
  });

  factory MsgEntity.fromJson(Map<String, dynamic> json) => $MsgEntityFromJson(json);

  Map<String, dynamic> toJson() => $MsgEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
