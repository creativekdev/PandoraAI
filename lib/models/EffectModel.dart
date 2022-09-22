class EffectModel {
  late String key = '';
  late String displayName = '';
  late String style = '';
  late Map<String, EffectItem> effects;
  late String defaultEffect;
  late List<String> thumbnails;
  late String thumbnail;
  late String tag;

  EffectModel({
    required this.key,
    required this.defaultEffect,
    Map<String, EffectItem>? effects,
    List<String>? thumbnails,
    this.displayName = '',
    this.style = '',
    this.tag = '',
    this.thumbnail = '',
  }) {
    this.effects = effects ?? {};
    this.thumbnails = thumbnails ?? [];
  }

  EffectModel.fromJson(Map<String, dynamic> json) {
    key = (json['key'] ?? '').toString();
    defaultEffect = (json['default_effect'] ?? '').toString();
    var effectsMap = (json['effects'] ?? {}) as Map<String, dynamic>;
    effects = effectsMap.map((key, value) => MapEntry(key, EffectItem.fromJson(value)));
    thumbnails = ((json['thumbnails'] ?? []) as List).map((e) => e.toString()).toList();
    displayName = (json['display_name'] ?? '').toString();
    style = (json['style'] ?? '').toString();
    tag = (json['tag'] ?? '').toString();
    thumbnail = (json['thumbnail'] ?? '').toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    data['default_effect'] = defaultEffect;
    data['effects'] = effects.map((key, value) => MapEntry(key, value.toJson()));
    data['thumbnails'] = thumbnails;
    data['display_name'] = displayName;
    data['style'] = style;
    data['tag'] = tag;
    data['thumbnail'] = thumbnail;
    return data;
  }
}

class EffectItem {
  late String key;
  late String algoname;
  late String stickerName;
  late String templateName;
  late String category;
  late String type;
  late String server;
  late bool originalFace;
  late String imageUrl;
  late String created;
  late String modified;
  late String id;
  late String displayName;
  late String tag;

  EffectItem({
    this.key = '',
    this.type = '',
    this.id = '',
    this.algoname = '',
    this.category = '',
    this.created = '',
    this.imageUrl = '',
    this.modified = '',
    this.originalFace = false,
    this.server = '',
    this.stickerName = '',
    this.displayName = '',
    this.tag = '',
    this.templateName = '',
  });

  EffectItem.fromJson(Map<String, dynamic> json) {
    key = (json['key'] ?? '').toString();
    type = (json['type'] ?? '').toString();
    id = (json['id'] ?? '').toString();
    algoname = (json['algoname'] ?? '').toString();
    category = (json['category'] ?? '').toString();
    created = (json['created'] ?? '').toString();
    imageUrl = (json['image_url'] ?? '').toString();
    modified = (json['modified'] ?? '').toString();
    originalFace = (json['original_face'] ?? false);
    server = (json['server'] ?? '').toString();
    stickerName = (json['sticker_name'] ?? '').toString();
    templateName = (json['template_name'] ?? '').toString();
    displayName = (json['display_name'] ?? '').toString();
    tag = (json['tag'] ?? '').toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    data['type'] = type;
    data['id'] = id;
    data['algoname'] = algoname;
    data['category'] = category;
    data['created'] = created;
    data['image_url'] = imageUrl;
    data['modified'] = modified;
    data['original_face'] = originalFace;
    data['server'] = server;
    data['sticker_name'] = stickerName;
    data['template_name'] = templateName;
    data['display_name'] = displayName;
    data['tag'] = tag;
    return data;
  }
}

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

  EffectItemListData.fromJson(Map<String, dynamic> json) {
    key = json['key'] ?? '';
    pos = json['pos'] ?? 0;
    uniqueKey = json['uniqueKey'] ?? '';
    var jsonItem = json['item'] as Map<String, dynamic>?;
    if (jsonItem != null) {
      item = EffectItem.fromJson(jsonItem);
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

class RecentEffectModel {
  late int lastTime;
  late String key;

  RecentEffectModel({
    required this.lastTime,
    required this.key,
  });

  RecentEffectModel.fromJson(Map<String, dynamic> json) {
    lastTime = json['lastTime'] ?? 0;
    key = json['key'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['lastTime'] = lastTime;
    data['key'] = key;
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

extension EffectModelEx on EffectModel {
  int getDefaultPos() {
    var keys = effects.keys.toList();
    for (int i = 0; i < keys.length; i++) {
      if (keys[i] == defaultEffect) {
        return i;
      }
    }
    return 0;
  }
}
