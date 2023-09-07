import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/upload_record_entity.dart';

UploadRecordEntity $UploadRecordEntityFromJson(Map<String, dynamic> json) {
  final UploadRecordEntity uploadRecordEntity = UploadRecordEntity();
  final String? key = jsonConvert.convert<String>(json['key']);
  if (key != null) {
    uploadRecordEntity.key = key;
  }
  final String? url = jsonConvert.convert<String>(json['url']);
  if (url != null) {
    uploadRecordEntity.url = url;
  }
  final int? createDt = jsonConvert.convert<int>(json['create_dt']);
  if (createDt != null) {
    uploadRecordEntity.createDt = createDt;
  }
  final String? originFileName = jsonConvert.convert<String>(json['originFileName']);
  if (originFileName != null) {
    uploadRecordEntity.originFileName = originFileName;
  }
  final String? fileName = jsonConvert.convert<String>(json['fileName']);
  if (fileName != null) {
    uploadRecordEntity.fileName = fileName;
  }
  final String? cachedId = jsonConvert.convert<String>(json['cached_id']);
  if (cachedId != null) {
    uploadRecordEntity.cachedId = cachedId;
  }
  final bool? checked = jsonConvert.convert<bool>(json['checked']);
  if (checked != null) {
    uploadRecordEntity.checked = checked;
  }
  return uploadRecordEntity;
}

Map<String, dynamic> $UploadRecordEntityToJson(UploadRecordEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['key'] = entity.key;
  data['url'] = entity.url;
  data['create_dt'] = entity.createDt;
  data['originFileName'] = entity.originFileName;
  data['fileName'] = entity.fileName;
  data['cached_id'] = entity.cachedId;
  data['checked'] = entity.checked;
  return data;
}
