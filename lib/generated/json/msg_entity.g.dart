import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/msg_entity.dart';
import 'package:cartoonizer/models/enums/msg_type.dart';


MsgEntity $MsgEntityFromJson(Map<String, dynamic> json) {
	final MsgEntity msgEntity = MsgEntity();
	final String? action = jsonConvert.convert<String>(json['action']);
	if (action != null) {
		msgEntity.action = action;
	}
	final String? detail = jsonConvert.convert<String>(json['detail']);
	if (detail != null) {
		msgEntity.detail = detail;
	}
	final int? toId = jsonConvert.convert<int>(json['to_id']);
	if (toId != null) {
		msgEntity.toId = toId;
	}
	final bool? isSystem = jsonConvert.convert<bool>(json['is_system']);
	if (isSystem != null) {
		msgEntity.isSystem = isSystem;
	}
	final bool? read = jsonConvert.convert<bool>(json['read']);
	if (read != null) {
		msgEntity.read = read;
	}
	final int? targetId = jsonConvert.convert<int>(json['target_id']);
	if (targetId != null) {
		msgEntity.targetId = targetId;
	}
	final int? campaignId = jsonConvert.convert<int>(json['campaign_id']);
	if (campaignId != null) {
		msgEntity.campaignId = campaignId;
	}
	final int? emailCampaignId = jsonConvert.convert<int>(json['email_campaign_id']);
	if (emailCampaignId != null) {
		msgEntity.emailCampaignId = emailCampaignId;
	}
	final int? emailAssignmentId = jsonConvert.convert<int>(json['email_assignment_id']);
	if (emailAssignmentId != null) {
		msgEntity.emailAssignmentId = emailAssignmentId;
	}
	final int? productId = jsonConvert.convert<int>(json['product_id']);
	if (productId != null) {
		msgEntity.productId = productId;
	}
	final int? productAssignmentId = jsonConvert.convert<int>(json['product_assignment_id']);
	if (productAssignmentId != null) {
		msgEntity.productAssignmentId = productAssignmentId;
	}
	final String? appName = jsonConvert.convert<String>(json['app_name']);
	if (appName != null) {
		msgEntity.appName = appName;
	}
	final String? role = jsonConvert.convert<String>(json['role']);
	if (role != null) {
		msgEntity.role = role;
	}
	final String? type = jsonConvert.convert<String>(json['type']);
	if (type != null) {
		msgEntity.type = type;
	}
	final String? payload = jsonConvert.convert<String>(json['payload']);
	if (payload != null) {
		msgEntity.payload = payload;
	}
	final String? created = jsonConvert.convert<String>(json['created']);
	if (created != null) {
		msgEntity.created = created;
	}
	final String? modified = jsonConvert.convert<String>(json['modified']);
	if (modified != null) {
		msgEntity.modified = modified;
	}
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		msgEntity.id = id;
	}
	return msgEntity;
}

Map<String, dynamic> $MsgEntityToJson(MsgEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['action'] = entity.action;
	data['detail'] = entity.detail;
	data['to_id'] = entity.toId;
	data['is_system'] = entity.isSystem;
	data['read'] = entity.read;
	data['target_id'] = entity.targetId;
	data['campaign_id'] = entity.campaignId;
	data['email_campaign_id'] = entity.emailCampaignId;
	data['email_assignment_id'] = entity.emailAssignmentId;
	data['product_id'] = entity.productId;
	data['product_assignment_id'] = entity.productAssignmentId;
	data['app_name'] = entity.appName;
	data['role'] = entity.role;
	data['type'] = entity.type;
	data['payload'] = entity.payload;
	data['created'] = entity.created;
	data['modified'] = entity.modified;
	data['id'] = entity.id;
	return data;
}

