import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/ad_config_entity.dart';

AdConfigEntity $AdConfigEntityFromJson(Map<String, dynamic> json) {
  final AdConfigEntity adConfigEntity = AdConfigEntity();
  final int? splash = jsonConvert.convert<int>(json['splash']);
  if (splash != null) {
    adConfigEntity.splash = splash;
  }
  final int? card = jsonConvert.convert<int>(json['card']);
  if (card != null) {
    adConfigEntity.card = card;
  }
  final int? processing = jsonConvert.convert<int>(json['processing']);
  if (processing != null) {
    adConfigEntity.processing = processing;
  }
  return adConfigEntity;
}

Map<String, dynamic> $AdConfigEntityToJson(AdConfigEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['splash'] = entity.splash;
  data['card'] = entity.card;
  data['processing'] = entity.processing;
  return data;
}
