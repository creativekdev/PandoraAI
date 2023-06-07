import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/print_option_entity.dart';

PrintOptionEntity $PrintOptionEntityFromJson(Map<String, dynamic> json) {
  final PrintOptionEntity printOptionEntity = PrintOptionEntity();
  final List<PrintOptionData>? data =
      jsonConvert.convertListNotNull<PrintOptionData>(json['data']);
  if (data != null) {
    printOptionEntity.data = data;
  }
  return printOptionEntity;
}

Map<String, dynamic> $PrintOptionEntityToJson(PrintOptionEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['data'] = entity.data.map((v) => v.toJson()).toList();
  return data;
}

PrintOptionData $PrintOptionDataFromJson(Map<String, dynamic> json) {
  final PrintOptionData printOptionData = PrintOptionData();
  final String? type = jsonConvert.convert<String>(json['type']);
  if (type != null) {
    printOptionData.type = type;
  }
  final dynamic category = jsonConvert.convert<dynamic>(json['category']);
  if (category != null) {
    printOptionData.category = category;
  }
  final String? title = jsonConvert.convert<String>(json['title']);
  if (title != null) {
    printOptionData.title = title;
  }
  final dynamic content = jsonConvert.convert<dynamic>(json['content']);
  if (content != null) {
    printOptionData.content = content;
  }
  final dynamic tags = jsonConvert.convert<dynamic>(json['tags']);
  if (tags != null) {
    printOptionData.tags = tags;
  }
  final String? thumbnail = jsonConvert.convert<String>(json['thumbnail']);
  if (thumbnail != null) {
    printOptionData.thumbnail = thumbnail;
  }
  final dynamic thumbnailLarge =
      jsonConvert.convert<dynamic>(json['thumbnail_large']);
  if (thumbnailLarge != null) {
    printOptionData.thumbnailLarge = thumbnailLarge;
  }
  final int? userId = jsonConvert.convert<int>(json['user_id']);
  if (userId != null) {
    printOptionData.userId = userId;
  }
  final int? displayOrder = jsonConvert.convert<int>(json['display_order']);
  if (displayOrder != null) {
    printOptionData.displayOrder = displayOrder;
  }
  final PrintOptionDataCanvaSize? canvaSize =
      jsonConvert.convert<PrintOptionDataCanvaSize>(json['canva_size']);
  if (canvaSize != null) {
    printOptionData.canvaSize = canvaSize;
  }
  final bool? xHide = jsonConvert.convert<bool>(json['hide']);
  if (xHide != null) {
    printOptionData.xHide = xHide;
  }
  final String? contentUrl = jsonConvert.convert<String>(json['content_url']);
  if (contentUrl != null) {
    printOptionData.contentUrl = contentUrl;
  }
  final dynamic mediakitChannel =
      jsonConvert.convert<dynamic>(json['mediakit_channel']);
  if (mediakitChannel != null) {
    printOptionData.mediakitChannel = mediakitChannel;
  }
  final dynamic externalId = jsonConvert.convert<dynamic>(json['external_id']);
  if (externalId != null) {
    printOptionData.externalId = externalId;
  }
  final String? desc = jsonConvert.convert<String>(json['desc']);
  if (desc != null) {
    printOptionData.desc = desc;
  }
  final String? shopifyProductId =
      jsonConvert.convert<String>(json['shopify_product_id']);
  if (shopifyProductId != null) {
    printOptionData.shopifyProductId = shopifyProductId;
  }
  final String? created = jsonConvert.convert<String>(json['created']);
  if (created != null) {
    printOptionData.created = created;
  }
  final String? modified = jsonConvert.convert<String>(json['modified']);
  if (modified != null) {
    printOptionData.modified = modified;
  }
  final int? id = jsonConvert.convert<int>(json['id']);
  if (id != null) {
    printOptionData.id = id;
  }
  final dynamic contentStr = jsonConvert.convert<dynamic>(json['content_str']);
  if (contentStr != null) {
    printOptionData.contentStr = contentStr;
  }
  final int? key = jsonConvert.convert<int>(json['key']);
  if (key != null) {
    printOptionData.key = key;
  }
  final PrintOptionDataS3Files? s3Files =
      jsonConvert.convert<PrintOptionDataS3Files>(json['s3_files']);
  if (s3Files != null) {
    printOptionData.s3Files = s3Files;
  }
  final String? hashedId = jsonConvert.convert<String>(json['hashed_id']);
  if (hashedId != null) {
    printOptionData.hashedId = hashedId;
  }
  final Map<String, dynamic>? productColorMap =
      jsonConvert.convert<Map<String, dynamic>>(json['productColorMap']);
  if (productColorMap != null) {
    printOptionData.productColorMap = productColorMap;
  }
  return printOptionData;
}

