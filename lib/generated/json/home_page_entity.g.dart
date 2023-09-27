import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/home_page_entity.dart';
import 'package:cartoonizer/generated/json/base/json_convert_content.dart';

import 'package:cartoonizer/models/discovery_list_entity.dart';

import 'package:cartoonizer/models/enums/home_card_type.dart';

import 'package:cartoonizer/models/enums/home_item.dart';


HomePageHomepageTools $HomePageHomepageToolsFromJson(Map<String, dynamic> json) {
	final HomePageHomepageTools homePageHomepageTools = HomePageHomepageTools();
	final String? categoryString = jsonConvert.convert<String>(json['category']);
	if (categoryString != null) {
		homePageHomepageTools.categoryString = categoryString;
	}
	final String? typeString = jsonConvert.convert<String>(json['resource_type']);
	if (typeString != null) {
		homePageHomepageTools.typeString = typeString;
	}
	final String? url = jsonConvert.convert<String>(json['url']);
	if (url != null) {
		homePageHomepageTools.url = url;
	}
	final String? payload = jsonConvert.convert<String>(json['payload']);
	if (payload != null) {
		homePageHomepageTools.payload = payload;
	}
	final String? title = jsonConvert.convert<String>(json['title']);
	if (title != null) {
		homePageHomepageTools.title = title;
	}
	final String? cartoonizeKey = jsonConvert.convert<String>(json['cartoonize_key']);
	if (cartoonizeKey != null) {
		homePageHomepageTools.cartoonizeKey = cartoonizeKey;
	}
	return homePageHomepageTools;
}

Map<String, dynamic> $HomePageHomepageToolsToJson(HomePageHomepageTools entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['category'] = entity.categoryString;
	data['resource_type'] = entity.typeString;
	data['url'] = entity.url;
	data['payload'] = entity.payload;
	data['title'] = entity.title;
	data['cartoonize_key'] = entity.cartoonizeKey;
	return data;
}

HomeItemEntity $HomeItemEntityFromJson(Map<String, dynamic> json) {
	final HomeItemEntity homeItemEntity = HomeItemEntity();
	final String? key = jsonConvert.convert<String>(json['key']);
	if (key != null) {
		homeItemEntity.key = key;
	}
	final int? records = jsonConvert.convert<int>(json['records']);
	if (records != null) {
		homeItemEntity.records = records;
	}
	final String? backgroundImage = jsonConvert.convert<String>(json['background_image']);
	if (backgroundImage != null) {
		homeItemEntity.backgroundImage = backgroundImage;
	}
	final bool? hasBackground = jsonConvert.convert<bool>(json['has_background']);
	if (hasBackground != null) {
		homeItemEntity.hasBackground = hasBackground;
	}
	final String? enableCountries = jsonConvert.convert<String>(json['enable_countries']);
	if (enableCountries != null) {
		homeItemEntity.enableCountries = enableCountries;
	}
	final String? enableLanguages = jsonConvert.convert<String>(json['enable_languages']);
	if (enableLanguages != null) {
		homeItemEntity.enableLanguages = enableLanguages;
	}
	final String? mHomeItemString = jsonConvert.convert<String>(json['type']);
	if (mHomeItemString != null) {
		homeItemEntity.mHomeItemString = mHomeItemString;
	}
	final dynamic value = jsonConvert.convert<dynamic>(json['value']);
	if (value != null) {
		homeItemEntity.value = value;
	}
	return homeItemEntity;
}

Map<String, dynamic> $HomeItemEntityToJson(HomeItemEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['key'] = entity.key;
	data['records'] = entity.records;
	data['background_image'] = entity.backgroundImage;
	data['has_background'] = entity.hasBackground;
	data['enable_countries'] = entity.enableCountries;
	data['enable_languages'] = entity.enableLanguages;
	data['type'] = entity.mHomeItemString;
	data['value'] = entity.value;
	return data;
}