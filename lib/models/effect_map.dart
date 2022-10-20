import 'package:cartoonizer/common/importFile.dart';

import 'EffectModel.dart';

class EffectMap {
  late Map<String, dynamic> data;
  late Map<String, dynamic> locale;
  CampaignTab? campaignTab;

  EffectMap({
    required this.data,
    required this.locale,
    this.campaignTab,
  });

  EffectMap.fromJson(Map<String, dynamic> json) {
    this.data = json['data'];
    this.locale = json['locale'];
    if (json['campaign_tab'] != null) {
      campaignTab = CampaignTab.fromJson(json['campaign_tab']);
    }
  }

  Map<String, dynamic> toJson() {
    var map = {
      'data': data,
      'locale': locale,
    };
    if (campaignTab != null) {
      map['campaign_tab'] = campaignTab!.toJson();
    }
    return map;
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

extension EffectMapEx on EffectMap {
  int tabPos(String childKey) {
    var keys = data.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      var list = effectList(keys[i]);
      var pick = list.pick((e) {
        var item = e.effects.values.toList().pick((t) => t.key == childKey);
        return item != null;
      });
      if (pick != null) {
        return i;
      }
    }
    return -1;
  }

  MapEntry<String, List<EffectModel>>? targetSeries(String childKey) {
    for (var key in data.keys) {
      var list = effectList(key);
      var pick = list.pick((e) {
        var item = e.effects.values.toList().pick((t) => t.key == childKey);
        return item != null;
      });
      if (pick != null) {
        return MapEntry(key, list);
      }
    }
    return null;
  }

  List<EffectModel> allEffectList() {
    List<EffectModel> result = [];
    data.keys.forEach((element) {
      result.addAll(effectList(element));
    });
    return result;
  }

  List<EffectModel> effectList(String key) {
    List<EffectModel> result = [];
    Map<String, dynamic> json = data[key];
    json.forEach((key, value) {
      var effect = EffectModel.fromJson(value);
      effect.effects.values.forEach((element) {
        element.displayName = localeName(element.key, defaultName: element.category);
      });
      effect.displayName = effectLocalName(key);
      effect.style = key;
      result.add(effect);
    });
    return result;
  }

  String localeName(String key, {String? defaultName}) {
    String dn = key;
    if (defaultName != null) {
      dn = defaultName;
    }
    return locale[key] ?? locale[dn] ?? effectLocalName(key, defaultName: defaultName);
  }

  String effectLocalName(String key, {String? defaultName}) {
    String dn = key;
    if (defaultName != null) {
      dn = defaultName;
    }
    return locale['key']?[key] ?? locale['key']?[dn] ?? dn;
  }
}

class EffectPosHolder {
  int tabPos;
  int categoryPos;
  int itemPos;

  EffectPosHolder({required this.tabPos, required this.categoryPos, required this.itemPos});
}
