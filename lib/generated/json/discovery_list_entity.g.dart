import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';

import 'package:cartoonizer/models/enums/home_card_type.dart';


DiscoveryListEntity $DiscoveryListEntityFromJson(Map<String, dynamic> json) {
	final DiscoveryListEntity discoveryListEntity = DiscoveryListEntity();
	final int? userId = jsonConvert.convert<int>(json['user_id']);
	if (userId != null) {
		discoveryListEntity.userId = userId;
	}
	final String? userName = jsonConvert.convert<String>(json['user_name']);
	if (userName != null) {
		discoveryListEntity.userName = userName;
	}
	final String? userAvatar = jsonConvert.convert<String>(json['user_avatar']);
	if (userAvatar != null) {
		discoveryListEntity.userAvatar = userAvatar;
	}
	final String? images = jsonConvert.convert<String>(json['images']);
	if (images != null) {
		discoveryListEntity.images = images;
	}
	final String? text = jsonConvert.convert<String>(json['text']);
	if (text != null) {
		discoveryListEntity.text = text;
	}
	final int? likes = jsonConvert.convert<int>(json['likes']);
	if (likes != null) {
		discoveryListEntity.likes = likes;
	}
	final int? comments = jsonConvert.convert<int>(json['comments']);
	if (comments != null) {
		discoveryListEntity.comments = comments;
	}
	final String? ip = jsonConvert.convert<String>(json['ip']);
	if (ip != null) {
		discoveryListEntity.ip = ip;
	}
	final String? country = jsonConvert.convert<String>(json['country']);
	if (country != null) {
		discoveryListEntity.country = country;
	}
	final String? region = jsonConvert.convert<String>(json['region']);
	if (region != null) {
		discoveryListEntity.region = region;
	}
	final String? city = jsonConvert.convert<String>(json['city']);
	if (city != null) {
		discoveryListEntity.city = city;
	}
	final String? created = jsonConvert.convert<String>(json['created']);
	if (created != null) {
		discoveryListEntity.created = created;
	}
	final String? modified = jsonConvert.convert<String>(json['modified']);
	if (modified != null) {
		discoveryListEntity.modified = modified;
	}
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		discoveryListEntity.id = id;
	}
	final String? status = jsonConvert.convert<String>(json['status']);
	if (status != null) {
		discoveryListEntity.status = status;
	}
	final String? categoryString = jsonConvert.convert<String>(json['category']);
	if (categoryString != null) {
		discoveryListEntity.categoryString = categoryString;
	}
	final String? cartoonizeKey = jsonConvert.convert<String>(json['cartoonize_key']);
	if (cartoonizeKey != null) {
		discoveryListEntity.cartoonizeKey = cartoonizeKey;
	}
	final int? likeId = jsonConvert.convert<int>(json['like_id']);
	if (likeId != null) {
		discoveryListEntity.likeId = likeId;
	}
	final String? resources = jsonConvert.convert<String>(json['resources']);
	if (resources != null) {
		discoveryListEntity.resources = resources;
	}
	final bool? removed = jsonConvert.convert<bool>(json['removed']);
	if (removed != null) {
		discoveryListEntity.removed = removed;
	}
	final String? payload = jsonConvert.convert<String>(json['payload']);
	if (payload != null) {
		discoveryListEntity.payload = payload;
	}
	final String? socialPostPageId = jsonConvert.convert<String>(json['social_post_page_id']);
	if (socialPostPageId != null) {
		discoveryListEntity.socialPostPageId = socialPostPageId;
	}
	return discoveryListEntity;
}

Map<String, dynamic> $DiscoveryListEntityToJson(DiscoveryListEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['user_id'] = entity.userId;
	data['user_name'] = entity.userName;
	data['user_avatar'] = entity.userAvatar;
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
	data['status'] = entity.status;
	data['category'] = entity.categoryString;
	data['cartoonize_key'] = entity.cartoonizeKey;
	data['like_id'] = entity.likeId;
	data['resources'] = entity.resources;
	data['removed'] = entity.removed;
	data['payload'] = entity.payload;
	data['social_post_page_id'] = entity.socialPostPageId;
	return data;
}

DiscoveryResource $DiscoveryResourceFromJson(Map<String, dynamic> json) {
	final DiscoveryResource discoveryResource = DiscoveryResource();
	final String? typeString = jsonConvert.convert<String>(json['type']);
	if (typeString != null) {
		discoveryResource.typeString = typeString;
	}
	final String? url = jsonConvert.convert<String>(json['url']);
	if (url != null) {
		discoveryResource.url = url;
	}
	return discoveryResource;
}

Map<String, dynamic> $DiscoveryResourceToJson(DiscoveryResource entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['type'] = entity.typeString;
	data['url'] = entity.url;
	return data;
}