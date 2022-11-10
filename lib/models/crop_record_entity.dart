import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/crop_record_entity.g.dart';

@JsonSerializable()
class CropRecordEntity {
	String fileName;
	late List<int> cropList;

	CropRecordEntity({
		this.fileName='',
		List<int>? cropList,
	}) {
		this.cropList = cropList??[];
	}

	factory CropRecordEntity.fromJson(Map<String, dynamic> json) => $CropRecordEntityFromJson(json);

	Map<String, dynamic> toJson() => $CropRecordEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}
