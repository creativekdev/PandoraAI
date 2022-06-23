import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/discovery_list_entity.g.dart';

@JsonSerializable()
class DiscoveryListEntity {
  @JSONField(name: "user_id")
  late int userId;
  @JSONField(name: "user_name")
  late String userName;
  @JSONField(name: "user_avatar")
  late String userAvatar;
  late String images;
  late String text;
  late int likes;
  late int comments;
  late String ip;
  late String country;
  late String region;
  late String city;
  late String created;
  late String modified;
  late int id;
  late String status;
  @JSONField(name: "cartoonize_key")
  late String cartoonizeKey;

  DiscoveryListEntity({
    this.userId = 0,
    this.images = '',
    this.text = '',
    this.likes = 0,
    this.comments = 0,
    this.ip = '',
    this.country = '',
    this.region = '',
    this.created = '',
    this.modified = '',
    this.id = 0,
    this.status = '',
    this.cartoonizeKey = '',
  });

  factory DiscoveryListEntity.fromJson(Map<String, dynamic> json) => $DiscoveryListEntityFromJson(json);

  Map<String, dynamic> toJson() => $DiscoveryListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
