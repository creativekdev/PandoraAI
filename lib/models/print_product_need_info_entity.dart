import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/print_product_need_info_entity.g.dart';

@JsonSerializable()
class PrintProductNeedInfoEntity {
  late int width;
  late int height;
  late double ratio;
  late List<PrintProductNeedInfoPages> pages;
  late PrintProductNeedInfoPrintInfo printInfo;
  late int modified;

  PrintProductNeedInfoEntity();

  factory PrintProductNeedInfoEntity.fromJson(Map<String, dynamic> json) => $PrintProductNeedInfoEntityFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductNeedInfoEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintProductNeedInfoPages {
  late String id;
  late List<dynamic> children;
  late String width;
  late String height;
  late String background;
  late int bleed;

  PrintProductNeedInfoPages();

  factory PrintProductNeedInfoPages.fromJson(Map<String, dynamic> json) => $PrintProductNeedInfoPagesFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductNeedInfoPagesToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintProductNeedInfoPrintInfo {
  late String url;
  late double width;
  late double height;
  late String name;
  late String title;
  late String size;
  late List<PrintProductNeedInfoPrintInfoPages> pages;
  late Map<String, dynamic> productColorMap;
  late String shopifyProductId;

  PrintProductNeedInfoPrintInfo();

  factory PrintProductNeedInfoPrintInfo.fromJson(Map<String, dynamic> json) => $PrintProductNeedInfoPrintInfoFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductNeedInfoPrintInfoToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class PrintProductNeedInfoPrintInfoPages {
  late double x;
  late double y;
  late double width;
  late double height;
  late int rotation;
  late String id;
  late int printPageIndex;
  late String type;

  PrintProductNeedInfoPrintInfoPages();

  factory PrintProductNeedInfoPrintInfoPages.fromJson(Map<String, dynamic> json) => $PrintProductNeedInfoPrintInfoPagesFromJson(json);

  Map<String, dynamic> toJson() => $PrintProductNeedInfoPrintInfoPagesToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