MsgDiscoveryEntity $MsgDiscoveryEntityFromJson(Map<String, dynamic> json) {
	final MsgDiscoveryEntity msgDiscoveryEntity = MsgDiscoveryEntity();
	final int? userId = jsonConvert.convert<int>(json['user_id']);
	if (userId != null) {
		msgDiscoveryEntity.userId = userId;
	}
	final int? socialPostId = jsonConvert.convert<int>(json['social_post_id']);
	if (socialPostId != null) {
		msgDiscoveryEntity.socialPostId = socialPostId;
	}
	final int? commentSocialPostId = jsonConvert.convert<int>(json['comment_social_post_id']);
	if (commentSocialPostId != null) {
		msgDiscoveryEntity.commentSocialPostId = commentSocialPostId;
	}
	final int? socialPostCommentId = jsonConvert.convert<int>(json['social_post_comment_id']);
	if (socialPostCommentId != null) {
		msgDiscoveryEntity.socialPostCommentId = socialPostCommentId;
	}
	final int? replySocialPostCommentId = jsonConvert.convert<int>(json['reply_social_post_comment_id']);
	if (replySocialPostCommentId != null) {
		msgDiscoveryEntity.replySocialPostCommentId = replySocialPostCommentId;
	}
	final int? replyUserId = jsonConvert.convert<int>(json['reply_user_id']);
	if (replyUserId != null) {
		msgDiscoveryEntity.replyUserId = replyUserId;
	}
	final int? authorUserId = jsonConvert.convert<int>(json['author_user_id']);
	if (authorUserId != null) {
		msgDiscoveryEntity.authorUserId = authorUserId;
	}
	final String? text = jsonConvert.convert<String>(json['text']);
	if (text != null) {
		msgDiscoveryEntity.text = text;
	}
	final String? created = jsonConvert.convert<String>(json['created']);
	if (created != null) {
		msgDiscoveryEntity.created = created;
	}
	final String? modified = jsonConvert.convert<String>(json['modified']);
	if (modified != null) {
		msgDiscoveryEntity.modified = modified;
	}
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		msgDiscoveryEntity.id = id;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		msgDiscoveryEntity.name = name;
	}
	final String? avatar = jsonConvert.convert<String>(json['avatar']);
	if (avatar != null) {
		msgDiscoveryEntity.avatar = avatar;
	}
	final String? postText = jsonConvert.convert<String>(json['post_text']);
	if (postText != null) {
		msgDiscoveryEntity.postText = postText;
	}
	final String? replyCommentText = jsonConvert.convert<String>(json['reply_comment_text']);
	if (replyCommentText != null) {
		msgDiscoveryEntity.replyCommentText = replyCommentText;
	}
	final String? commentText = jsonConvert.convert<String>(json['comment_text']);
	if (commentText != null) {
		msgDiscoveryEntity.commentText = commentText;
	}
	final String? ip = jsonConvert.convert<String>(json['ip']);
	if (ip != null) {
		msgDiscoveryEntity.ip = ip;
	}
	final String? country = jsonConvert.convert<String>(json['country']);
	if (country != null) {
		msgDiscoveryEntity.country = country;
	}
	final String? region = jsonConvert.convert<String>(json['region']);
	if (region != null) {
		msgDiscoveryEntity.region = region;
	}
	final String? city = jsonConvert.convert<String>(json['city']);
	if (city != null) {
		msgDiscoveryEntity.city = city;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		msgDiscoveryEntity.status = status;
	}
	final int? likes = jsonConvert.convert<int>(json['likes']);
	if (likes != null) {
		msgDiscoveryEntity.likes = likes;
	}
	final int? comments = jsonConvert.convert<int>(json['comments']);
	if (comments != null) {
		msgDiscoveryEntity.comments = comments;
	}
	final int? realLikes = jsonConvert.convert<int>(json['real_likes']);
	if (realLikes != null) {
		msgDiscoveryEntity.realLikes = realLikes;
	}
	return msgDiscoveryEntity;
}

Map<String, dynamic> $MsgDiscoveryEntityToJson(MsgDiscoveryEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['user_id'] = entity.userId;
	data['social_post_id'] = entity.socialPostId;
	data['comment_social_post_id'] = entity.commentSocialPostId;
	data['social_post_comment_id'] = entity.socialPostCommentId;
	data['reply_social_post_comment_id'] = entity.replySocialPostCommentId;
	data['reply_user_id'] = entity.replyUserId;
	data['author_user_id'] = entity.authorUserId;
	data['text'] = entity.text;
	data['created'] = entity.created;
	data['modified'] = entity.modified;
	data['id'] = entity.id;
	data['name'] = entity.name;
	data['avatar'] = entity.avatar;
	data['post_text'] = entity.postText;
	data['reply_comment_text'] = entity.replyCommentText;
	data['comment_text'] = entity.commentText;
	data['ip'] = entity.ip;
	data['country'] = entity.country;
	data['region'] = entity.region;
	data['city'] = entity.city;
	data['status'] = entity.status;
	data['likes'] = entity.likes;
	data['comments'] = entity.comments;
	data['real_likes'] = entity.realLikes;
	return data;
}