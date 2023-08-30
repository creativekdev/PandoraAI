import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/print_product_entity.g.dart';
import 'dart:convert';

@JsonSerializable()
class PrintProductEntity {
  late PrintProductData data;

  PrintProductEntity();

  factory PrintProductEntity.fromJson(Map<String, dynamic> json) => $PrintProductEntityFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintProductData {
  late List<PrintProductDataRows> rows;

  PrintProductData();

  factory PrintProductData.fromJson(Map<String, dynamic> json) => $PrintProductDataFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductDataToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintProductDataRows {
  late String id;
  late String title;
  late String description;
  late String descriptionHtml;
  late String onlineStorePreviewUrl;
  late PrintProductDataRowsFeaturedImage featuredImage;
  late String status;
  late PrintProductDataRowsVariants variants;

  PrintProductDataRows();

  factory PrintProductDataRows.fromJson(Map<String, dynamic> json) => $PrintProductDataRowsFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductDataRowsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintProductDataRowsFeaturedImage {
  late String originalSrc;

  PrintProductDataRowsFeaturedImage();

  factory PrintProductDataRowsFeaturedImage.fromJson(Map<String, dynamic> json) => $PrintProductDataRowsFeaturedImageFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductDataRowsFeaturedImageToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintProductDataRowsVariants {
  late List<PrintProductDataRowsVariantsEdges> edges;

  PrintProductDataRowsVariants();

  factory PrintProductDataRowsVariants.fromJson(Map<String, dynamic> json) => $PrintProductDataRowsVariantsFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductDataRowsVariantsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintProductDataRowsVariantsEdges {
  late PrintProductDataRowsVariantsEdgesNode node;

  PrintProductDataRowsVariantsEdges();

  factory PrintProductDataRowsVariantsEdges.fromJson(Map<String, dynamic> json) => $PrintProductDataRowsVariantsEdgesFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductDataRowsVariantsEdgesToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintProductDataRowsVariantsEdgesNode {
  late String price;
  late String title;
  late int weight;
  late int inventoryQuantity;
  dynamic image;
  late List<PrintProductDataRowsVariantsEdgesNodeSelectedOptions> selectedOptions;
  late String id;

  PrintProductDataRowsVariantsEdgesNode();

  factory PrintProductDataRowsVariantsEdgesNode.fromJson(Map<String, dynamic> json) => $PrintProductDataRowsVariantsEdgesNodeFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductDataRowsVariantsEdgesNodeToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintProductDataRowsVariantsEdgesNodeSelectedOptions {
  late String name;
  late String value;

  PrintProductDataRowsVariantsEdgesNodeSelectedOptions();

  factory PrintProductDataRowsVariantsEdgesNodeSelectedOptions.fromJson(Map<String, dynamic> json) => $PrintProductDataRowsVariantsEdgesNodeSelectedOptionsFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductDataRowsVariantsEdgesNodeSelectedOptionsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
