import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/discovery_comment_list_entity.g.dart';

@JsonSerializable()
class DiscoveryCommentListEntity {
  @JSONField(name: "user_id")
  late int userId;
  @JSONField(name: "social_post_id")
  late int socialPostId;
  @JSONField(name: "reply_social_post_comment_id")
  late int? replySocialPostCommentId;
  @JSONField(name: "reply_user_id")
  late int? replyUserId;
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
  @JSONField(name: "user_name")
  late String userName;
  @JSONField(name: "user_avatar")
  late String userAvatar;
  @JSONField(name: "like_id")
  int? likeId;

  DiscoveryCommentListEntity({
    this.userName = '',
    this.userAvatar = '',
    this.city = '',
    this.likeId,
    this.id = 0,
    this.likes = 0,
    this.userId = 0,
    this.replySocialPostCommentId,
    this.text = '',
    this.socialPostId = 0,
    this.comments = 0,
    this.images = '',
    this.modified = '',
    this.created = '',
    this.region = '',
    this.country = '',
    this.ip = '',
    this.replyUserId,
  });

  factory DiscoveryCommentListEntity.fromJson(Map<String, dynamic> json) => $DiscoveryCommentListEntityFromJson(json);

  Map<String, dynamic> toJson() => $DiscoveryCommentListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }

  DiscoveryCommentListEntity copy() {
    return DiscoveryCommentListEntity.fromJson(toJson());
  }
}
