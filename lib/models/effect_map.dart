import 'EffectModel.dart';

class EffectMap {
  late Map<String, dynamic> data;
  late Map<String, dynamic> locale;

  EffectMap({
    required this.data,
    required this.locale,
  });

  EffectMap.fromJson(Map<String, dynamic> json) {
    this.data = json['data'];
    this.locale = json['locale'];
  }

  Map<String, dynamic> toJson() {
    return {'data': data, 'locale': locale};
  }
}

extension EffectMapEx on EffectMap {
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
        element.displayName = effectLocalName(key, defaultName: element.category);
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
    return locale[key] ?? dn;
  }

  String effectLocalName(String key, {String? defaultName}) {
    String dn = key;
    if (defaultName != null) {
      dn = defaultName;
    }
    return locale['key']?[key] ?? dn;
  }
}