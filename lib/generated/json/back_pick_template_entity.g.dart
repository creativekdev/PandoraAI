import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/back_pick_template_entity.dart';

BackPickTemplateEntity $BackPickTemplateEntityFromJson(Map<String, dynamic> json) {
  final BackPickTemplateEntity backPickTemplateEntity = BackPickTemplateEntity();
  final String? category = jsonConvert.convert<String>(json['category']);
  if (category != null) {
    backPickTemplateEntity.category = category;
  }
  final BackPickS3FileEntity? files = jsonConvert.convert<BackPickS3FileEntity>(json['files']);
  if (files != null) {
    backPickTemplateEntity.files = files;
  }
  final BackPickS3FileEntity? s3Files = jsonConvert.convert<BackPickS3FileEntity>(json['s3_files']);
  if (s3Files != null) {
    backPickTemplateEntity.s3Files = s3Files;
  }
  final List<String>? tags = jsonConvert.convertListNotNull<String>(json['tags']);
  if (tags != null) {
    backPickTemplateEntity.tags = tags;
  }
  final String? title = jsonConvert.convert<String>(json['title']);
  if (title != null) {
    backPickTemplateEntity.title = title;
  }
  final String? key = jsonConvert.convert<String>(json['key']);
  if (key != null) {
    backPickTemplateEntity.key = key;
  }
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    backPickTemplateEntity.type = type;
  }
  final String? id = jsonConvert.convert<String>(json['id']);
  if (id != null) {
    backPickTemplateEntity.id = id;
  }
  return backPickTemplateEntity;
}

Map<String, dynamic> $BackPickTemplateEntityToJson(BackPickTemplateEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['category'] = entity.category;
  data['files'] = entity.files.toJson();
  data['s3_files'] = entity.s3Files.toJson();
  data['tags'] = entity.tags;
  data['title'] = entity.title;
  data['key'] = entity.key;
  data['type'] = entity.type;
  data['id'] = entity.id;
  return data;
}

BackPickS3FileEntity $BackPickS3FileEntityFromJson(Map<String, dynamic> json) {
  final BackPickS3FileEntity backPickS3FileEntity = BackPickS3FileEntity();
  final String? screen = jsonConvert.convert<String>(json['SCREEN']);
  if (screen != null) {
    backPickS3FileEntity.screen = screen;
  }
  final String? thumbnail = jsonConvert.convert<String>(json['THUMBNAIL']);
  if (thumbnail != null) {
    backPickS3FileEntity.thumbnail = thumbnail;
  }
  final String? thumbnailLarge = jsonConvert.convert<String>(json['THUMBNAIL_LARGE']);
  if (thumbnailLarge != null) {
    backPickS3FileEntity.thumbnailLarge = thumbnailLarge;
  }
  return backPickS3FileEntity;
}

Map<String, dynamic> $BackPickS3FileEntityToJson(BackPickS3FileEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['SCREEN'] = entity.screen;
  data['THUMBNAIL'] = entity.thumbnail;
  data['THUMBNAIL_LARGE'] = entity.thumbnailLarge;
  return data;
}
