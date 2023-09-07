import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/platform_connection_entity.dart';

PlatformConnectionEntity $PlatformConnectionEntityFromJson(Map<String, dynamic> json) {
  final PlatformConnectionEntity platformConnectionEntity = PlatformConnectionEntity();
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    platformConnectionEntity.name = name;
  }
  final String? avatar = jsonConvert.convert<String>(json['avatar']);
  if (avatar != null) {
    platformConnectionEntity.avatar = avatar;
  }
  final String? bio = jsonConvert.convert<String>(json['bio']);
  if (bio != null) {
    platformConnectionEntity.bio = bio;
  }
  final String? id = jsonConvert.convert<String>(json['_id']);
  if (id != null) {
    platformConnectionEntity.id = id;
  }
  final String? channel = jsonConvert.convert<String>(json['channel']);
  if (channel != null) {
    platformConnectionEntity.channel = channel;
  }
  final int? coreUserId = jsonConvert.convert<int>(json['core_user_id']);
  if (coreUserId != null) {
    platformConnectionEntity.coreUserId = coreUserId;
  }
  final PlatformConnectionCoreUser? coreUser = jsonConvert.convert<PlatformConnectionCoreUser>(json['core_user']);
  if (coreUser != null) {
    platformConnectionEntity.coreUser = coreUser;
  }
  return platformConnectionEntity;
}

Map<String, dynamic> $PlatformConnectionEntityToJson(PlatformConnectionEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['name'] = entity.name;
  data['avatar'] = entity.avatar;
  data['bio'] = entity.bio;
  data['_id'] = entity.id;
  data['channel'] = entity.channel;
  data['core_user_id'] = entity.coreUserId;
  data['core_user'] = entity.coreUser.toJson();
  return data;
}

PlatformConnectionCoreUser $PlatformConnectionCoreUserFromJson(Map<String, dynamic> json) {
  final PlatformConnectionCoreUser platformConnectionCoreUser = PlatformConnectionCoreUser();
  final String? youtubeChannel = jsonConvert.convert<String>(json['youtube_channel']);
  if (youtubeChannel != null) {
    platformConnectionCoreUser.youtubeChannel = youtubeChannel;
  }
  final String? instagramUsername = jsonConvert.convert<String>(json['instagram_username']);
  if (instagramUsername != null) {
    platformConnectionCoreUser.instagramUsername = instagramUsername;
  }
  final String? tiktokUsername = jsonConvert.convert<String>(json['tiktok_username']);
  if (tiktokUsername != null) {
    platformConnectionCoreUser.tiktokUsername = tiktokUsername;
  }
  return platformConnectionCoreUser;
}

Map<String, dynamic> $PlatformConnectionCoreUserToJson(PlatformConnectionCoreUser entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['youtube_channel'] = entity.youtubeChannel;
  data['instagram_username'] = entity.instagramUsername;
  data['tiktok_username'] = entity.tiktokUsername;
  return data;
}
