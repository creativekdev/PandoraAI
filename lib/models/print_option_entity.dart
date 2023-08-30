import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/print_option_entity.g.dart';

@JsonSerializable()
class PrintOptionEntity {
  late List<PrintOptionData> data;

  PrintOptionEntity();

  factory PrintOptionEntity.fromJson(Map<String, dynamic> json) => $PrintOptionEntityFromJson(json);

  Map<String, dynamic> toJson() => $PrintOptionEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOptionData {
  late String type;
  dynamic category;
  late String title;
  dynamic content;
  dynamic tags;
  late String thumbnail;
  @JSONField(name: "thumbnail_large")
  dynamic thumbnailLarge;
  @JSONField(name: "user_id")
  late int userId;
  @JSONField(name: "display_order")
  late int displayOrder;
  @JSONField(name: "canva_size")
  late PrintOptionDataCanvaSize canvaSize;
  @JSONField(name: "hide")
  late bool xHide;
  @JSONField(name: "content_url")
  late String contentUrl;
  @JSONField(name: "mediakit_channel")
  dynamic mediakitChannel;
  @JSONField(name: "external_id")
  dynamic externalId;
  late String desc;
  @JSONField(name: "shopify_product_id")
  late String shopifyProductId;
  late String created;
  late String modified;
  late int id;
  @JSONField(name: "content_str")
  dynamic contentStr;
  late int key;
  @JSONField(name: "s3_files")
  late PrintOptionDataS3Files s3Files;
  @JSONField(name: "hashed_id")
  late String hashedId;

  Map<String, dynamic>? productColorMap;

  PrintOptionData();

  factory PrintOptionData.fromJson(Map<String, dynamic> json) => $PrintOptionDataFromJson(json);

  Map<String, dynamic> toJson() => $PrintOptionDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOptionDataCanvaSize {
  late int width;
  late int height;
  late int ratio;

  PrintOptionDataCanvaSize();

  factory PrintOptionDataCanvaSize.fromJson(Map<String, dynamic> json) => $PrintOptionDataCanvaSizeFromJson(json);

  Map<String, dynamic> toJson() => $PrintOptionDataCanvaSizeToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintOptionDataS3Files {
  @JSONField(name: "THUMBNAIL")
  late String tHUMBNAIL;
  @JSONField(name: "THUMBNAIL_LARGE")
  dynamic thumbnailLarge;

  PrintOptionDataS3Files();

  factory PrintOptionDataS3Files.fromJson(Map<String, dynamic> json) => $PrintOptionDataS3FilesFromJson(json);

  Map<String, dynamic> toJson() => $PrintOptionDataS3FilesToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
