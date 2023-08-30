import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:cartoonizer/common/importFile.dart';

import 'package:cartoonizer/generated/json/base/json_convert_content.dart';

import 'package:cartoonizer/models/discovery_list_entity.dart';

MetagramPageEntity $MetagramPageEntityFromJson(Map<String, dynamic> json) {
  final MetagramPageEntity metagramPageEntity = MetagramPageEntity();
  final int? records = jsonConvert.convert<int>(json['records']);
  if (records != null) {
    metagramPageEntity.records = records;
  }
  final int? total = jsonConvert.convert<int>(json['total']);
  if (total != null) {
    metagramPageEntity.total = total;
  }
  final int? page = jsonConvert.convert<int>(json['page']);
  if (page != null) {
    metagramPageEntity.page = page;
  }
  final List<MetagramItemEntity>? rows = jsonConvert.convertListNotNull<MetagramItemEntity>(json['rows']);
  if (rows != null) {
    metagramPageEntity.rows = rows;
  }
  final SocialPostPageEntity? socialPostPage = jsonConvert.convert<SocialPostPageEntity>(json['social_post_page']);
  if (socialPostPage != null) {
    metagramPageEntity.socialPostPage = socialPostPage;
  }
  return metagramPageEntity;
}

Map<String, dynamic> $MetagramPageEntityToJson(MetagramPageEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['records'] = entity.records;
  data['total'] = entity.total;
  data['page'] = entity.page;
  data['rows'] = entity.rows.map((v) => v.toJson()).toList();
  data['social_post_page'] = entity.socialPostPage?.toJson();
  return data;
}

SocialPostPageEntity $SocialPostPageEntityFromJson(Map<String, dynamic> json) {
  final SocialPostPageEntity socialPostPageEntity = SocialPostPageEntity();
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    socialPostPageEntity.name = name;
  }
  final int? userId = jsonConvert.convert<int>(json['user_id']);
  if (userId != null) {
    socialPostPageEntity.userId = userId;
  }
  final int? coreUserId = jsonConvert.convert<int>(json['core_user_id']);
  if (coreUserId != null) {
    socialPostPageEntity.coreUserId = coreUserId;
  }
  final String? coverImage = jsonConvert.convert<String>(json['cover_image']);
  if (coverImage != null) {
    socialPostPageEntity.coverImage = coverImage;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    socialPostPageEntity.status = status;
  }
  final String? payload = jsonConvert.convert<String>(json['payload']);
  if (payload != null) {
    socialPostPageEntity.payload = payload;
  }
  final String? slug = jsonConvert.convert<String>(json['slug']);
  if (slug != null) {
    socialPostPageEntity.slug = slug;
  }
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    socialPostPageEntity.type = type;
  }
  final String? previewImages = jsonConvert.convert<String>(json['preview_images']);
  if (previewImages != null) {
    socialPostPageEntity.previewImages = previewImages;
  }
  final String? created = jsonConvert.convert<String>(json['created']);
  if (created != null) {
    socialPostPageEntity.created = created;
  }
  final String? modified = jsonConvert.convert<String>(json['modified']);
  if (modified != null) {
    socialPostPageEntity.modified = modified;
  }
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    socialPostPageEntity.id = id;
  }
  return socialPostPageEntity;
}

Map<String, dynamic> $SocialPostPageEntityToJson(SocialPostPageEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['name'] = entity.name;
  data['user_id'] = entity.userId;
  data['core_user_id'] = entity.coreUserId;
  data['cover_image'] = entity.coverImage;
  data['status'] = entity.status;
  data['payload'] = entity.payload;
  data['slug'] = entity.slug;
  data['type'] = entity.type;
  data['preview_images'] = entity.previewImages;
  data['created'] = entity.created;
  data['modified'] = entity.modified;
  data['id'] = entity.id;
  return data;
}

