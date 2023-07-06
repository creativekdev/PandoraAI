import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/back_pick_template_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class BackPickTemplateEntity {
	late String category;
	late BackPickS3FileEntity files;
	@JSONField(name: "s3_files")
	late BackPickS3FileEntity s3Files;
	late List<String> tags;
	late String title;
	late String key;
	late String type;
	late String id;

	BackPickTemplateEntity();

	factory BackPickTemplateEntity.fromJson(Map<String, dynamic> json) => $BackPickTemplateEntityFromJson(json);

	Map<String, dynamic> toJson() => $BackPickTemplateEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}

@JsonSerializable()
class BackPickS3FileEntity {
	@JSONField(name: "SCREEN")
	String? screen;
	@JSONField(name: "THUMBNAIL")
	String? thumbnail;
	@JSONField(name: "THUMBNAIL_LARGE")
	String? thumbnailLarge;
	BackPickS3FileEntity();

	factory BackPickS3FileEntity.fromJson(Map<String, dynamic> json) => $BackPickS3FileEntityFromJson(json);

	Map<String, dynamic> toJson() => $BackPickS3FileEntityToJson(this);

	@override
	String toString() {
		return jsonEncode(this);
	}
}