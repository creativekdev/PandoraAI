import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/avatar_ai_list_entity.dart';

AvatarAiListEntity $AvatarAiListEntityFromJson(Map<String, dynamic> json) {
  final AvatarAiListEntity avatarAiListEntity = AvatarAiListEntity();
  final int? userId = jsonConvert.convert<int>(json['user_id']);
  if (userId != null) {
    avatarAiListEntity.userId = userId;
  }
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    avatarAiListEntity.name = name;
  }
  final String? token = jsonConvert.convert<String>(json['token']);
  if (token != null) {
    avatarAiListEntity.token = token;
  }
  final String? role = jsonConvert.convert<String>(json['role']);
  if (role != null) {
    avatarAiListEntity.role = role;
  }
  final String? trainImages = jsonConvert.convert<String>(json['train_images']);
  if (trainImages != null) {
    avatarAiListEntity.trainImages = trainImages;
  }
  final List<AvatarChildEntity>? outputImages = jsonConvert.convertListNotNull<AvatarChildEntity>(json['output_images']);
  if (outputImages != null) {
    avatarAiListEntity.outputImages = outputImages;
  }
  final String? coverImages = jsonConvert.convert<String>(json['cover_images']);
  if (coverImages != null) {
    avatarAiListEntity.coverImages = coverImages;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    avatarAiListEntity.status = status;
  }
  final int? expiry = jsonConvert.convert<int>(json['expiry']);
  if (expiry != null) {
    avatarAiListEntity.expiry = expiry;
  }
  final int? imageCount = jsonConvert.convert<int>(json['image_count']);
  if (imageCount != null) {
    avatarAiListEntity.imageCount = imageCount;
  }
  final String? created = jsonConvert.convert<String>(json['created']);
  if (created != null) {
    avatarAiListEntity.created = created;
  }
  final String? modified = jsonConvert.convert<String>(json['modified']);
  if (modified != null) {
    avatarAiListEntity.modified = modified;
  }
  final String? shareCode = jsonConvert.convert<String>(json['share_code']);
  if (shareCode != null) {
    avatarAiListEntity.shareCode = shareCode;
  }
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    avatarAiListEntity.id = id;
  }
  return avatarAiListEntity;
}

Map<String, dynamic> $AvatarAiListEntityToJson(AvatarAiListEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['user_id'] = entity.userId;
  data['name'] = entity.name;
  data['token'] = entity.token;
  data['role'] = entity.role;
  data['train_images'] = entity.trainImages;
  data['output_images'] = entity.outputImages.map((v) => v.toJson()).toList();
  data['cover_images'] = entity.coverImages;
  data['status'] = entity.status;
  data['expiry'] = entity.expiry;
  data['image_count'] = entity.imageCount;
  data['created'] = entity.created;
  data['modified'] = entity.modified;
  data['share_code'] = entity.shareCode;
  data['id'] = entity.id;
  return data;
}

AvatarChildEntity $AvatarChildEntityFromJson(Map<String, dynamic> json) {
  final AvatarChildEntity avatarChildEntity = AvatarChildEntity();
  final int? userId = jsonConvert.convert<int>(json['user_id']);
  if (userId != null) {
    avatarChildEntity.userId = userId;
  }
  final int? aiAvatarId = jsonConvert.convert<int>(json['ai_avatar_id']);
  if (aiAvatarId != null) {
    avatarChildEntity.aiAvatarId = aiAvatarId;
  }
  final String? style = jsonConvert.convert<String>(json['style']);
  if (style != null) {
    avatarChildEntity.style = style;
  }
  final String? url = jsonConvert.convert<String>(json['url']);
  if (url != null) {
    avatarChildEntity.url = url;
  }
  final String? created = jsonConvert.convert<String>(json['created']);
  if (created != null) {
    avatarChildEntity.created = created;
  }
  final String? modified = jsonConvert.convert<String>(json['modified']);
  if (modified != null) {
    avatarChildEntity.modified = modified;
  }
  return avatarChildEntity;
}

Map<String, dynamic> $AvatarChildEntityToJson(AvatarChildEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['user_id'] = entity.userId;
  data['ai_avatar_id'] = entity.aiAvatarId;
  data['style'] = entity.style;
  data['url'] = entity.url;
  data['created'] = entity.created;
  data['modified'] = entity.modified;
  return data;
}
