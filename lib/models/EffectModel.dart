import 'package:cartoonizer/models/api_config_entity.dart';

class EffectItemListData {
  String key = '';
  String uniqueKey = '';
  int pos = 0;
  EffectItem? item = null;

  EffectItemListData({
    this.key = '',
    this.pos = 0,
    this.item,
    this.uniqueKey = '',
  });

  EffectItemListData.fromJson(Map<String, dynamic> json, Map<String, dynamic> locale) {
    key = json['key'] ?? '';
    pos = json['pos'] ?? 0;
    uniqueKey = json['uniqueKey'] ?? '';
    var jsonItem = json['item'] as Map<String, dynamic>?;
    if (jsonItem != null) {
      item = EffectItem.fromJson(jsonItem, locale);
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    data['pos'] = pos;
    data['uniqueKey'] = uniqueKey;
    data['item'] = item?.toJson();
    return data;
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
