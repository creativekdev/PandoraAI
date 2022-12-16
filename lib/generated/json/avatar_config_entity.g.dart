import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/avatar_config_entity.dart';

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
	final Map<String, dynamic>? roles = jsonConvert.convert<Map<String, dynamic>>(json['roles']);
	if (roles != null) {
		avatarConfigData.roles = roles;
	}
	return avatarConfigData;
}

Map<String, dynamic> $AvatarConfigDataToJson(AvatarConfigData entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['roles'] = entity.roles;
	return data;
}