import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/daily_limit_rule_entity.g.dart';

@JsonSerializable()
class DailyLimitRuleEntity {
  VIPPlanDetail? cartoonize;
  @JSONField(name: 'video_removebg')
  VIPPlanDetail? videoRemovebg;
  VIPPlanDetail? removebg;
  VIPPlanDetail? stylemorph;
  VIPPlanDetail? anotherme;
  VIPPlanDetail? txt2img;
  VIPPlanDetail? scribble;
  VIPPlanDetail? inpaint;

  DailyLimitRuleEntity();

  factory DailyLimitRuleEntity.fromJson(Map<String, dynamic> json) => $DailyLimitRuleEntityFromJson(json);

  Map<String, dynamic> toJson() => $DailyLimitRuleEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}

@JsonSerializable()
class VIPPlanDetail {
  int anonymous = 0;
  int user = 0;
  int plan = 0;
  int? parent;
  int? child;

  VIPPlanDetail();

  factory VIPPlanDetail.fromJson(Map<String, dynamic> json) => $VIPPlanDetailFromJson(json);

  Map<String, dynamic> toJson() => $VIPPlanDetailToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
