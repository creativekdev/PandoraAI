import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/print_product_info_entity.dart';

PrintProductInfoEntity $PrintProductInfoEntityFromJson(Map<String, dynamic> json) {
	final PrintProductInfoEntity printProductInfoEntity = PrintProductInfoEntity();
	final int? width = jsonConvert.convert<int>(json['width']);
	if (width != null) {
		printProductInfoEntity.width = width;
	}
	final int? height = jsonConvert.convert<int>(json['height']);
	if (height != null) {
		printProductInfoEntity.height = height;
	}
	final int? ratio = jsonConvert.convert<int>(json['ratio']);
	if (ratio != null) {
		printProductInfoEntity.ratio = ratio;
	}
	final List<PrintProductInfoPages>? pages = jsonConvert.convertListNotNull<PrintProductInfoPages>(json['pages']);
	if (pages != null) {
		printProductInfoEntity.pages = pages;
	}
	final PrintProductInfoPrintInfo? printInfo = jsonConvert.convert<PrintProductInfoPrintInfo>(json['printInfo']);
	if (printInfo != null) {
		printProductInfoEntity.printInfo = printInfo;
	}
	final int? modified = jsonConvert.convert<int>(json['modified']);
	if (modified != null) {
		printProductInfoEntity.modified = modified;
	}
	return printProductInfoEntity;
}

Map<String, dynamic> $PrintProductInfoEntityToJson(PrintProductInfoEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['width'] = entity.width;
	data['height'] = entity.height;
	data['ratio'] = entity.ratio;
	data['pages'] =  entity.pages.map((v) => v.toJson()).toList();
	data['printInfo'] = entity.printInfo.toJson();
	data['modified'] = entity.modified;
	return data;
}

PrintProductInfoPages $PrintProductInfoPagesFromJson(Map<String, dynamic> json) {
	final PrintProductInfoPages printProductInfoPages = PrintProductInfoPages();
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		printProductInfoPages.id = id;
	}
	final List<dynamic>? children = jsonConvert.convertListNotNull<dynamic>(json['children']);
	if (children != null) {
		printProductInfoPages.children = children;
	}
	final String? width = jsonConvert.convert<String>(json['width']);
	if (width != null) {
		printProductInfoPages.width = width;
	}
	final String? height = jsonConvert.convert<String>(json['height']);
	if (height != null) {
		printProductInfoPages.height = height;
	}
	final String? background = jsonConvert.convert<String>(json['background']);
	if (background != null) {
		printProductInfoPages.background = background;
	}
	final int? bleed = jsonConvert.convert<int>(json['bleed']);
	if (bleed != null) {
		printProductInfoPages.bleed = bleed;
	}
	return printProductInfoPages;
}

Map<String, dynamic> $PrintProductInfoPagesToJson(PrintProductInfoPages entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['id'] = entity.id;
	data['children'] =  entity.children;
	data['width'] = entity.width;
	data['height'] = entity.height;
	data['background'] = entity.background;
	data['bleed'] = entity.bleed;
	return data;
}

PrintProductInfoPrintInfo $PrintProductInfoPrintInfoFromJson(Map<String, dynamic> json) {
	final PrintProductInfoPrintInfo printProductInfoPrintInfo = PrintProductInfoPrintInfo();
	final String? url = jsonConvert.convert<String>(json['url']);
	if (url != null) {
		printProductInfoPrintInfo.url = url;
	}
	final int? width = jsonConvert.convert<int>(json['width']);
	if (width != null) {
		printProductInfoPrintInfo.width = width;
	}
	final int? height = jsonConvert.convert<int>(json['height']);
	if (height != null) {
		printProductInfoPrintInfo.height = height;
	}
	final String? name = jsonConvert.convert<String>(json['name']);
	if (name != null) {
		printProductInfoPrintInfo.name = name;
	}
	final String? title = jsonConvert.convert<String>(json['title']);
	if (title != null) {
		printProductInfoPrintInfo.title = title;
	}
	final String? size = jsonConvert.convert<String>(json['size']);
	if (size != null) {
		printProductInfoPrintInfo.size = size;
	}
	final List<PrintProductInfoPrintInfoPages>? pages = jsonConvert.convertListNotNull<PrintProductInfoPrintInfoPages>(json['pages']);
	if (pages != null) {
		printProductInfoPrintInfo.pages = pages;
	}
	final Map<String, dynamic>? productColorMap = jsonConvert.convert<Map<String, dynamic>>(json['productColorMap']);
	if (productColorMap != null) {
		printProductInfoPrintInfo.productColorMap = productColorMap;
	}
	final String? shopifyProductId = jsonConvert.convert<String>(json['shopifyProductId']);
	if (shopifyProductId != null) {
		printProductInfoPrintInfo.shopifyProductId = shopifyProductId;
	}
	return printProductInfoPrintInfo;
}

Map<String, dynamic> $PrintProductInfoPrintInfoToJson(PrintProductInfoPrintInfo entity) {
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

PrintProductInfoPrintInfoPages $PrintProductInfoPrintInfoPagesFromJson(Map<String, dynamic> json) {
	final PrintProductInfoPrintInfoPages printProductInfoPrintInfoPages = PrintProductInfoPrintInfoPages();
	final double? x = jsonConvert.convert<double>(json['x']);
	if (x != null) {
		printProductInfoPrintInfoPages.x = x;
	}
	final double? y = jsonConvert.convert<double>(json['y']);
	if (y != null) {
		printProductInfoPrintInfoPages.y = y;
	}
	final int? width = jsonConvert.convert<int>(json['width']);
	if (width != null) {
		printProductInfoPrintInfoPages.width = width;
	}
	final int? height = jsonConvert.convert<int>(json['height']);
	if (height != null) {
		printProductInfoPrintInfoPages.height = height;
	}
	final int? rotation = jsonConvert.convert<int>(json['rotation']);
	if (rotation != null) {
		printProductInfoPrintInfoPages.rotation = rotation;
	}
	final String? id = jsonConvert.convert<String>(json['id']);
	if (id != null) {
		printProductInfoPrintInfoPages.id = id;
	}
	final int? printPageIndex = jsonConvert.convert<int>(json['printPageIndex']);
	if (printPageIndex != null) {
		printProductInfoPrintInfoPages.printPageIndex = printPageIndex;
	}
	final String? type = jsonConvert.convert<String>(json['type']);
	if (type != null) {
		printProductInfoPrintInfoPages.type = type;
	}
	return printProductInfoPrintInfoPages;
}

Map<String, dynamic> $PrintProductInfoPrintInfoPagesToJson(PrintProductInfoPrintInfoPages entity) {
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