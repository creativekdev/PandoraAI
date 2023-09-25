import 'dart:convert';

import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/home_page_entity.g.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/models/enums/home_item.dart';

@JsonSerializable()
class HomePageEntity {
  late List<DiscoveryListEntity> banners;
  late List<HomePageHomepageTools> tools;
  late List<HomePageHomepageTools> features;
  late List<HomePageHomepageGalleries> galleries;

  HomePageEntity({
    List<DiscoveryListEntity>? banners,
    List<HomePageHomepageTools>? tools,
    List<HomePageHomepageTools>? features,
    List<HomePageHomepageGalleries>? galleries,
  }) {
    this.banners = banners ?? [];
    this.tools = tools ?? [];
    this.features = features ?? [];
    this.galleries = galleries ?? [];
  }

  factory HomePageEntity.fromJson(Map<String, dynamic> json) => $HomePageEntityFromJson(json);

  Map<String, dynamic> toJson() => $HomePageEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class HomePageHomepageTools {
  @JSONField(name: 'category')
  String? categoryString;

  @JSONField(serialize: false, deserialize: false)
  HomeCardType? _category;

  HomeCardType get category {
    if (_category == null) {
      _category = HomeCardTypeUtils.build(categoryString);
    }
    return _category!;
  }

  set category(HomeCardType type) {
    _category = type;
    categoryString = _category!.value();
  }

  @JSONField(name: 'resource_type')
  String? typeString;
  @JSONField(serialize: false, deserialize: false)
  DiscoveryResourceType? _resourceType;

  DiscoveryResourceType get resourceType {
    if (_resourceType == null) {
      _resourceType = DiscoveryResourceTypeUtil.build(typeString);
    }
    return _resourceType!;
  }

  set resourceType(DiscoveryResourceType type) {
    _resourceType = type;
    typeString = _resourceType!.value();
  }

  late String url;
  String? payload;
  late String title;
  @JSONField(name: "cartoonize_key")
  String? cartoonizeKey;

  HomePageHomepageTools({String? url}) {
    this.url = url ?? '';
  }

  factory HomePageHomepageTools.fromJson(Map<String, dynamic> json) => $HomePageHomepageToolsFromJson(json);

  Map<String, dynamic> toJson() => $HomePageHomepageToolsToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class HomePageHomepageGalleries {
  @JSONField(name: 'category')
  String? categoryString;
  int? records;

  @JSONField(serialize: false, deserialize: false)
  HomeCardType? _category;

  HomeCardType get category {
    if (_category == null) {
      _category = HomeCardTypeUtils.build(categoryString);
    }
    return _category!;
  }

  set category(HomeCardType type) {
    _category = type;
    categoryString = _category!.value();
  }

  @JSONField(name: "social_posts")
  late List<DiscoveryListEntity> socialPosts;
  String? title;

  HomePageHomepageGalleries();

  factory HomePageHomepageGalleries.fromJson(Map<String, dynamic> json) => $HomePageHomepageGalleriesFromJson(json);

  Map<String, dynamic> toJson() => $HomePageHomepageGalleriesToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class HomeItemEntity {
  String? key;
  int records = 0;
  @JSONField(name: 'has_background')
  bool hasBackground = false;
  @JSONField(name: 'type')
  String? mHomeItemString;

  @JSONField(serialize: false, deserialize: false)
  HomeItem? _mHomeItem;

  HomeItem get mHomeItem {
    if (_mHomeItem == null) {
      _mHomeItem = HomeItemUtils.build(mHomeItemString);
    }
    return _mHomeItem!;
  }

  set mHomeItem(HomeItem type) {
    _mHomeItem = type;
    mHomeItemString = _mHomeItem!.value();
  }

  dynamic value;

  List<T> getDataList<T>() {
    if (value is List) {
      List<T> result = [];
      for (var e in value) {
        result.add(jsonConvert.convert<T>(e)!);
      }
      return result;
    } else {
      return <T>[];
    }
  }

  HomeItemEntity();

  factory HomeItemEntity.fromJson(Map<String, dynamic> json) => $HomeItemEntityFromJson(json);

  Map<String, dynamic> toJson() => $HomeItemEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
