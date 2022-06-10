class EffectModel {
  late String key = '';
  late String displayName = '';
  late String style = '';
  late Map<String, EffectItem> effects;
  late String defaultEffect;
  late List<dynamic> thumbnails;

  EffectModel({
    required this.key,
    required this.defaultEffect,
    Map<String, EffectItem>? effects,
    List<dynamic>? thumbnails,
    this.displayName = '',
    this.style = '',
  }) {
    this.effects = effects ?? {};
    this.thumbnails = thumbnails ?? [];
  }

  EffectModel.fromJson(Map<String, dynamic> json) {
    key = json['key'].toString();
    defaultEffect = (json['default_effect'] ?? '').toString();
    var effectsMap = (json['effects'] ?? {}) as Map<String, dynamic>;
    effects = effectsMap.map((key, value) => MapEntry(key, EffectItem.fromJson(value)));
    thumbnails = json['thumbnails'] ?? [];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    data['default_effect'] = defaultEffect;
    data['effects'] = effects.map((key, value) => MapEntry(key, value.toJson()));
    data['thumbnails'] = thumbnails;
    return data;
  }
}

class EffectItem {
  late String key;
  late String algoname;
  late String stickerName;
  late String category;
  late String type;
  late String server;
  late bool originalFace;
  late String imageUrl;
  late String created;
  late String modified;
  late String id;
  late String displayName;

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
    return data;
  }
}

class EffectItemListData {
  String key;
  int pos;
  EffectItem item;

  EffectItemListData({
    required this.key,
    required this.pos,
    required this.item,
  });
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
  String getShownUrl({int? pos}) {
    switch (key) {
      case 'transform':
        return "https://d35b8pv2lrtup8.cloudfront.net/assets/video/$key${pos ?? ''}.webp";
      default:
        return 'https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/$key${pos ?? ''}.jpg';
    }
  }
}

extension EffectModelEx on EffectModel {
  String getShownUrl({int? pos}) {
    switch (key) {
      case 'transform':
        return "https://d35b8pv2lrtup8.cloudfront.net/assets/video/$key${pos ?? ''}.webp";
      default:
        return 'https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/$key${pos ?? ''}.jpg';
    }
  }

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
