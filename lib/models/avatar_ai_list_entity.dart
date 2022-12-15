import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/avatar_ai_list_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class AvatarAiListEntity {
  @JSONField(name: "user_id")
  int userId = 0;
  String name = '';
  String token = '';
  String role = '';
  @JSONField(name: "train_images")
  String trainImages = '';
  @JSONField(name: "output_images")
  late List<AvatarChildEntity> outputImages;
  @JSONField(name: "cover_images")
  String coverImages = '';
  String status = '';
  int expiry = 0;
  @JSONField(name: "image_count")
  int imageCount = 0;
  String created = '';
  String modified = '';
  int id = 0;

  AvatarAiListEntity({List<AvatarChildEntity>? outputImages}) {
    this.outputImages = outputImages ?? [];
  }

  factory AvatarAiListEntity.fromJson(Map<String, dynamic> json) => $AvatarAiListEntityFromJson(json);

  Map<String, dynamic> toJson() => $AvatarAiListEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }

  List<String> coverImage() {
    return coverImages.split(',');
  }
}

@JsonSerializable()
class AvatarChildEntity {
  @JSONField(name: 'user_id')
  int userId = 0;
  @JSONField(name: 'ai_avatar_id')
  int aiAvatarId = 0;
  String style = '';
  String url = '';
  String created = '';
  String modified = '';

  AvatarChildEntity();

  factory AvatarChildEntity.fromJson(Map<String, dynamic> json) => $AvatarChildEntityFromJson(json);

  Map<String, dynamic> toJson() => $AvatarChildEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
