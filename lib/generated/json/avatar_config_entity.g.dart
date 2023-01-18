import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/avatar_config_entity.dart';
import 'package:cartoonizer/images-res.dart';

import 'package:common_utils/common_utils.dart';


AvatarConfigEntity $AvatarConfigEntityFromJson(Map<String, dynamic> json) {
	final AvatarConfigEntity avatarConfigEntity = AvatarConfigEntity();
	final AvatarConfigData? data = jsonConvert.convert<AvatarConfigData>(json['data']);
	if (data != null) {
		avatarConfigEntity.data = data;
	}
	final Map<String, dynamic>? locale = jsonConvert.convert<Map<String, dynamic>>(json['locale']);
	if (locale != null) {
		avatarConfigEntity.locale = locale;
	}
	return avatarConfigEntity;
}

Map<String, dynamic> $AvatarConfigEntityToJson(AvatarConfigEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['data'] = entity.data.toJson();
	data['locale'] = entity.locale;
	return data;
}

AvatarConfigData $AvatarConfigDataFromJson(Map<String, dynamic> json) {
	final AvatarConfigData avatarConfigData = AvatarConfigData();
	final int? pendingTime = jsonConvert.convert<int>(json['pending_time']);
	if (pendingTime != null) {
		avatarConfigData.pendingTime = pendingTime;
	}
	final Map<String, dynamic>? roles = jsonConvert.convert<Map<String, dynamic>>(json['roles']);
	if (roles != null) {
		avatarConfigData.roles = roles;
	}
	final int? faceCheckRatio = jsonConvert.convert<int>(json['face_check_ratio']);
	if (faceCheckRatio != null) {
		avatarConfigData.faceCheckRatio = faceCheckRatio;
	}
	return avatarConfigData;
}

Map<String, dynamic> $AvatarConfigDataToJson(AvatarConfigData entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['pending_time'] = entity.pendingTime;
	data['roles'] = entity.roles;
	data['face_check_ratio'] = entity.faceCheckRatio;
	return data;
}