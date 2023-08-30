import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/color_fill_result_entity.dart';

ColorFillResultEntity $ColorFillResultEntityFromJson(Map<String, dynamic> json) {
  final ColorFillResultEntity colorFillResultEntity = ColorFillResultEntity();
  final List<String>? images = jsonConvert.convertListNotNull<String>(json['images']);
  if (images != null) {
    colorFillResultEntity.images = images;
  }
  final Map<String, dynamic>? parameters = jsonConvert.convert<Map<String, dynamic>>(json['parameters']);
  if (parameters != null) {
    colorFillResultEntity.parameters = parameters;
  }
  final String? info = jsonConvert.convert<String>(json['info']);
  if (info != null) {
    colorFillResultEntity.info = info;
  }
  final String? filePath = jsonConvert.convert<String>(json['filePath']);
  if (filePath != null) {
    colorFillResultEntity.filePath = filePath;
  }
  final String? s = jsonConvert.convert<String>(json['s']);
  if (s != null) {
    colorFillResultEntity.s = s;
  }
  return colorFillResultEntity;
}

Map<String, dynamic> $ColorFillResultEntityToJson(ColorFillResultEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['images'] = entity.images;
  data['parameters'] = entity.parameters;
  data['info'] = entity.info;
  data['filePath'] = entity.filePath;
  data['s'] = entity.s;
  return data;
}
