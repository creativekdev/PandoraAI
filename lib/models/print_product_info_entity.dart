import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/print_product_info_entity.g.dart';

@JsonSerializable()
class PrintProductInfoEntity {
  late int width;
  late int height;
  late int ratio;
  late List<PrintProductInfoPages> pages;
  late PrintProductInfoPrintInfo printInfo;
  late int modified;

  PrintProductInfoEntity();

  factory PrintProductInfoEntity.fromJson(Map<String, dynamic> json) =>
      $PrintProductInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductInfoEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintProductInfoPages {
  late String id;
  List<dynamic>? children;
  late String width;
  late String height;
  late String background;
  late int bleed;

  PrintProductInfoPages();

  factory PrintProductInfoPages.fromJson(Map<String, dynamic> json) =>
      $PrintProductInfoPagesFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductInfoPagesToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintProductInfoPrintInfo {
  late String url;
  late int width;
  late int height;
  late String name;
  late String title;
  late String size;
  late List<PrintProductInfoPrintInfoPages> pages;
  late Map<String, dynamic> productColorMap;
  late String shopifyProductId;

  PrintProductInfoPrintInfo();

  factory PrintProductInfoPrintInfo.fromJson(Map<String, dynamic> json) =>
      $PrintProductInfoPrintInfoFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductInfoPrintInfoToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintProductInfoPrintInfoPages {
  late double x;
  late double y;
  late int width;
  late int height;
  late int rotation;
  late String id;
  late int printPageIndex;
  late String type;

  PrintProductInfoPrintInfoPages();

  factory PrintProductInfoPrintInfoPages.fromJson(Map<String, dynamic> json) =>
      $PrintProductInfoPrintInfoPagesFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductInfoPrintInfoPagesToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
