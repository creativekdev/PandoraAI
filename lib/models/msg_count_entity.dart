import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/msg_count_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class MsgCountEntity {
  late String action;
  late int count;

  MsgCountEntity();

  factory MsgCountEntity.fromJson(Map<String, dynamic> json) => $MsgCountEntityFromJson(json);

  Map<String, dynamic> toJson() => $MsgCountEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
