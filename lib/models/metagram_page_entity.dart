import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/metagram_page_entity.g.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';

@JsonSerializable()
class MetagramPageEntity {
  int records = 0;
  int total = 0;
  int page = 0;
  late List<MetagramItemEntity> rows;
  @JSONField(name: "social_post_page")
  SocialPostPageEntity? socialPostPage;

  MetagramPageEntity({
    this.page = 0,
    this.total = 0,
    this.records = 0,
    this.socialPostPage,
    List<MetagramItemEntity>? rows,
  }) {
    this.rows = rows ?? <MetagramItemEntity>[];
  }

  factory MetagramPageEntity.fromJson(Map<String, dynamic> json) => $MetagramPageEntityFromJson(json);

  Map<String, dynamic> toJson() => $MetagramPageEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class SocialPostPageEntity {
  String? name;
  @JSONField(name: "user_id")
  int? userId;
  @JSONField(name: "core_user_id")
  int? coreUserId;
  @JSONField(name: "cover_image")
  String? coverImage;
  String? status;
  String? payload;
  String? slug;
  String? created;
  String? modified;
  int? id;

  SocialPostPageEntity();

  factory SocialPostPageEntity.fromJson(Map<String, dynamic> json) => $SocialPostPageEntityFromJson(json);

  Map<String, dynamic> toJson() => $SocialPostPageEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class MetagramItemEntity {
  @JSONField(name: 'user_id˚')
  int? userId;
  String? images;
  String? resources;
  String? text;
  int likes = 0;
  @JSONField(name: 'real_likes')
  int realLikes = 0;
  int comments = 0;
  String? ip;
  String? country;
  String? region;
  String? city;
  String? status;
  @JSONField(name: 'cartoonize_key')
  String? cartoonizeKey;
  String? category;
  @JSONField(name: 'social_post_page_id')
  String? socialPostPageId;
  @JSONField(name: 'original_post_url')
  String? originalPostUrl;
  @JSONField(name: 'post_created_at')
  String? postCreatedAt;
  String? payload;
  String? created;
  String? modified;
  int? id;

  MetagramItemEntity();

  factory MetagramItemEntity.fromJson(Map<String, dynamic> json) => $MetagramItemEntityFromJson(json);

  Map<String, dynamic> toJson() => $MetagramItemEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }

  MetagramItemEntity copy() {
    return MetagramItemEntity.fromJson(toJson());
  }

  List<DiscoveryResource> resourceList() {
    try {
      var json = jsonDecode(resources ?? '');
      return (json as List<dynamic>).map((e) => jsonConvert.convert<DiscoveryResource>(e)!).toList().reversed.toList();
    } on FormatException catch (e) {
      return [];
    }
  }
}
