import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/txt2img_style_entity.dart';

Txt2imgStyleEntity $Txt2imgStyleEntityFromJson(Map<String, dynamic> json) {
  final Txt2imgStyleEntity txt2imgStyleEntity = Txt2imgStyleEntity();
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    txt2imgStyleEntity.name = name;
  }
  final dynamic score = jsonConvert.convert<dynamic>(json['score']);
  if (score != null) {
    txt2imgStyleEntity.score = score;
  }
  final String? category = jsonConvert.convert<String>(json['category']);
  if (category != null) {
    txt2imgStyleEntity.category = category;
  }
  final String? slug = jsonConvert.convert<String>(json['slug']);
  if (slug != null) {
    txt2imgStyleEntity.slug = slug;
  }
  final String? url = jsonConvert.convert<String>(json['url']);
  if (url != null) {
    txt2imgStyleEntity.url = url;
  }
  return txt2imgStyleEntity;
}

Map<String, dynamic> $Txt2imgStyleEntityToJson(Txt2imgStyleEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['name'] = entity.name;
  data['score'] = entity.score;
  data['category'] = entity.category;
  data['slug'] = entity.slug;
  data['url'] = entity.url;
  return data;
}
