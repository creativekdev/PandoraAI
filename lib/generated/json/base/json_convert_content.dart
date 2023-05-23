// ignore_for_file: non_constant_identifier_names
// ignore_for_file: camel_case_types
// ignore_for_file: prefer_single_quotes

// This file is automatically generated. DO NOT EDIT, all your changes would be lost.
import 'package:flutter/material.dart' show debugPrint;
import 'package:cartoonizer/models/ad_config_entity.dart';
import 'package:cartoonizer/models/ai_draw_result_entity.dart';
import 'package:cartoonizer/models/another_me_result_entity.dart';
import 'package:cartoonizer/models/app_feature_entity.dart';
import 'package:cartoonizer/models/avatar_ai_list_entity.dart';
import 'package:cartoonizer/models/avatar_config_entity.dart';
import 'package:cartoonizer/models/crop_record_entity.dart';
import 'package:cartoonizer/models/daily_limit_rule_entity.dart';
import 'package:cartoonizer/models/discovery_comment_list_entity.dart';
import 'package:cartoonizer/models/discovery_list_entity.dart';
import 'package:cartoonizer/models/generate_limit_entity.dart';
import 'package:cartoonizer/models/home_card_entity.dart';
import 'package:cartoonizer/models/metagram_page_entity.dart';
import 'package:cartoonizer/models/msg_count_entity.dart';
import 'package:cartoonizer/models/msg_entity.dart';
import 'package:cartoonizer/models/page_entity.dart';
import 'package:cartoonizer/models/pay_plan_entity.dart';
import 'package:cartoonizer/models/platform_connection_entity.dart';
import 'package:cartoonizer/models/push_extra_entity.dart';
import 'package:cartoonizer/models/rate_config_entity.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/models/txt2img_result_entity.dart';
import 'package:cartoonizer/models/txt2img_style_entity.dart';
import 'package:cartoonizer/models/upload_record_entity.dart';
import 'package:cartoonizer/models/user_ref_link_entity.dart';

JsonConvert jsonConvert = JsonConvert();
typedef JsonConvertFunction<T> = T Function(Map<String, dynamic> json);
typedef EnumConvertFunction<T> = T Function(String value);

class JsonConvert {
	static final Map<String, JsonConvertFunction> convertFuncMap = {
		(AdConfigEntity).toString(): AdConfigEntity.fromJson,
		(AiDrawResultEntity).toString(): AiDrawResultEntity.fromJson,
		(AnotherMeResultEntity).toString(): AnotherMeResultEntity.fromJson,
		(AppFeatureEntity).toString(): AppFeatureEntity.fromJson,
		(AppFeaturePayload).toString(): AppFeaturePayload.fromJson,
		(AvatarAiListEntity).toString(): AvatarAiListEntity.fromJson,
		(AvatarChildEntity).toString(): AvatarChildEntity.fromJson,
		(AvatarConfigEntity).toString(): AvatarConfigEntity.fromJson,
		(AvatarConfigData).toString(): AvatarConfigData.fromJson,
		(CropRecordEntity).toString(): CropRecordEntity.fromJson,
		(DailyLimitRuleEntity).toString(): DailyLimitRuleEntity.fromJson,
		(VIPPlanDetail).toString(): VIPPlanDetail.fromJson,
		(DiscoveryCommentListEntity).toString(): DiscoveryCommentListEntity.fromJson,
		(DiscoveryListEntity).toString(): DiscoveryListEntity.fromJson,
		(DiscoveryResource).toString(): DiscoveryResource.fromJson,
		(GenerateLimitEntity).toString(): GenerateLimitEntity.fromJson,
		(HomeCardEntity).toString(): HomeCardEntity.fromJson,
		(MetagramPageEntity).toString(): MetagramPageEntity.fromJson,
		(SocialPostPageEntity).toString(): SocialPostPageEntity.fromJson,
		(MetagramItemEntity).toString(): MetagramItemEntity.fromJson,
		(MsgCountEntity).toString(): MsgCountEntity.fromJson,
		(MsgEntity).toString(): MsgEntity.fromJson,
		(MsgDiscoveryEntity).toString(): MsgDiscoveryEntity.fromJson,
		(PageEntity).toString(): PageEntity.fromJson,
		(MsgPageEntity).toString(): MsgPageEntity.fromJson,
		(PayPlanEntity).toString(): PayPlanEntity.fromJson,
		(PlatformConnectionEntity).toString(): PlatformConnectionEntity.fromJson,
		(PlatformConnectionCoreUser).toString(): PlatformConnectionCoreUser.fromJson,
		(PushExtraEntity).toString(): PushExtraEntity.fromJson,
		(PushModuleExtraEntity).toString(): PushModuleExtraEntity.fromJson,
		(RateConfigEntity).toString(): RateConfigEntity.fromJson,
		(RecentEffectModel).toString(): RecentEffectModel.fromJson,
		(RecentEffectItem).toString(): RecentEffectItem.fromJson,
		(RecentMetaverseEntity).toString(): RecentMetaverseEntity.fromJson,
		(RecentGroundEntity).toString(): RecentGroundEntity.fromJson,
		(Txt2imgResultEntity).toString(): Txt2imgResultEntity.fromJson,
		(Txt2imgStyleEntity).toString(): Txt2imgStyleEntity.fromJson,
		(UploadRecordEntity).toString(): UploadRecordEntity.fromJson,
		(UserRefLinkEntity).toString(): UserRefLinkEntity.fromJson,
	};

