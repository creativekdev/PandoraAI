import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/upload_record_entity.dart';
import 'package:cartoonizer/app/user/rate_notice_operator.dart';


UploadRecordEntity $UploadRecordEntityFromJson(Map<String, dynamic> json) {
	final UploadRecordEntity uploadRecordEntity = UploadRecordEntity();
	final String? url = jsonConvert.convert<String>(json['url']);
	if (url != null) {
		uploadRecordEntity.url = url;
	}
	final int? createDt = jsonConvert.convert<int>(json['create_dt']);
	if (createDt != null) {
		uploadRecordEntity.createDt = createDt;
	}
	final String? fileName = jsonConvert.convert<String>(json['fileName']);
	if (fileName != null) {
		uploadRecordEntity.fileName = fileName;
	}
	final String? cachedId = jsonConvert.convert<String>(json['cached_id']);
	if (cachedId != null) {
		uploadRecordEntity.cachedId = cachedId;
	}
	return uploadRecordEntity;
}

Map<String, dynamic> $UploadRecordEntityToJson(UploadRecordEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['url'] = entity.url;
	data['create_dt'] = entity.createDt;
	data['fileName'] = entity.fileName;
	data['cached_id'] = entity.cachedId;
	return data;
}