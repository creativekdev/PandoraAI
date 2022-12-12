import 'dart:convert';
import 'package:cartoonizer/generated/json/base/json_field.dart';
import 'package:cartoonizer/generated/json/pay_plan_entity.g.dart';

@JsonSerializable()
class PayPlanEntity {
  @JSONField(name: "stripe_plan_id")
  String stripePlanId = '';
  @JSONField(name: "plan_name")
  String planName = '';
  String detail = '';
  String type = '';
  int limit = 0;
  String price = '';
  int duration = 0;
  String created = '';
  String modified = '';
  int id = 0;
  @JSONField(name: "only_once")
  int onlyOnce = 0;
  @JSONField(name: "hide")
  int xHide = 0;
  int level = 0;
  @JSONField(name: "profile_credit")
  int profileCredit = 0;
  String category = '';
  String payload = '';
  @JSONField(name: "email_limit")
  String emailLimit = '';
  @JSONField(name: "free_trial_days")
  int freeTrialDays = 0;
  String currency = '';
  @JSONField(name: "dm_limit")
  String dmLimit = '';
  @JSONField(name: "email_campaign_credit")
  int emailCampaignCredit = 0;
  @JSONField(name: "tiny_search_credit")
  int tinySearchCredit = 0;
  @JSONField(name: "display_core_user_limit")
  int displayCoreUserLimit = 0;
  @JSONField(name: "api_limit")
  int apiLimit = 0;
  @JSONField(name: "product_credit")
  int productCredit = 0;
  @JSONField(name: "show_profile_level")
  int showProfileLevel = 0;
  String promotion = '';
  @JSONField(name: "renew_prices")
  String renewPrices = '';
  @JSONField(name: "has_coupon")
  int hasCoupon = 0;
  @JSONField(name: "free_trial_price")
  int freeTrialPrice = 0;
  String role = '';
  @JSONField(name: "course_purchased")
  int coursePurchased = 0;
  @JSONField(name: "image_credit")
  int imageCredit = 0;
  @JSONField(name: "image_preview_credit")
  int imagePreviewCredit = 0;
  @JSONField(name: "affiliate_rate")
  int affiliateRate = 0;
  @JSONField(name: "email_plan")
  int emailPlan = 0;
  @JSONField(name: "video_credit")
  int videoCredit = 0;
  @JSONField(name: "cartoonize_credit")
  int cartoonizeCredit = 0;
  String sku = '';
  @JSONField(name: "sku_category")
  String skuCategory = '';
  @JSONField(name: "apple_store_plan_id")
  String appleStorePlanId = '';
  @JSONField(name: "google_play_plan_id")
  String googlePlayPlanId = '';
  @JSONField(name: "ai_avatar_credit")
  int aiAvatarCredit = 0;
  @JSONField(name: "user_id")
  int userId = 0;

  PayPlanEntity();

  factory PayPlanEntity.fromJson(Map<String, dynamic> json) => $PayPlanEntityFromJson(json);

  Map<String, dynamic> toJson() => $PayPlanEntityToJson(this);

  @override
  String toString() {
    return jsonEncode(this);
  }
}