  T? convert<T>(dynamic value, {EnumConvertFunction? enumConvert}) {
    if (value == null) {
      return null;
    }
    if (value is T) {
      return value;
    }
    try {
      return _asT<T>(value, enumConvert: enumConvert);
    } catch (e, stackTrace) {
      debugPrint('asT<$T> $e $stackTrace');
      return null;
    }
  }

  List<T?>? convertList<T>(List<dynamic>? value, {EnumConvertFunction? enumConvert}) {
    if (value == null) {
      return null;
    }
    try {
      return value.map((dynamic e) => _asT<T>(e,enumConvert: enumConvert)).toList();
    } catch (e, stackTrace) {
      debugPrint('asT<$T> $e $stackTrace');
      return <T>[];
    }
  }

List<T>? convertListNotNull<T>(dynamic value, {EnumConvertFunction? enumConvert}) {
    if (value == null) {
      return null;
    }
    try {
      return (value as List<dynamic>).map((dynamic e) => _asT<T>(e,enumConvert: enumConvert)!).toList();
    } catch (e, stackTrace) {
      debugPrint('asT<$T> $e $stackTrace');
      return <T>[];
    }
  }

  T? _asT<T extends Object?>(dynamic value,
      {EnumConvertFunction? enumConvert}) {
    final String type = T.toString();
    final String valueS = value.toString();
    if (enumConvert != null) {
      return enumConvert(valueS) as T;
    } else if (type == "String") {
      return valueS as T;
    } else if (type == "int") {
      final int? intValue = int.tryParse(valueS);
      if (intValue == null) {
        return double.tryParse(valueS)?.toInt() as T?;
      } else {
        return intValue as T;
      }
    } else if (type == "double") {
      return double.parse(valueS) as T;
    } else if (type == "DateTime") {
      return DateTime.parse(valueS) as T;
    } else if (type == "bool") {
      if (valueS == '0' || valueS == '1') {
        return (valueS == '1') as T;
      }
      return (valueS == 'true') as T;
    } else if (type == "Map" || type.startsWith("Map<")) {
      return value as T;
    } else {
      if (convertFuncMap.containsKey(type)) {
        return convertFuncMap[type]!(Map<String, dynamic>.from(value)) as T;
      } else {
        throw UnimplementedError('$type unimplemented');
      }
    }
  }

