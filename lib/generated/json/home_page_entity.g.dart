import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/home_page_entity.dart';

HomePageEntity $HomePageEntityFromJson(Map<String, dynamic> json) {
  final HomePageEntity homePageEntity = HomePageEntity();
  final List<HomePageHomepageTools>? banners = jsonConvert.convertListNotNull<HomePageHomepageTools>(json['banners']);
  if (banners != null) {
    homePageEntity.banners = banners;
  }
  final List<HomePageHomepageTools>? tools = jsonConvert.convertListNotNull<HomePageHomepageTools>(json['tools']);
  if (tools != null) {
    homePageEntity.tools = tools;
  }
  final List<HomePageHomepageTools>? features = jsonConvert.convertListNotNull<HomePageHomepageTools>(json['features']);
  if (features != null) {
    homePageEntity.features = features;
  }
  final List<HomePageHomepageGalleries>? galleries = jsonConvert.convertListNotNull<HomePageHomepageGalleries>(json['galleries']);
  if (galleries != null) {
    homePageEntity.galleries = galleries;
  }
  return homePageEntity;
}

Map<String, dynamic> $HomePageEntityToJson(HomePageEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['banners'] = entity.banners.map((v) => v.toJson()).toList();
  data['tools'] = entity.tools.map((v) => v.toJson()).toList();
  data['features'] = entity.features.map((v) => v.toJson()).toList();
  data['galleries'] = entity.galleries.map((v) => v.toJson()).toList();
  return data;
}

HomePageHomepageTools $HomePageHomepageToolsFromJson(Map<String, dynamic> json) {
  final HomePageHomepageTools homePageHomepageTools = HomePageHomepageTools();
  final String? category = jsonConvert.convert<String>(json['category']);
  if (category != null) {
    homePageHomepageTools.category = category;
  }
  final String? resourceType = jsonConvert.convert<String>(json['resource_type']);
  if (resourceType != null) {
    homePageHomepageTools.resourceType = resourceType;
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
  data['category'] = entity.category;
  data['resource_type'] = entity.resourceType;
  data['url'] = entity.url;
  data['payload'] = entity.payload;
  data['title'] = entity.title;
  data['cartoonize_key'] = entity.cartoonizeKey;
  return data;
}

HomePageHomepageGalleries $HomePageHomepageGalleriesFromJson(Map<String, dynamic> json) {
  final HomePageHomepageGalleries homePageHomepageGalleries = HomePageHomepageGalleries();
  final String? category = jsonConvert.convert<String>(json['category']);
  if (category != null) {
    homePageHomepageGalleries.category = category;
  }
  final List<DiscoveryListEntity>? socialPosts = jsonConvert.convertListNotNull<DiscoveryListEntity>(json['social_posts']);
  if (socialPosts != null) {
    homePageHomepageGalleries.socialPosts = socialPosts;
  }
  final String? title = jsonConvert.convert<String>(json['title']);
  if (title != null) {
    homePageHomepageGalleries.title = title;
  }
  return homePageHomepageGalleries;
}

Map<String, dynamic> $HomePageHomepageGalleriesToJson(HomePageHomepageGalleries entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['category'] = entity.category;
  data['social_posts'] = entity.socialPosts.map((v) => v.toJson()).toList();
  data['title'] = entity.title;
  return data;
}