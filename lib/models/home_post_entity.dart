import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/home_post_entity.g.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';

@JsonSerializable()
class HomePostEntity {
  late HomePostData data;

  HomePostEntity();

  factory HomePostEntity.fromJson(Map<String, dynamic> json) => $HomePostEntityFromJson(json);

  Map<String, dynamic> toJson() => $HomePostEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class HomePostData {
  late List<DiscoveryListEntity> rows;
  late int records;
  late int total;
  late int page;

  HomePostData();

  factory HomePostData.fromJson(Map<String, dynamic> json) => $HomePostDataFromJson(json);

  Map<String, dynamic> toJson() => $HomePostDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
