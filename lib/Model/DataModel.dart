import 'EffectModel.dart';

class DataModel {
  late List<EffectModel> face;
  DataModel({
    required this.face,
  });

  DataModel.fromJson(Map<String, dynamic> json) {
    final arr0 = <EffectModel>[];
    json.keys.forEach((element) {
      if(json[element] != null){
        json[element].forEach((v) {
          arr0.add(EffectModel.fromJson(v));
        });
      }
    });
    face = (arr0);
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    if (face != null) {
      final v = face;
      final arr0 = [];
      v.forEach((v) {
        arr0.add(v.toJson());
      });
      data['face'] = arr0;
    }
    return data;
  }
}
