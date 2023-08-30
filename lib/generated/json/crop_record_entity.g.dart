import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/crop_record_entity.dart';

CropRecordEntity $CropRecordEntityFromJson(Map<String, dynamic> json) {
  final CropRecordEntity cropRecordEntity = CropRecordEntity();
  final String? fileName = jsonConvert.convert<String>(json['fileName']);
  if (fileName != null) {
    cropRecordEntity.fileName = fileName;
  }
  final List<int>? cropList = jsonConvert.convertListNotNull<int>(json['cropList']);
  if (cropList != null) {
    cropRecordEntity.cropList = cropList;
  }
  return cropRecordEntity;
}

Map<String, dynamic> $CropRecordEntityToJson(CropRecordEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['fileName'] = entity.fileName;
  data['cropList'] = entity.cropList;
  return data;
}
