import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/print_product_entity.dart';

PrintProductEntity $PrintProductEntityFromJson(Map<String, dynamic> json) {
  final PrintProductEntity printProductEntity = PrintProductEntity();
  final PrintProductData? data =
      jsonConvert.convert<PrintProductData>(json['data']);
  if (data != null) {
    printProductEntity.data = data;
  }
  return printProductEntity;
}

Map<String, dynamic> $PrintProductEntityToJson(PrintProductEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['data'] = entity.data.toJson();
  return data;
}

PrintProductData $PrintProductDataFromJson(Map<String, dynamic> json) {
  final PrintProductData printProductData = PrintProductData();
  final List<PrintProductDataRows>? rows =
      jsonConvert.convertListNotNull<PrintProductDataRows>(json['rows']);
  if (rows != null) {
    printProductData.rows = rows;
  }
  return printProductData;
}

Map<String, dynamic> $PrintProductDataToJson(PrintProductData entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['rows'] = entity.rows.map((v) => v.toJson()).toList();
  return data;
}

PrintProductDataRows $PrintProductDataRowsFromJson(Map<String, dynamic> json) {
  final PrintProductDataRows printProductDataRows = PrintProductDataRows();
  final String? id = jsonConvert.convert<String>(json['id']);
  if (id != null) {
    printProductDataRows.id = id;
  }
  final String? title = jsonConvert.convert<String>(json['title']);
  if (title != null) {
    printProductDataRows.title = title;
  }
  final String? description = jsonConvert.convert<String>(json['description']);
  if (description != null) {
    printProductDataRows.description = description;
  }
  final String? descriptionHtml =
      jsonConvert.convert<String>(json['descriptionHtml']);
  if (descriptionHtml != null) {
    printProductDataRows.descriptionHtml = descriptionHtml;
  }
  final String? onlineStorePreviewUrl =
      jsonConvert.convert<String>(json['onlineStorePreviewUrl']);
  if (onlineStorePreviewUrl != null) {
    printProductDataRows.onlineStorePreviewUrl = onlineStorePreviewUrl;
  }
  final PrintProductDataRowsFeaturedImage? featuredImage = jsonConvert
      .convert<PrintProductDataRowsFeaturedImage>(json['featuredImage']);
  if (featuredImage != null) {
    printProductDataRows.featuredImage = featuredImage;
  }
  final String? status = jsonConvert.convert<String>(json['status']);
  if (status != null) {
    printProductDataRows.status = status;
  }
  final PrintProductDataRowsVariants? variants =
      jsonConvert.convert<PrintProductDataRowsVariants>(json['variants']);
  if (variants != null) {
    printProductDataRows.variants = variants;
  }
  return printProductDataRows;
}

Map<String, dynamic> $PrintProductDataRowsToJson(PrintProductDataRows entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['id'] = entity.id;
  data['title'] = entity.title;
  data['description'] = entity.description;
  data['descriptionHtml'] = entity.descriptionHtml;
  data['onlineStorePreviewUrl'] = entity.onlineStorePreviewUrl;
  data['featuredImage'] = entity.featuredImage.toJson();
  data['status'] = entity.status;
  data['variants'] = entity.variants.toJson();
  return data;
}

PrintProductDataRowsFeaturedImage $PrintProductDataRowsFeaturedImageFromJson(
    Map<String, dynamic> json) {
  final PrintProductDataRowsFeaturedImage printProductDataRowsFeaturedImage =
      PrintProductDataRowsFeaturedImage();
  final String? originalSrc = jsonConvert.convert<String>(json['originalSrc']);
  if (originalSrc != null) {
    printProductDataRowsFeaturedImage.originalSrc = originalSrc;
  }
  return printProductDataRowsFeaturedImage;
}

Map<String, dynamic> $PrintProductDataRowsFeaturedImageToJson(
    PrintProductDataRowsFeaturedImage entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['originalSrc'] = entity.originalSrc;
  return data;
}

PrintProductDataRowsVariants $PrintProductDataRowsVariantsFromJson(
    Map<String, dynamic> json) {
  final PrintProductDataRowsVariants printProductDataRowsVariants =
      PrintProductDataRowsVariants();
  final List<PrintProductDataRowsVariantsEdges>? edges = jsonConvert
      .convertListNotNull<PrintProductDataRowsVariantsEdges>(json['edges']);
  if (edges != null) {
    printProductDataRowsVariants.edges = edges;
  }
  return printProductDataRowsVariants;
}

