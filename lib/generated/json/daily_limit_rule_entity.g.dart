import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/daily_limit_rule_entity.dart';

DailyLimitRuleEntity $DailyLimitRuleEntityFromJson(Map<String, dynamic> json) {
  final DailyLimitRuleEntity dailyLimitRuleEntity = DailyLimitRuleEntity();
  final VIPPlanDetail? cartoonize = jsonConvert.convert<VIPPlanDetail>(json['cartoonize']);
  if (cartoonize != null) {
    dailyLimitRuleEntity.cartoonize = cartoonize;
  }
  final VIPPlanDetail? videoRemovebg = jsonConvert.convert<VIPPlanDetail>(json['video_removebg']);
  if (videoRemovebg != null) {
    dailyLimitRuleEntity.videoRemovebg = videoRemovebg;
  }
  final VIPPlanDetail? removebg = jsonConvert.convert<VIPPlanDetail>(json['removebg']);
  if (removebg != null) {
    dailyLimitRuleEntity.removebg = removebg;
  }
  final VIPPlanDetail? stylemorph = jsonConvert.convert<VIPPlanDetail>(json['stylemorph']);
  if (stylemorph != null) {
    dailyLimitRuleEntity.stylemorph = stylemorph;
  }
  final VIPPlanDetail? anotherme = jsonConvert.convert<VIPPlanDetail>(json['anotherme']);
  if (anotherme != null) {
    dailyLimitRuleEntity.anotherme = anotherme;
  }
  final VIPPlanDetail? txt2img = jsonConvert.convert<VIPPlanDetail>(json['txt2img']);
  if (txt2img != null) {
    dailyLimitRuleEntity.txt2img = txt2img;
  }
  final VIPPlanDetail? scribble = jsonConvert.convert<VIPPlanDetail>(json['scribble']);
  if (scribble != null) {
    dailyLimitRuleEntity.scribble = scribble;
  }
  final VIPPlanDetail? inpaint = jsonConvert.convert<VIPPlanDetail>(json['inpaint']);
  if (inpaint != null) {
    dailyLimitRuleEntity.inpaint = inpaint;
  }
  return dailyLimitRuleEntity;
}

Map<String, dynamic> $DailyLimitRuleEntityToJson(DailyLimitRuleEntity entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['cartoonize'] = entity.cartoonize?.toJson();
  data['video_removebg'] = entity.videoRemovebg?.toJson();
  data['removebg'] = entity.removebg?.toJson();
  data['stylemorph'] = entity.stylemorph?.toJson();
  data['anotherme'] = entity.anotherme?.toJson();
  data['txt2img'] = entity.txt2img?.toJson();
  data['scribble'] = entity.scribble?.toJson();
  data['inpaint'] = entity.inpaint?.toJson();
  return data;
}

VIPPlanDetail $VIPPlanDetailFromJson(Map<String, dynamic> json) {
  final VIPPlanDetail vIPPlanDetail = VIPPlanDetail();
  final int? anonymous = jsonConvert.convert<int>(json['anonymous']);
  if (anonymous != null) {
    vIPPlanDetail.anonymous = anonymous;
  }
  final int? user = jsonConvert.convert<int>(json['user']);
  if (user != null) {
    vIPPlanDetail.user = user;
  }
  final int? plan = jsonConvert.convert<int>(json['plan']);
  if (plan != null) {
    vIPPlanDetail.plan = plan;
  }
  final int? parent = jsonConvert.convert<int>(json['parent']);
  if (parent != null) {
    vIPPlanDetail.parent = parent;
  }
  final int? child = jsonConvert.convert<int>(json['child']);
  if (child != null) {
    vIPPlanDetail.child = child;
  }
  return vIPPlanDetail;
}

Map<String, dynamic> $VIPPlanDetailToJson(VIPPlanDetail entity) {
  final Map<String, dynamic> data = <String, dynamic>{};
  data['anonymous'] = entity.anonymous;
  data['user'] = entity.user;
  data['plan'] = entity.plan;
  data['parent'] = entity.parent;
  data['child'] = entity.child;
  return data;
}
