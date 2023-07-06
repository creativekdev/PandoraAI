import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/home_post_entity.dart';

HomePostEntity $HomePostEntityFromJson(Map<String, dynamic> json) {
  final HomePostEntity homePostEntity = HomePostEntity();
  final HomePostData? data = jsonConvert.convert<HomePostData>(json['data']);
  if (data != null) {
    homePostEntity.data = data;
  }
  return homePostEntity;
}

Map<String, dynamic> $HomePostEntityToJson(HomePostEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['data'] = entity.data.toJson();
  return data;
}

HomePostData $HomePostDataFromJson(Map<String, dynamic> json) {
  final HomePostData homePostData = HomePostData();
  final List<DiscoveryListEntity>? rows = jsonConvert.convertListNotNull<DiscoveryListEntity>(json['rows']);
  if (rows != null) {
    homePostData.rows = rows;
  }
  final int? records = jsonConvert.convert<int>(json['records']);
  if (records != null) {
    homePostData.records = records;
  }
  final int? total = jsonConvert.convert<int>(json['total']);
  if (total != null) {
    homePostData.total = total;
  }
  final int? page = jsonConvert.convert<int>(json['page']);
  if (page != null) {
    homePostData.page = page;
  }
  return homePostData;
}

Map<String, dynamic> $HomePostDataToJson(HomePostData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['rows'] = entity.rows.map((v) => v.toJson()).toList();
  data['records'] = entity.records;
  data['total'] = entity.total;
  data['page'] = entity.page;
  return data;
}
