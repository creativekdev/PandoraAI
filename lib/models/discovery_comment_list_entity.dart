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
  late int? likeId;

  DiscoveryCommentListEntity();

  factory DiscoveryCommentListEntity.fromJson(Map<String, dynamic> json) => $DiscoveryCommentListEntityFromJson(json);

  Map<String, dynamic> toJson() => $DiscoveryCommentListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
