import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/msg_entity.g.dart';
import 'package:cartoonizer/models/enums/msg_type.dart';

@JsonSerializable()
class MsgEntity {
  late String action;
  late String detail;
  @JSONField(name: 'to_id')
  late int toId;
  @JSONField(name: 'is_system')
  late bool isSystem;
  late bool read;
  @JSONField(name: 'target_id')
  late int targetId;
  @JSONField(name: 'campaign_id')
  late int campaignId;
  @JSONField(name: 'email_campaign_id')
  late int emailCampaignId;
  @JSONField(name: 'email_assignment_id')
  late int emailAssignmentId;
  @JSONField(name: 'product_id')
  late int productId;
  @JSONField(name: 'product_assignment_id')
  late int productAssignmentId;
  @JSONField(name: 'app_name')
  late String appName;
  late String role;
  late String type;
  late String payload;
  late String created;
  late String modified;
  late int id;

  MsgType get msgType => MsgTypeUtils.build(action);

  Map<String, dynamic> get extras {
    try {
      return json.decode(payload);
    } catch (e) {
      return {};
    }
  }

  MsgEntity({
    this.id = 0,
    this.read = false,
    this.created = '',
    this.modified = '',
    this.action = '',
    this.campaignId = 0,
    this.detail = '',
    this.emailAssignmentId = 0,
    this.emailCampaignId = 0,
    this.isSystem = false,
    this.payload = '',
    this.productAssignmentId = 0,
    this.productId = 0,
    this.targetId = 0,
    this.toId = 0,
  });

  factory MsgEntity.fromJson(Map<String, dynamic> json) => $MsgEntityFromJson(json);

  Map<String, dynamic> toJson() => $MsgEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class MsgDiscoveryEntity {
  @JSONField(name: 'user_id')
  int userId = 0;
  @JSONField(name: 'social_post_id')
  int socialPostId = 0;
  @JSONField(name: 'comment_social_post_id')
  int commentSocialPostId = 0;
  @JSONField(name: 'social_post_comment_id')
  int socialPostCommentId = 0;
  @JSONField(name: 'reply_social_post_comment_id')
  int replySocialPostCommentId = 0;
  @JSONField(name: 'reply_user_id')
  int replyUserId = 0;
  @JSONField(name: 'author_user_id')
  int authorUserId = 0;
  String text = '';
  String created = '';
  String modified = '';
  int id = 0;
  String name = '';
  String avatar = '';
  @JSONField(name: 'post_text')
  String postText = '';
  @JSONField(name: 'reply_comment_text')
  String replyCommentText = '';
  @JSONField(name: 'comment_text')
  String commentText = '';
  String ip = '';
  String country = '';
  String region = '';
  String city = '';
  String? status;
  int likes = 0;
  int comments = 0;
  @JSONField(name: 'real_likes')
  int realLikes = 0;

  MsgDiscoveryEntity();

  factory MsgDiscoveryEntity.fromJson(Map<String, dynamic> json) => $MsgDiscoveryEntityFromJson(json);

  Map<String, dynamic> toJson() => $MsgDiscoveryEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

extension MsgDiscoveryEntityEx on MsgDiscoveryEntity {
  int getPostId() {
    if (socialPostId == 0) {
      return commentSocialPostId;
    }
    return socialPostId;
  }
}
