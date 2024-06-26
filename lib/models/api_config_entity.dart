import 'dart:convert';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/main.dart';
import 'package:cartoonizer/models/ai_server_entity.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/home_card_entity.dart';
import 'package:cartoonizer/models/home_page_entity.dart';
import 'package:cartoonizer/models/shipping_method_entity.dart';
import 'package:cartoonizer/utils/map_util.dart';
import 'package:common_utils/common_utils.dart';

class ApiConfigEntity {
  List<EffectData> data = [];

  List<HomeItemEntity> homepage = [];
  Map<String, dynamic> locale = {};
  CampaignTab? campaignTab;
  List<String> tags = [];
  List<HomeCardEntity> homeCards = [];
  String? hash;
  List<DiscoveryResource> promotionResources = [];

  List<ShippingMethodEntity> shippingMethods = [];
  int imageMaxl = 512;
  int mattingMaxl = 512;
  int matting3rdParty = 0;
  List<AiServerEntity> aiConfig = [];

  EffectData? get stylemorph => data.pick((t) => t.key == 'stylemorph');

  EffectData? get cartoonize => data.pick((t) => t.key == 'cartoonize');

  EffectData? get sticker => data.pick((t) => t.key == 'sticker');

  List<EffectData> get datas => data.filter((t) => t.key != 'stylemorph');

  ApiConfigEntity._instance();

  factory ApiConfigEntity.fromJson(Map<String, dynamic> json) {
    ApiConfigEntity entity = ApiConfigEntity._instance();
    entity.locale = json['locale'] ?? {};
    if (json['data'] != null) {
      entity.data = [];
      Map<String, dynamic> data = json['data'];
      for (var key in data.keys) {
        entity.data.add(EffectData.fromJson(key, data[key], entity.locale));
      }
    }
    if (json['campaign_tab'] != null) {
      entity.campaignTab = CampaignTab.fromJson(json['campaign_tab']);
    }
    if (json['tags'] != null) {
      entity.tags = (json['tags'] as List).map((e) => e.toString()).toList();
    }
    if (json['home_functions'] != null) {
      entity.homeCards = (json['home_functions'] as List).map((e) => HomeCardEntity.fromJson(e)).toList();
    }
    if (json['hash'] != null) {
      entity.hash = json['hash'];
    }
    if (json['promotion_resources'] != null) {
      entity.promotionResources = (json['promotion_resources'] as List).map((e) => DiscoveryResource.fromJson(e)).toList();
    }
    if (json['shipping_methods'] != null) {
      entity.shippingMethods = (json['shipping_methods'] as List).map((e) => ShippingMethodEntity.fromJson(e)).toList();
    }
    if (json['image_maxl'] != null) {
      entity.imageMaxl = json['image_maxl'] as int;
    }
    if (json['matting_maxl'] != null) {
      entity.mattingMaxl = json['matting_maxl'] as int;
    }
    if (json['matting_3rd_party'] != null) {
      entity.matting3rdParty = json['matting_3rd_party'] as int;
    }
    if (json['ai_config'] != null) {
      entity.aiConfig = (json['ai_config'] as List).map((e) => AiServerEntity.fromJson(e)).toList();
    }
    if (json['homepage'] != null) {
      entity.homepage = (json['homepage'] as List).map((e) => HomeItemEntity.fromJson(e)).toList().filter((t) {
        if (TextUtil.isEmpty(t.enableLanguages)) {
          return true;
        } else {
          return t.enableLanguages.toLowerCase().contains(MyApp.currentLocales.toLowerCase());
        }
      });
    }
    return entity;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> result = {};
    result['data'] = data.map((e) => MapEntry(e.key, e.toJson())).toList().toMap();
    result['locale'] = locale;
    if (campaignTab != null) {
      result['campaign_tab'] = campaignTab!.toJson();
    }
    result['tags'] = tags;
    result['home_functions'] = homeCards.map((e) => e.toJson()).toList();
    if (hash != null) {
      result['hash'] = hash!;
    }
    result['promotion_resources'] = promotionResources.map((e) => e.toJson()).toList();
    result['shipping_methods'] = shippingMethods.map((e) => e.toJson()).toList();
    result['ai_config'] = aiConfig.map((e) => e.toJson()).toList();
    result['homepage'] = homepage.map((e) => e.toJson()).toList();
    result['image_maxl'] = imageMaxl;
    result['matting_maxl'] = mattingMaxl;
    result['matting_3rd_party'] = matting3rdParty;
    return result;
  }

