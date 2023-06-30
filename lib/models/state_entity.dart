import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_field.dart';

import '../generated/json/state_entity.g.dart';

@JsonSerializable()
class StateEntity {
  String? code;
  String? name;

  StateEntity();

  factory StateEntity.fromJson(Map<String, dynamic> json) => $StateEntityFromJson(json);

  Map<String, dynamic> toJson() => $StateEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
