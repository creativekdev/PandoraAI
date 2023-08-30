import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/ai_draw_result_entity.dart';

AiDrawResultEntity $AiDrawResultEntityFromJson(Map<String, dynamic> json) {
  final AiDrawResultEntity aiDrawResultEntity = AiDrawResultEntity();
  final List<String>? images = jsonConvert.convertListNotNull<String>(json['images']);
  if (images != null) {
    aiDrawResultEntity.images = images;
  }
  final Map<String, dynamic>? parameters = jsonConvert.convert<Map<String, dynamic>>(json['parameters']);
  if (parameters != null) {
    aiDrawResultEntity.parameters = parameters;
  }
  final String? info = jsonConvert.convert<String>(json['info']);
  if (info != null) {
    aiDrawResultEntity.info = info;
  }
  final List<String>? filePath = jsonConvert.convertListNotNull<String>(json['filePath']);
  if (filePath != null) {
    aiDrawResultEntity.filePath = filePath;
  }
  final String? s = jsonConvert.convert<String>(json['s']);
  if (s != null) {
    aiDrawResultEntity.s = s;
  }
  return aiDrawResultEntity;
}

Map<String, dynamic> $AiDrawResultEntityToJson(AiDrawResultEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['images'] = entity.images;
  data['parameters'] = entity.parameters;
  data['info'] = entity.info;
  data['filePath'] = entity.filePath;
  data['s'] = entity.s;
  return data;
}