Map<String, dynamic> $PrintProductDataRowsVariantsToJson(
    PrintProductDataRowsVariants entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['edges'] = entity.edges.map((v) => v.toJson()).toList();
  return data;
}

PrintProductDataRowsVariantsEdges $PrintProductDataRowsVariantsEdgesFromJson(
    Map<String, dynamic> json) {
  final PrintProductDataRowsVariantsEdges printProductDataRowsVariantsEdges =
      PrintProductDataRowsVariantsEdges();
  final PrintProductDataRowsVariantsEdgesNode? node =
      jsonConvert.convert<PrintProductDataRowsVariantsEdgesNode>(json['node']);
  if (node != null) {
    printProductDataRowsVariantsEdges.node = node;
  }
  return printProductDataRowsVariantsEdges;
}

Map<String, dynamic> $PrintProductDataRowsVariantsEdgesToJson(
    PrintProductDataRowsVariantsEdges entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['node'] = entity.node.toJson();
  return data;
}

PrintProductDataRowsVariantsEdgesNode
    $PrintProductDataRowsVariantsEdgesNodeFromJson(Map<String, dynamic> json) {
  final PrintProductDataRowsVariantsEdgesNode
      printProductDataRowsVariantsEdgesNode =
      PrintProductDataRowsVariantsEdgesNode();
  final String? price = jsonConvert.convert<String>(json['price']);
  if (price != null) {
    printProductDataRowsVariantsEdgesNode.price = price;
  }
  final String? title = jsonConvert.convert<String>(json['title']);
  if (title != null) {
    printProductDataRowsVariantsEdgesNode.title = title;
  }
  final int? weight = jsonConvert.convert<int>(json['weight']);
  if (weight != null) {
    printProductDataRowsVariantsEdgesNode.weight = weight;
  }
  final int? inventoryQuantity =
      jsonConvert.convert<int>(json['inventoryQuantity']);
  if (inventoryQuantity != null) {
    printProductDataRowsVariantsEdgesNode.inventoryQuantity = inventoryQuantity;
  }
  final dynamic image = jsonConvert.convert<dynamic>(json['image']);
  if (image != null) {
    printProductDataRowsVariantsEdgesNode.image = image;
  }
  final List<PrintProductDataRowsVariantsEdgesNodeSelectedOptions>?
      selectedOptions = jsonConvert.convertListNotNull<
              PrintProductDataRowsVariantsEdgesNodeSelectedOptions>(
          json['selectedOptions']);
  if (selectedOptions != null) {
    printProductDataRowsVariantsEdgesNode.selectedOptions = selectedOptions;
  }
  final String? id = jsonConvert.convert<String>(json['id']);
  if (id != null) {
    printProductDataRowsVariantsEdgesNode.id = id;
  }
  return printProductDataRowsVariantsEdgesNode;
}

Map<String, dynamic> $PrintProductDataRowsVariantsEdgesNodeToJson(
    PrintProductDataRowsVariantsEdgesNode entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['price'] = entity.price;
  data['title'] = entity.title;
  data['weight'] = entity.weight;
  data['inventoryQuantity'] = entity.inventoryQuantity;
  data['image'] = entity.image;
  data['selectedOptions'] =
      entity.selectedOptions.map((v) => v.toJson()).toList();
  data['id'] = entity.id;
  return data;
}

PrintProductDataRowsVariantsEdgesNodeSelectedOptions
    $PrintProductDataRowsVariantsEdgesNodeSelectedOptionsFromJson(
        Map<String, dynamic> json) {
  final PrintProductDataRowsVariantsEdgesNodeSelectedOptions
      printProductDataRowsVariantsEdgesNodeSelectedOptions =
      PrintProductDataRowsVariantsEdgesNodeSelectedOptions();
  final String? name = jsonConvert.convert<String>(json['name']);
  if (name != null) {
    printProductDataRowsVariantsEdgesNodeSelectedOptions.name = name;
  }
  final String? value = jsonConvert.convert<String>(json['value']);
  if (value != null) {
    printProductDataRowsVariantsEdgesNodeSelectedOptions.value = value;
  }
  return printProductDataRowsVariantsEdgesNodeSelectedOptions;
}

Map<String, dynamic>
    $PrintProductDataRowsVariantsEdgesNodeSelectedOptionsToJson(
        PrintProductDataRowsVariantsEdgesNodeSelectedOptions entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['name'] = entity.name;
  data['value'] = entity.value;
  return data;
}
