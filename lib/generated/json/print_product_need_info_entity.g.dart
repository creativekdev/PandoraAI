import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/print_product_need_info_entity.dart';

PrintProductNeedInfoEntity $PrintProductNeedInfoEntityFromJson(Map<String, dynamic> json) {
	final PrintProductNeedInfoEntity printProductNeedInfoEntity = PrintProductNeedInfoEntity();
	final int? width = jsonConvert.convert<int>(json['width']);
	if (width != null) {
		printProductNeedInfoEntity.width = width;
	}
	final int? height = jsonConvert.convert<int>(json['height']);
	if (height != null) {
		printProductNeedInfoEntity.height = height;
	}
	final double? ratio = jsonConvert.convert<double>(json['ratio']);
	if (ratio != null) {
		printProductNeedInfoEntity.ratio = ratio;
	}
	final List<PrintProductNeedInfoPages>? pages = jsonConvert.convertListNotNull<PrintProductNeedInfoPages>(json['pages']);
	if (pages != null) {
		printProductNeedInfoEntity.pages = pages;
	}
	final PrintProductNeedInfoPrintInfo? printInfo = jsonConvert.convert<PrintProductNeedInfoPrintInfo>(json['printInfo']);
	if (printInfo != null) {
		printProductNeedInfoEntity.printInfo = printInfo;
	}
	final int? modified = jsonConvert.convert<int>(json['modified']);
	if (modified != null) {
		printProductNeedInfoEntity.modified = modified;
	}
	return printProductNeedInfoEntity;
}

Map<String, dynamic> $PrintProductNeedInfoEntityToJson(PrintProductNeedInfoEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['width'] = entity.width;
	data['height'] = entity.height;
	data['ratio'] = entity.ratio;
	data['pages'] =  entity.pages.map((v) => v.toJson()).toList();
	data['printInfo'] = entity.printInfo.toJson();
	data['modified'] = entity.modified;
	return data;
}

PrintProductNeedInfoPages $PrintProductNeedInfoPagesFromJson(Map<String, dynamic> json) {
	final PrintProductNeedInfoPages printProductNeedInfoPages = PrintProductNeedInfoPages();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		printProductNeedInfoPages.id = id;
	}
	final List<dynamic>? children = jsonConvert.convertListNotNull<dynamic>(json['children']);
	if (children != null) {
		printProductNeedInfoPages.children = children;
	}
	final String? width = jsonConvert.convert<String>(json['width']);
	if (width != null) {
		printProductNeedInfoPages.width = width;
	}
	final String? height = jsonConvert.convert<String>(json['height']);
	if (height != null) {
		printProductNeedInfoPages.height = height;
	}
	final String? background = jsonConvert.convert<String>(json['background']);
	if (background != null) {
		printProductNeedInfoPages.background = background;
	}
	final int? bleed = jsonConvert.convert<int>(json['bleed']);
	if (bleed != null) {
		printProductNeedInfoPages.bleed = bleed;
	}
	return printProductNeedInfoPages;
}

Map<String, dynamic> $PrintProductNeedInfoPagesToJson(PrintProductNeedInfoPages entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['children'] =  entity.children;
	data['width'] = entity.width;
	data['height'] = entity.height;
	data['background'] = entity.background;
	data['bleed'] = entity.bleed;
	return data;
}

PrintProductNeedInfoPrintInfo $PrintProductNeedInfoPrintInfoFromJson(Map<String, dynamic> json) {
	final PrintProductNeedInfoPrintInfo printProductNeedInfoPrintInfo = PrintProductNeedInfoPrintInfo();
	final String? url = jsonConvert.convert<String>(json['url']);
	if (url != null) {
		printProductNeedInfoPrintInfo.url = url;
	}
	final double? width = jsonConvert.convert<double>(json['width']);
	if (width != null) {
		printProductNeedInfoPrintInfo.width = width;
	}
	final double? height = jsonConvert.convert<double>(json['height']);
	if (height != null) {
		printProductNeedInfoPrintInfo.height = height;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		printProductNeedInfoPrintInfo.name = name;
	}
	final String? title = jsonConvert.convert<String>(json['title']);
	if (title != null) {
		printProductNeedInfoPrintInfo.title = title;
	}
	final String? size = jsonConvert.convert<String>(json['size']);
	if (size != null) {
		printProductNeedInfoPrintInfo.size = size;
	}
	final List<PrintProductNeedInfoPrintInfoPages>? pages = jsonConvert.convertListNotNull<PrintProductNeedInfoPrintInfoPages>(json['pages']);
	if (pages != null) {
		printProductNeedInfoPrintInfo.pages = pages;
	}
	final Map<String, dynamic>? productColorMap = jsonConvert.convert<Map<String, dynamic>>(json['productColorMap']);
	if (productColorMap != null) {
		printProductNeedInfoPrintInfo.productColorMap = productColorMap;
	}
	final String? shopifyProductId = jsonConvert.convert<String>(json['shopifyProductId']);
	if (shopifyProductId != null) {
		printProductNeedInfoPrintInfo.shopifyProductId = shopifyProductId;
	}
	return printProductNeedInfoPrintInfo;
}

Map<String, dynamic> $PrintProductNeedInfoPrintInfoToJson(PrintProductNeedInfoPrintInfo entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['url'] = entity.url;
	data['width'] = entity.width;
	data['height'] = entity.height;
	data['name'] = entity.name;
	data['title'] = entity.title;
	data['size'] = entity.size;
	data['pages'] =  entity.pages.map((v) => v.toJson()).toList();
	data['productColorMap'] = entity.productColorMap;
	data['shopifyProductId'] = entity.shopifyProductId;
	return data;
}

PrintProductNeedInfoPrintInfoPages $PrintProductNeedInfoPrintInfoPagesFromJson(Map<String, dynamic> json) {
	final PrintProductNeedInfoPrintInfoPages printProductNeedInfoPrintInfoPages = PrintProductNeedInfoPrintInfoPages();
	final double? x = jsonConvert.convert<double>(json['x']);
	if (x != null) {
		printProductNeedInfoPrintInfoPages.x = x;
	}
	final double? y = jsonConvert.convert<double>(json['y']);
	if (y != null) {
		printProductNeedInfoPrintInfoPages.y = y;
	}
	final double? width = jsonConvert.convert<double>(json['width']);
	if (width != null) {
		printProductNeedInfoPrintInfoPages.width = width;
	}
	final double? height = jsonConvert.convert<double>(json['height']);
	if (height != null) {
		printProductNeedInfoPrintInfoPages.height = height;
	}
	final int? rotation = jsonConvert.convert<int>(json['rotation']);
	if (rotation != null) {
		printProductNeedInfoPrintInfoPages.rotation = rotation;
	}
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		printProductNeedInfoPrintInfoPages.id = id;
	}
	final int? printPageIndex = jsonConvert.convert<int>(json['printPageIndex']);
	if (printPageIndex != null) {
		printProductNeedInfoPrintInfoPages.printPageIndex = printPageIndex;
	}
	final String? type = jsonConvert.convert<String>(json['type']);
	if (type != null) {
		printProductNeedInfoPrintInfoPages.type = type;
	}
	return printProductNeedInfoPrintInfoPages;
}

Map<String, dynamic> $PrintProductNeedInfoPrintInfoPagesToJson(PrintProductNeedInfoPrintInfoPages entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['x'] = entity.x;
	data['y'] = entity.y;
	data['width'] = entity.width;
	data['height'] = entity.height;
	data['rotation'] = entity.rotation;
	data['id'] = entity.id;
	data['printPageIndex'] = entity.printPageIndex;
	data['type'] = entity.type;
	return data;
}