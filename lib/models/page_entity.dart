import 'dart:convert';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/page_entity.g.dart';

@JsonSerializable()
class PageEntity {
  late int records;
  late int total;
  late int page;
  late List<dynamic> rows;

  PageEntity({
    this.page = 0,
    this.total = 0,
    this.records = 0,
    List<dynamic>? rows,
  }) {
    this.rows = rows ?? [];
  }

  factory PageEntity.fromJson(Map<String, dynamic> json) => $PageEntityFromJson(json);

  Map<String, dynamic> toJson() => $PageEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }

  List<T> getDataList<T>() {
    return rows.map((e) => jsonConvert.convert<T>(e)!).toList();
  }
}

@JsonSerializable()
class MsgPageEntity {
  late int records;
  @JSONField(name: "unread_count")
  late int unreadCount;
  late List<dynamic> rows;

  MsgPageEntity({
    this.records = 0,
    this.unreadCount = 0,
    List<dynamic>? rows,
  }) {
    this.rows = rows ?? [];
  }

  factory MsgPageEntity.fromJson(Map<String, dynamic> json) => $MsgPageEntityFromJson(json);

  Map<String, dynamic> toJson() => $MsgPageEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }

  List<T> getDataList<T>() {
    return rows.map((e) => jsonConvert.convert<T>(e)!).toList();
  }
}
