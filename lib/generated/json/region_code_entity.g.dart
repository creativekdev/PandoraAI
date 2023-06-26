import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/region_code_entity.dart';

RegionCodeEntity $RegionCodeEntityFromJson(Map<String, dynamic> json) {
	final RegionCodeEntity regionCodeEntity = RegionCodeEntity();
	final String? regionName = jsonConvert.convert<String>(json['regionName']);
	if (regionName != null) {
		regionCodeEntity.regionName = regionName;
	}
	final String? callingCode = jsonConvert.convert<String>(json['callingCode']);
	if (callingCode != null) {
		regionCodeEntity.callingCode = callingCode;
	}
	final String? regionCode = jsonConvert.convert<String>(json['regionCode']);
	if (regionCode != null) {
		regionCodeEntity.regionCode = regionCode;
	}
	final String? regionFlag = jsonConvert.convert<String>(json['regionFlag']);
	if (regionFlag != null) {
		regionCodeEntity.regionFlag = regionFlag;
	}
	final List<String>? regionSyllables = jsonConvert.convertListNotNull<String>(json['regionSyllables']);
	if (regionSyllables != null) {
		regionCodeEntity.regionSyllables = regionSyllables;
	}
	return regionCodeEntity;
}

Map<String, dynamic> $RegionCodeEntityToJson(RegionCodeEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['regionName'] = entity.regionName;
	data['callingCode'] = entity.callingCode;
	data['regionCode'] = entity.regionCode;
	data['regionFlag'] = entity.regionFlag;
	data['regionSyllables'] =  entity.regionSyllables;
	return data;
}