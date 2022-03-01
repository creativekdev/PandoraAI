class EffectModel {
  late String key;
  late String display_name = "";
  late List<String> effects;

  EffectModel({
    required this.key,
    required this.effects,
    required this.display_name,
  });
  EffectModel.fromJson(Map<String, dynamic> json) {
    display_name = json['display_name'].toString();
    key = json['key'].toString();
    if (json['effects'] != null) {
      final v = json['effects'];
      final arr0 = <String>[];
      v.forEach((v) {
        arr0.add(v.toString());
      });
      effects = arr0;
    }
    //
    // final arr0 = <String>[];
    // json.keys.forEach((element) {
    //   if(json[element] != null){
    //     json[element].forEach((v) {
    //       arr0.add(v.toString());
    //     });
    //   }
    // });
    // effects = arr0;
  }
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['key'] = key;
    data['display_name'] = display_name;
    if (effects != null) {
      final v = effects;
      final arr0 = [];
      v.forEach((v) {
        arr0.add(v);
      });
      data['effects'] = arr0;
    }
    return data;
  }
}