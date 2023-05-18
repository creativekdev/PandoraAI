import 'package:cartoonizer/Widgets/auth/connector_platform.dart';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/platform_connection_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class PlatformConnectionEntity {
  String? name;
  String? avatar;
  String? bio;
  @JSONField(name: "_id")
  String? id;
  late String channel;
  @JSONField(name: "core_user_id")
  int coreUserId = 0;
  @JSONField(name: "core_user")
  late PlatformConnectionCoreUser coreUser;

  PlatformConnectionEntity();

  factory PlatformConnectionEntity.fromJson(Map<String, dynamic> json) => $PlatformConnectionEntityFromJson(json);

  Map<String, dynamic> toJson() => $PlatformConnectionEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PlatformConnectionCoreUser {
  @JSONField(name: "youtube_channel")
  String? youtubeChannel;
  @JSONField(name: "instagram_username")
  String? instagramUsername;
  @JSONField(name: "tiktok_username")
  String? tiktokUsername;

  PlatformConnectionCoreUser();

  factory PlatformConnectionCoreUser.fromJson(Map<String, dynamic> json) => $PlatformConnectionCoreUserFromJson(json);

  Map<String, dynamic> toJson() => $PlatformConnectionCoreUserToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

extension PlatformConnectionEntityEx on PlatformConnectionEntity {
  ConnectorPlatform get platform => ConnectorPlatformUtils.build(channel);
}
