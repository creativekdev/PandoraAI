class EffectModel {
  late String key;
  late String style = "";
  late String display_name = "";
  late Map<String, dynamic> effects;

  EffectModel({
    required this.key,
    required this.effects,
    required this.display_name,
  });

  EffectModel.fromJson(Map<String, dynamic> json, String style) {
    display_name = json['key'] == 'animation' ? "Animation" : json['display_name'].toString();
    key = json['key'].toString();
    effects = json['effects'];
    this.style = style;
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
