import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/discovery_list_entity.g.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';

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
  @JSONField(name: 'category')
  String? categoryString;

  @JSONField(serialize: false, deserialize: false)
  HomeCardType? _category;

  HomeCardType get category {
    if (_category == null) {
      _category = HomeCardTypeUtils.build(categoryString);
    }
    return _category!;
  }

  set category(HomeCardType type) {
    _category = type;
    categoryString = _category!.value();
  }

  @JSONField(name: "cartoonize_key")
  late String cartoonizeKey;
  @JSONField(name: "like_id")
  int? likeId;
  late String resources;
  bool removed;
  String? payload;
  @JSONField(name: 'social_post_page_id')
  String? socialPostPageId;

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
    this.payload,
    this.socialPostPageId,
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
      return (json as List<dynamic>).map((e) => jsonConvert.convert<DiscoveryResource>(e)!).toList().reversed.toList();
    } on Exception catch (e) {
      return [];
    }
  }

  DiscoveryListEntity copy() {
    return DiscoveryListEntity.fromJson(toJson());
  }

  String? getPrompt() {
    if (category != 'txt2img') {
      return null;
    }
    try {
      Map<String, dynamic> p = jsonDecode(payload ?? '');
      if (p['displayText'] ?? false) {
        return p['txt2img_params']['prompt'];
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}

@JsonSerializable()
class DiscoveryResource {
  @JSONField(name: 'type')
  String? typeString;
  String? url;

  @JSONField(serialize: false, deserialize: false)
  DiscoveryResourceType? _type;

  DiscoveryResourceType get type {
    if (_type == null) {
      _type = DiscoveryResourceTypeUtil.build(typeString);
    }
    return _type!;
  }

  set type(DiscoveryResourceType type) {
    _type = type;
    typeString = _type!.value();
  }

  DiscoveryResource();

  factory DiscoveryResource.fromJson(Map<String, dynamic> json) => $DiscoveryResourceFromJson(json);

  Map<String, dynamic> toJson() => $DiscoveryResourceToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }

  DiscoveryResource copy() => DiscoveryResource.fromJson(toJson());
}

enum DiscoveryResourceType { image, video, UNDEFINED }

class DiscoveryResourceTypeUtil {
  static DiscoveryResourceType build(String? value) {
    switch (value) {
      case 'image':
        return DiscoveryResourceType.image;
      case 'video':
        return DiscoveryResourceType.video;
      default:
        return DiscoveryResourceType.UNDEFINED;
    }
  }
}

extension DiscoveryResourceTypeEx on DiscoveryResourceType {
  String value() {
    switch (this) {
      case DiscoveryResourceType.image:
        return 'image';
      case DiscoveryResourceType.video:
        return 'video';
      case DiscoveryResourceType.UNDEFINED:
        return '';
    }
  }
}
