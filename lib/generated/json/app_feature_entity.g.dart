import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/app_feature_entity.dart';

AppFeatureEntity $AppFeatureEntityFromJson(Map<String, dynamic> json) {
  final AppFeatureEntity appFeatureEntity = AppFeatureEntity();
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    appFeatureEntity.name = name;
  }
  final String? content = jsonConvert.convert<String>(json['content']);
  if (content != null) {
    appFeatureEntity.content = content;
  }
  final String? url = jsonConvert.convert<String>(json['url']);
  if (url != null) {
    appFeatureEntity.url = url;
  }
  final String? role = jsonConvert.convert<String>(json['role']);
  if (role != null) {
    appFeatureEntity.role = role;
  }
  final bool? public = jsonConvert.convert<bool>(json['public']);
  if (public != null) {
    appFeatureEntity.public = public;
  }
  final String? payload = jsonConvert.convert<String>(json['payload']);
  if (payload != null) {
    appFeatureEntity.payload = payload;
  }
  final String? product = jsonConvert.convert<String>(json['product']);
  if (product != null) {
    appFeatureEntity.product = product;
  }
  final String? created = jsonConvert.convert<String>(json['created']);
  if (created != null) {
    appFeatureEntity.created = created;
  }
  return appFeatureEntity;
}

Map<String, dynamic> $AppFeatureEntityToJson(AppFeatureEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['name'] = entity.name;
  data['content'] = entity.content;
  data['url'] = entity.url;
  data['role'] = entity.role;
  data['public'] = entity.public;
  data['payload'] = entity.payload;
  data['product'] = entity.product;
  data['created'] = entity.created;
  return data;
}

AppFeaturePayload $AppFeaturePayloadFromJson(Map<String, dynamic> json) {
  final AppFeaturePayload appFeaturePayload = AppFeaturePayload();
  final String? image = jsonConvert.convert<String>(json['image']);
  if (image != null) {
    appFeaturePayload.image = image;
  }
  final String? target = jsonConvert.convert<String>(json['target']);
  if (target != null) {
    appFeaturePayload.target = target;
  }
  final String? data = jsonConvert.convert<String>(json['data']);
  if (data != null) {
    appFeaturePayload.data = data;
  }
  return appFeaturePayload;
}

Map<String, dynamic> $AppFeaturePayloadToJson(AppFeaturePayload entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['image'] = entity.image;
  data['target'] = entity.target;
  data['data'] = entity.data;
  return data;
}