  String toString() {
    return jsonEncode(toJson());
  }

  @override
  bool operator ==(Object other) {
    if (other is ApiConfigEntity) {
      return other.toString() == toString();
    } else {
      return false;
    }
  }
}

class EffectData {
  late String title;
  late String key;
  late List<EffectCategory> children;

  EffectData._instance();

  factory EffectData.fromJson(String key, Map<String, dynamic> json, Map<String, dynamic> locale) {
    EffectData entity = EffectData._instance();
    entity.key = key;
    entity.title = key.localeValue(locale);
    entity.children = json.values.map((e) => EffectCategory.fromJson(e, locale, key)).toList();
    return entity;
  }

  Map<String, dynamic> toJson() {
    return children.map((e) => MapEntry(e.key, e.toJson())).toList().toMap();
  }

  String toString() {
    return jsonEncode(toJson());
  }
}

class EffectCategory {
  late String key;
  late String title;
  late String defaultEffect;
  late List<String> thumbnails;
  late List<EffectItem> effects;
  late String thumbnail;
  late String tag;
  late bool isNsfw;
  late String category;

  EffectCategory._instance();

  factory EffectCategory.fromJson(Map<String, dynamic> json, Map<String, dynamic> locale, String category) {
    EffectCategory entity = EffectCategory._instance();
    entity.category = category;
    entity.key = (json['key'] ?? '').toString();
    entity.tag = (json['tag'] ?? '').toString();
    entity.title = entity.key.localeValue(locale);
    entity.thumbnail = (json['thumbnail'] ?? '').toString();
    entity.thumbnails = ((json['thumbnails'] ?? []) as List).map((e) => e.toString()).toList();
    entity.isNsfw = (json['is_nsfw'] ?? false);
    entity.effects = ((json['effects'] ?? {}) as Map<String, dynamic>).values.map((value) => EffectItem.fromJson(value, locale, category)).toList();
    if (json['default_effect'] != null) {
      entity.defaultEffect = json['default_effect'].toString();
    } else {
      if (entity.effects.isEmpty) {
        entity.defaultEffect = '';
      } else {
        entity.defaultEffect = entity.effects.first.key;
      }
    }
    return entity;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    data['tag'] = tag;
    data['thumbnail'] = thumbnail;
    data['thumbnails'] = thumbnails;
    data['is_nsfw'] = isNsfw;
    data['default_effect'] = defaultEffect;
    data['effects'] = effects.map((value) => MapEntry(value.key, value.toJson())).toList().toMap();
    return data;
  }

  String toString() {
    return jsonEncode(toJson());
  }
}

class EffectItem {
  late String id;
  late String key;
  late String title;
  late String algoName;
  late String stickerName;
  late String templateName;
  late String category;
  late String type;
  late String server;
  late bool originalFace;
  late String imageUrl;
  late String created;
  late String modified;
  late int featured;
  late bool isNsfw;
  late String tag;
  late List<String> tagList;
  late String parent;

  EffectItem._instance();

