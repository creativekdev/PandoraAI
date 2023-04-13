import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/page_entity.g.dart';

@JsonSerializable()
class PageEntity {
  late int records;
  late int total;
  late int page;
  late dynamic rows;

  PageEntity({
    this.page = 0,
    this.total = 0,
    this.records = 0,
    dynamic rows,
  }) {
    this.rows = rows ?? <dynamic>[];
  }

  factory PageEntity.fromJson(Map<String, dynamic> json) => $PageEntityFromJson(json);

  Map<String, dynamic> toJson() => $PageEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }

  List<T> getDataList<T>() {
    if (rows is List) {
      List<T> result = [];
      for (var e in rows) {
        result.add(jsonConvert.convert<T>(e)!);
      }
      return result;
    } else {
      return <T>[];
    }
  }
}

@JsonSerializable()
class MsgPageEntity {
  late int records;
  @JSONField(name: "unread_count")
  late int unreadCount;
  late dynamic rows;

  MsgPageEntity({
    this.records = 0,
    this.unreadCount = 0,
    dynamic rows,
  }) {
    this.rows = rows ?? <dynamic>[];
  }

  factory MsgPageEntity.fromJson(Map<String, dynamic> json) => $MsgPageEntityFromJson(json);

  Map<String, dynamic> toJson() => $MsgPageEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }

  List<T> getDataList<T>() {
    if (rows is List) {
      List<T> result = [];
      for (var e in rows) {
        result.add(jsonConvert.convert<T>(e)!);
      }
      return result;
    } else {
      return <T>[];
    }
  }
}