Map<String, dynamic> $PrintOptionDataToJson(PrintOptionData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['type'] = entity.type;
  data['category'] = entity.category;
  data['title'] = entity.title;
  data['content'] = entity.content;
  data['tags'] = entity.tags;
  data['thumbnail'] = entity.thumbnail;
  data['thumbnail_large'] = entity.thumbnailLarge;
  data['user_id'] = entity.userId;
  data['display_order'] = entity.displayOrder;
  data['canva_size'] = entity.canvaSize.toJson();
  data['hide'] = entity.xHide;
  data['content_url'] = entity.contentUrl;
  data['mediakit_channel'] = entity.mediakitChannel;
  data['external_id'] = entity.externalId;
  data['desc'] = entity.desc;
  data['shopify_product_id'] = entity.shopifyProductId;
  data['created'] = entity.created;
  data['modified'] = entity.modified;
  data['id'] = entity.id;
  data['content_str'] = entity.contentStr;
  data['key'] = entity.key;
  data['s3_files'] = entity.s3Files.toJson();
  data['hashed_id'] = entity.hashedId;
  data['productColorMap'] = entity.productColorMap;
  return data;
}

PrintOptionDataCanvaSize $PrintOptionDataCanvaSizeFromJson(
    Map<String, dynamic> json) {
  final PrintOptionDataCanvaSize printOptionDataCanvaSize =
      PrintOptionDataCanvaSize();
  final int? width = jsonConvert.convert<int>(json['width']);
  if (width != null) {
    printOptionDataCanvaSize.width = width;
  }
  final int? height = jsonConvert.convert<int>(json['height']);
  if (height != null) {
    printOptionDataCanvaSize.height = height;
  }
  final int? ratio = jsonConvert.convert<int>(json['ratio']);
  if (ratio != null) {
    printOptionDataCanvaSize.ratio = ratio;
  }
  return printOptionDataCanvaSize;
}

Map<String, dynamic> $PrintOptionDataCanvaSizeToJson(
    PrintOptionDataCanvaSize entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['width'] = entity.width;
  data['height'] = entity.height;
  data['ratio'] = entity.ratio;
  return data;
}

PrintOptionDataS3Files $PrintOptionDataS3FilesFromJson(
    Map<String, dynamic> json) {
  final PrintOptionDataS3Files printOptionDataS3Files =
      PrintOptionDataS3Files();
  final String? tHUMBNAIL = jsonConvert.convert<String>(json['THUMBNAIL']);
  if (tHUMBNAIL != null) {
    printOptionDataS3Files.tHUMBNAIL = tHUMBNAIL;
  }
  final dynamic thumbnailLarge =
      jsonConvert.convert<dynamic>(json['THUMBNAIL_LARGE']);
  if (thumbnailLarge != null) {
    printOptionDataS3Files.thumbnailLarge = thumbnailLarge;
  }
  return printOptionDataS3Files;
}

Map<String, dynamic> $PrintOptionDataS3FilesToJson(
    PrintOptionDataS3Files entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['THUMBNAIL'] = entity.tHUMBNAIL;
  data['THUMBNAIL_LARGE'] = entity.thumbnailLarge;
  return data;
}