  factory EffectItem.fromJson(Map<String, dynamic> json, Map<String, dynamic> locale, String parent) {
    EffectItem entity = EffectItem._instance();
    entity.parent = parent;
    entity.id = (json['id'] ?? '').toString();
    entity.key = (json['key'] ?? '').toString();
    entity.category = (json['category'] ?? '').toString();
    entity.title = entity.key.localeValue(locale, defaultKey: entity.category);
    entity.type = (json['type'] ?? '').toString();
    entity.algoName = (json['algoname'] ?? '').toString();
    entity.created = (json['created'] ?? '').toString();
    entity.imageUrl = (json['image_url'] ?? '').toString();
    entity.modified = (json['modified'] ?? '').toString();
    entity.originalFace = (json['original_face'] ?? false);
    entity.server = (json['server'] ?? '').toString();
    entity.stickerName = (json['sticker_name'] ?? '').toString();
    entity.templateName = (json['template_name'] ?? '').toString();
    entity.featured = (json['featured'] ?? 0);
    entity.isNsfw = (json['is_nsfw'] ?? false);
    entity.tag = (json['tag'] ?? '').toString();
    if (entity.tag.isNotEmpty) {
      entity.tagList = entity.tag.split(',');
    } else {
      entity.tagList = [];
    }
    return entity;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    data['type'] = type;
    data['id'] = id;
    data['algoname'] = algoName;
    data['category'] = category;
    data['created'] = created;
    data['image_url'] = imageUrl;
    data['modified'] = modified;
    data['original_face'] = originalFace;
    data['server'] = server;
    data['sticker_name'] = stickerName;
    data['template_name'] = templateName;
    data['tag'] = tag;
    data['featured'] = featured;
    data['is_nsfw'] = isNsfw;
    return data;
  }
}

class CampaignTab {
  late String title;
  late String image;
  late String imageSelected;
  late String tag;

  CampaignTab({this.title = '', this.image = '', this.imageSelected = '', this.tag = ''});

  CampaignTab.fromJson(Map<String, dynamic> json) {
    this.title = json['title'] ?? '';
    this.image = json['image'] ?? '';
    this.imageSelected = json['image_selected'] ?? '';
    this.tag = json['tag'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'image': image,
      'image_selected': imageSelected,
      'tag': tag,
    };
  }
}

extension ApiConfigEntityEx on ApiConfigEntity {
  int tabPos(String effectKey) {
    int pos = -1;
    bool find = false;
    for (var i = 0; i < datas.length; i++) {
      var value = datas[i];
      if (find) {
        break;
      }
      for (var category in value.children) {
        if (find) {
          break;
        }
        for (var effect in category.effects) {
          if (effect.key == effectKey) {
            pos = i;
            find = true;
            break;
          }
        }
      }
    }
    return pos;
  }

  EffectCategory? findCategory(String effectKey) {
    for (var tab in datas) {
      for (var category in tab.children) {
        if (category.effects.exist((e) => e.key == effectKey)) {
          return category;
        }
      }
    }
    return null;
  }
}

extension TitleLocaleEx on String {
  String localeValue(Map<String, dynamic> locale, {String? defaultKey}) {
    var result = _localValue(locale, this);
    if (result != null) {
      return result;
    }
    if (defaultKey != null) {
      result = _localValue(locale, defaultKey);
      if (result != null) {
        return result;
      }
      return this;
    } else {
      return this;
    }
  }

  String? _localValue(Map<String, dynamic> locale, String key) {
    var result = locale[key];
    if (result != null) {
      return result;
    }
    result = locale['key'][key];
    if (result != null) {
      return result;
    }
    return null;
  }
}

extension EffectItemEx on EffectItem {
  handleApiParams(Map<String, dynamic> params) {
    if (type == 'sticker') {
      params['sticker_name'] = stickerName;
    } else if (type == 'template') {
      params['template_name'] = templateName;
    }
  }
}

extension EffectModelEx on EffectCategory {
  int getDefaultPos() {
    for (int i = 0; i < effects.length; i++) {
      if (effects[i].key == defaultEffect) {
        return i;
      }
    }
    return 0;
  }
}