MetagramItemEntity $MetagramItemEntityFromJson(Map<String, dynamic> json) {
  final MetagramItemEntity metagramItemEntity = MetagramItemEntity();
  final int? userId = jsonConvert.convert<int>(json['user_id']);
  if (userId != null) {
    metagramItemEntity.userId = userId;
  }
  final String? images = jsonConvert.convert<String>(json['images']);
  if (images != null) {
    metagramItemEntity.images = images;
  }
  final String? resources = jsonConvert.convert<String>(json['resources']);
  if (resources != null) {
    metagramItemEntity.resources = resources;
  }
  final String? text = jsonConvert.convert<String>(json['text']);
  if (text != null) {
    metagramItemEntity.text = text;
  }
  final int? likes = jsonConvert.convert<int>(json['likes']);
  if (likes != null) {
    metagramItemEntity.likes = likes;
  }
  final int? likeId = jsonConvert.convert<int>(json['like_id']);
  if (likeId != null) {
    metagramItemEntity.likeId = likeId;
  }
  final int? realLikes = jsonConvert.convert<int>(json['real_likes']);
  if (realLikes != null) {
    metagramItemEntity.realLikes = realLikes;
  }
  final int? comments = jsonConvert.convert<int>(json['comments']);
  if (comments != null) {
    metagramItemEntity.comments = comments;
  }
  final String? ip = jsonConvert.convert<String>(json['ip']);
  if (ip != null) {
    metagramItemEntity.ip = ip;
  }
  final String? country = jsonConvert.convert<String>(json['country']);
  if (country != null) {
    metagramItemEntity.country = country;
  }
  final String? region = jsonConvert.convert<String>(json['region']);
  if (region != null) {
    metagramItemEntity.region = region;
  }
  final String? city = jsonConvert.convert<String>(json['city']);
  if (city != null) {
    metagramItemEntity.city = city;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    metagramItemEntity.status = status;
  }
  final String? cartoonizeKey = jsonConvert.convert<String>(json['cartoonize_key']);
  if (cartoonizeKey != null) {
    metagramItemEntity.cartoonizeKey = cartoonizeKey;
  }
  final String? category = jsonConvert.convert<String>(json['category']);
  if (category != null) {
    metagramItemEntity.category = category;
  }
  final String? socialPostPageId = jsonConvert.convert<String>(json['social_post_page_id']);
  if (socialPostPageId != null) {
    metagramItemEntity.socialPostPageId = socialPostPageId;
  }
  final String? originalPostUrl = jsonConvert.convert<String>(json['original_post_url']);
  if (originalPostUrl != null) {
    metagramItemEntity.originalPostUrl = originalPostUrl;
  }
  final String? postCreatedAt = jsonConvert.convert<String>(json['post_created_at']);
  if (postCreatedAt != null) {
    metagramItemEntity.postCreatedAt = postCreatedAt;
  }
  final String? payload = jsonConvert.convert<String>(json['payload']);
  if (payload != null) {
    metagramItemEntity.payload = payload;
  }
  final String? created = jsonConvert.convert<String>(json['created']);
  if (created != null) {
    metagramItemEntity.created = created;
  }
  final String? modified = jsonConvert.convert<String>(json['modified']);
  if (modified != null) {
    metagramItemEntity.modified = modified;
  }
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    metagramItemEntity.id = id;
  }
  return metagramItemEntity;
}

Map<String, dynamic> $MetagramItemEntityToJson(MetagramItemEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['user_id'] = entity.userId;
  data['images'] = entity.images;
  data['resources'] = entity.resources;
  data['text'] = entity.text;
  data['likes'] = entity.likes;
  data['like_id'] = entity.likeId;
  data['real_likes'] = entity.realLikes;
  data['comments'] = entity.comments;
  data['ip'] = entity.ip;
  data['country'] = entity.country;
  data['region'] = entity.region;
  data['city'] = entity.city;
  data['status'] = entity.status;
  data['cartoonize_key'] = entity.cartoonizeKey;
  data['category'] = entity.category;
  data['social_post_page_id'] = entity.socialPostPageId;
  data['original_post_url'] = entity.originalPostUrl;
  data['post_created_at'] = entity.postCreatedAt;
  data['payload'] = entity.payload;
  data['created'] = entity.created;
  data['modified'] = entity.modified;
  data['id'] = entity.id;
  return data;
}
