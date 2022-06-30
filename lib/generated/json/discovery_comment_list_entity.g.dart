import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/discovery_comment_list_entity.dart';

DiscoveryCommentListEntity $DiscoveryCommentListEntityFromJson(Map<String, dynamic> json) {
	final DiscoveryCommentListEntity discoveryCommentListEntity = DiscoveryCommentListEntity();
	final int? userId = jsonConvert.convert<int>(json['user_id']);
	if (userId != null) {
		discoveryCommentListEntity.userId = userId;
	}
	final int? socialPostId = jsonConvert.convert<int>(json['social_post_id']);
	if (socialPostId != null) {
		discoveryCommentListEntity.socialPostId = socialPostId;
	}
	final int? replySocialPostCommentId = jsonConvert.convert<int>(json['reply_social_post_comment_id']);
	if (replySocialPostCommentId != null) {
		discoveryCommentListEntity.replySocialPostCommentId = replySocialPostCommentId;
	}
	final int? replyUserId = jsonConvert.convert<int>(json['reply_user_id']);
	if (replyUserId != null) {
		discoveryCommentListEntity.replyUserId = replyUserId;
	}
	final String? images = jsonConvert.convert<String>(json['images']);
	if (images != null) {
		discoveryCommentListEntity.images = images;
	}
	final String? text = jsonConvert.convert<String>(json['text']);
	if (text != null) {
		discoveryCommentListEntity.text = text;
	}
	final int? likes = jsonConvert.convert<int>(json['likes']);
	if (likes != null) {
		discoveryCommentListEntity.likes = likes;
	}
	final int? comments = jsonConvert.convert<int>(json['comments']);
	if (comments != null) {
		discoveryCommentListEntity.comments = comments;
	}
	final String? ip = jsonConvert.convert<String>(json['ip']);
	if (ip != null) {
		discoveryCommentListEntity.ip = ip;
	}
	final String? country = jsonConvert.convert<String>(json['country']);
	if (country != null) {
		discoveryCommentListEntity.country = country;
	}
	final String? region = jsonConvert.convert<String>(json['region']);
	if (region != null) {
		discoveryCommentListEntity.region = region;
	}
	final String? city = jsonConvert.convert<String>(json['city']);
	if (city != null) {
		discoveryCommentListEntity.city = city;
	}
	final String? created = jsonConvert.convert<String>(json['created']);
	if (created != null) {
		discoveryCommentListEntity.created = created;
	}
	final String? modified = jsonConvert.convert<String>(json['modified']);
	if (modified != null) {
		discoveryCommentListEntity.modified = modified;
	}
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		discoveryCommentListEntity.id = id;
	}
	final String? userName = jsonConvert.convert<String>(json['user_name']);
	if (userName != null) {
		discoveryCommentListEntity.userName = userName;
	}
	final String? userAvatar = jsonConvert.convert<String>(json['user_avatar']);
	if (userAvatar != null) {
		discoveryCommentListEntity.userAvatar = userAvatar;
	}
	final int? likeId = jsonConvert.convert<int>(json['like_id']);
	if (likeId != null) {
		discoveryCommentListEntity.likeId = likeId;
	}
	return discoveryCommentListEntity;
}

Map<String, dynamic> $DiscoveryCommentListEntityToJson(DiscoveryCommentListEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['user_id'] = entity.userId;
	data['social_post_id'] = entity.socialPostId;
	data['reply_social_post_comment_id'] = entity.replySocialPostCommentId;
	data['reply_user_id'] = entity.replyUserId;
	data['images'] = entity.images;
	data['text'] = entity.text;
	data['likes'] = entity.likes;
	data['comments'] = entity.comments;
	data['ip'] = entity.ip;
	data['country'] = entity.country;
	data['region'] = entity.region;
	data['city'] = entity.city;
	data['created'] = entity.created;
	data['modified'] = entity.modified;
	data['id'] = entity.id;
	data['user_name'] = entity.userName;
	data['user_avatar'] = entity.userAvatar;
	data['like_id'] = entity.likeId;
	return data;
}