	//list is returned by type
	static M? _getListChildType<M>(List<Map<String, dynamic>> data) {
		if(<AdConfigEntity>[] is M){
			return data.map<AdConfigEntity>((Map<String, dynamic> e) => AdConfigEntity.fromJson(e)).toList() as M;
		}
		if(<AiDrawResultEntity>[] is M){
			return data.map<AiDrawResultEntity>((Map<String, dynamic> e) => AiDrawResultEntity.fromJson(e)).toList() as M;
		}
		if(<AnotherMeResultEntity>[] is M){
			return data.map<AnotherMeResultEntity>((Map<String, dynamic> e) => AnotherMeResultEntity.fromJson(e)).toList() as M;
		}
		if(<AppFeatureEntity>[] is M){
			return data.map<AppFeatureEntity>((Map<String, dynamic> e) => AppFeatureEntity.fromJson(e)).toList() as M;
		}
		if(<AppFeaturePayload>[] is M){
			return data.map<AppFeaturePayload>((Map<String, dynamic> e) => AppFeaturePayload.fromJson(e)).toList() as M;
		}
		if(<AvatarAiListEntity>[] is M){
			return data.map<AvatarAiListEntity>((Map<String, dynamic> e) => AvatarAiListEntity.fromJson(e)).toList() as M;
		}
		if(<AvatarChildEntity>[] is M){
			return data.map<AvatarChildEntity>((Map<String, dynamic> e) => AvatarChildEntity.fromJson(e)).toList() as M;
		}
		if(<AvatarConfigEntity>[] is M){
			return data.map<AvatarConfigEntity>((Map<String, dynamic> e) => AvatarConfigEntity.fromJson(e)).toList() as M;
		}
		if(<AvatarConfigData>[] is M){
			return data.map<AvatarConfigData>((Map<String, dynamic> e) => AvatarConfigData.fromJson(e)).toList() as M;
		}
		if(<CropRecordEntity>[] is M){
			return data.map<CropRecordEntity>((Map<String, dynamic> e) => CropRecordEntity.fromJson(e)).toList() as M;
		}
		if(<DailyLimitRuleEntity>[] is M){
			return data.map<DailyLimitRuleEntity>((Map<String, dynamic> e) => DailyLimitRuleEntity.fromJson(e)).toList() as M;
		}
		if(<VIPPlanDetail>[] is M){
			return data.map<VIPPlanDetail>((Map<String, dynamic> e) => VIPPlanDetail.fromJson(e)).toList() as M;
		}
		if(<DiscoveryCommentListEntity>[] is M){
			return data.map<DiscoveryCommentListEntity>((Map<String, dynamic> e) => DiscoveryCommentListEntity.fromJson(e)).toList() as M;
		}
		if(<DiscoveryListEntity>[] is M){
			return data.map<DiscoveryListEntity>((Map<String, dynamic> e) => DiscoveryListEntity.fromJson(e)).toList() as M;
		}
		if(<DiscoveryResource>[] is M){
			return data.map<DiscoveryResource>((Map<String, dynamic> e) => DiscoveryResource.fromJson(e)).toList() as M;
		}
		if(<GenerateLimitEntity>[] is M){
			return data.map<GenerateLimitEntity>((Map<String, dynamic> e) => GenerateLimitEntity.fromJson(e)).toList() as M;
		}
		if(<HomeCardEntity>[] is M){
			return data.map<HomeCardEntity>((Map<String, dynamic> e) => HomeCardEntity.fromJson(e)).toList() as M;
		}
		if(<MetagramPageEntity>[] is M){
			return data.map<MetagramPageEntity>((Map<String, dynamic> e) => MetagramPageEntity.fromJson(e)).toList() as M;
		}
		if(<SocialPostPageEntity>[] is M){
			return data.map<SocialPostPageEntity>((Map<String, dynamic> e) => SocialPostPageEntity.fromJson(e)).toList() as M;
		}
		if(<MetagramItemEntity>[] is M){
			return data.map<MetagramItemEntity>((Map<String, dynamic> e) => MetagramItemEntity.fromJson(e)).toList() as M;
		}
		if(<MsgCountEntity>[] is M){
			return data.map<MsgCountEntity>((Map<String, dynamic> e) => MsgCountEntity.fromJson(e)).toList() as M;
		}
		if(<MsgEntity>[] is M){
			return data.map<MsgEntity>((Map<String, dynamic> e) => MsgEntity.fromJson(e)).toList() as M;
		}
		if(<MsgDiscoveryEntity>[] is M){
			return data.map<MsgDiscoveryEntity>((Map<String, dynamic> e) => MsgDiscoveryEntity.fromJson(e)).toList() as M;
		}
		if(<PageEntity>[] is M){
			return data.map<PageEntity>((Map<String, dynamic> e) => PageEntity.fromJson(e)).toList() as M;
		}
		if(<MsgPageEntity>[] is M){
			return data.map<MsgPageEntity>((Map<String, dynamic> e) => MsgPageEntity.fromJson(e)).toList() as M;
		}
		if(<PayPlanEntity>[] is M){
			return data.map<PayPlanEntity>((Map<String, dynamic> e) => PayPlanEntity.fromJson(e)).toList() as M;
		}
		if(<PlatformConnectionEntity>[] is M){
			return data.map<PlatformConnectionEntity>((Map<String, dynamic> e) => PlatformConnectionEntity.fromJson(e)).toList() as M;
		}
		if(<PlatformConnectionCoreUser>[] is M){
			return data.map<PlatformConnectionCoreUser>((Map<String, dynamic> e) => PlatformConnectionCoreUser.fromJson(e)).toList() as M;
		}
		if(<PushExtraEntity>[] is M){
			return data.map<PushExtraEntity>((Map<String, dynamic> e) => PushExtraEntity.fromJson(e)).toList() as M;
		}
		if(<PushModuleExtraEntity>[] is M){
			return data.map<PushModuleExtraEntity>((Map<String, dynamic> e) => PushModuleExtraEntity.fromJson(e)).toList() as M;
		}
		if(<RateConfigEntity>[] is M){
			return data.map<RateConfigEntity>((Map<String, dynamic> e) => RateConfigEntity.fromJson(e)).toList() as M;
		}
		if(<RecentEffectModel>[] is M){
			return data.map<RecentEffectModel>((Map<String, dynamic> e) => RecentEffectModel.fromJson(e)).toList() as M;
		}
		if(<RecentEffectItem>[] is M){
			return data.map<RecentEffectItem>((Map<String, dynamic> e) => RecentEffectItem.fromJson(e)).toList() as M;
		}
		if(<RecentMetaverseEntity>[] is M){
			return data.map<RecentMetaverseEntity>((Map<String, dynamic> e) => RecentMetaverseEntity.fromJson(e)).toList() as M;
		}
		if(<RecentGroundEntity>[] is M){
			return data.map<RecentGroundEntity>((Map<String, dynamic> e) => RecentGroundEntity.fromJson(e)).toList() as M;
		}
		if(<Txt2imgResultEntity>[] is M){
			return data.map<Txt2imgResultEntity>((Map<String, dynamic> e) => Txt2imgResultEntity.fromJson(e)).toList() as M;
		}
		if(<Txt2imgStyleEntity>[] is M){
			return data.map<Txt2imgStyleEntity>((Map<String, dynamic> e) => Txt2imgStyleEntity.fromJson(e)).toList() as M;
		}
		if(<UploadRecordEntity>[] is M){
			return data.map<UploadRecordEntity>((Map<String, dynamic> e) => UploadRecordEntity.fromJson(e)).toList() as M;
		}
		if(<UserRefLinkEntity>[] is M){
			return data.map<UserRefLinkEntity>((Map<String, dynamic> e) => UserRefLinkEntity.fromJson(e)).toList() as M;
		}

		debugPrint("${M.toString()} not found");
	
		return null;
}

	static M? fromJsonAsT<M>(dynamic json) {
		if (json is List) {
			return _getListChildType<M>(json.map((e) => e as Map<String, dynamic>).toList());
		} else {
			return jsonConvert.convert<M>(json);
		}
	}
}