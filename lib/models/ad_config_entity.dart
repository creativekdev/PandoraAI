import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/ad_config_entity.g.dart';

@JsonSerializable()
class AdConfigEntity {
  int splash;
  int card;
  int processing;

  AdConfigEntity({
    this.splash = 0,
    this.card = 0,
    this.processing = 1,
  });

  factory AdConfigEntity.fromJson(Map<String, dynamic> json) => $AdConfigEntityFromJson(json);

  Map<String, dynamic> toJson() => $AdConfigEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
