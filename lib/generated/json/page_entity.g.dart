import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/page_entity.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';

PageEntity $PageEntityFromJson(Map<String, dynamic> json) {
  final PageEntity pageEntity = PageEntity();
  final int? records = jsonConvert.convert<int>(json['records']);
  if (records != null) {
    pageEntity.records = records;
  }
  final int? total = jsonConvert.convert<int>(json['total']);
  if (total != null) {
    pageEntity.total = total;
  }
  final int? page = jsonConvert.convert<int>(json['page']);
  if (page != null) {
    pageEntity.page = page;
  }
  final dynamic rows = jsonConvert.convert<dynamic>(json['rows']);
  if (rows != null) {
    pageEntity.rows = rows;
  }
  return pageEntity;
}

Map<String, dynamic> $PageEntityToJson(PageEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['records'] = entity.records;
  data['total'] = entity.total;
  data['page'] = entity.page;
  data['rows'] = entity.rows;
  return data;
}

MsgPageEntity $MsgPageEntityFromJson(Map<String, dynamic> json) {
  final MsgPageEntity msgPageEntity = MsgPageEntity();
  final int? records = jsonConvert.convert<int>(json['records']);
  if (records != null) {
    msgPageEntity.records = records;
  }
  final int? unreadCount = jsonConvert.convert<int>(json['unread_count']);
  if (unreadCount != null) {
    msgPageEntity.unreadCount = unreadCount;
  }
  final dynamic rows = jsonConvert.convert<dynamic>(json['rows']);
  if (rows != null) {
    msgPageEntity.rows = rows;
  }
  return msgPageEntity;
}

Map<String, dynamic> $MsgPageEntityToJson(MsgPageEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['records'] = entity.records;
  data['unread_count'] = entity.unreadCount;
  data['rows'] = entity.rows;
  return data;
}
