import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
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
  @JSONField(name: "like_id")
  int? likeId;
  late String resources;
  bool removed;

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
    this.city = '',
    this.userName = '',
    this.userAvatar = '',
    this.likeId,
    this.resources = '',
    this.removed = false,
  });

  factory DiscoveryListEntity.fromJson(Map<String, dynamic> json) => $DiscoveryListEntityFromJson(json);

  Map<String, dynamic> toJson() => $DiscoveryListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }

  List<DiscoveryResource> resourceList() {
    try {
      var json = jsonDecode(resources);
      return (json as List<dynamic>).map((e) => jsonConvert.convert<DiscoveryResource>(e)!).toList();
    } on FormatException catch (e) {
      return [];
    }
  }

  DiscoveryListEntity copy() {
    return DiscoveryListEntity.fromJson(toJson());
  }
}

@JsonSerializable()
class DiscoveryResource {
  String? type;
  String? url;

  DiscoveryResource({
    this.type,
    this.url,
  });

  factory DiscoveryResource.fromJson(Map<String, dynamic> json) => $DiscoveryResourceFromJson(json);

  Map<String, dynamic> toJson() => $DiscoveryResourceToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }

  DiscoveryResource copy() => DiscoveryResource.fromJson(toJson());
}

enum DiscoveryResourceType {
  image,
  video,
}

extension DiscoveryResourceTypeEx on DiscoveryResourceType {
  String value() {
    switch (this) {
      case DiscoveryResourceType.image:
        return 'image';
      case DiscoveryResourceType.video:
        return 'video';
    }
  }
}
