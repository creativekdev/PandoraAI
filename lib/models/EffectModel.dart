class EffectModel {
  late String key = '';
  late String style = "";
  late String display_name = "";
  late Map<String, dynamic> effects;

  EffectModel({
    required this.key,
    required this.effects,
    required this.display_name,
    required this.style,
  });

  EffectModel.fromJson(Map<String, dynamic> json, String style) {
    display_name = json['key'] == 'animation'
        ? "Animation"
        : json['display_name'].toString();
    key = json['key'].toString();
    effects = json['effects'];
    this.style = style;
  }

  EffectModel.fromCacheJson(Map<String, dynamic> json) {
    display_name = json['key'] == 'animation'
        ? "Animation"
        : json['display_name'].toString();
    key = json['key'].toString();
    effects = json['effects'];
    style = json['style'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    data['style'] = style;
    data['display_name'] = key == 'animation' ? "Animation" : display_name;
    data['effects'] = effects;
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
    key = json['key']??'';
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['lastTime'] = lastTime;
    data['key'] = key;
    return data;
  }
}

extension EffectModelEx on EffectModel {
  String getShownUrl({int? pos}) {
    switch (key) {
      case 'transform':
        return "https://d35b8pv2lrtup8.cloudfront.net/assets/video/$key${pos ?? ''}.webp";
      default:
        return 'https://d35b8pv2lrtup8.cloudfront.net/assets/cartoonize/$key${pos ?? '.mobile'}.jpg';
    }
  }
}
