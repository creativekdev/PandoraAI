import 'package:cartoonizer/generated/json/base/json_convert_content.dart';
import 'package:cartoonizer/models/pay_plan_entity.dart';

PayPlanEntity $PayPlanEntityFromJson(Map<String, dynamic> json) {
	final PayPlanEntity payPlanEntity = PayPlanEntity();
	final String? stripePlanId = jsonConvert.convert<String>(json['stripe_plan_id']);
	if (stripePlanId != null) {
		payPlanEntity.stripePlanId = stripePlanId;
	}
	final String? planName = jsonConvert.convert<String>(json['plan_name']);
	if (planName != null) {
		payPlanEntity.planName = planName;
	}
	final String? detail = jsonConvert.convert<String>(json['detail']);
	if (detail != null) {
		payPlanEntity.detail = detail;
	}
	final String? type = jsonConvert.convert<String>(json['type']);
	if (type != null) {
		payPlanEntity.type = type;
	}
	final int? limit = jsonConvert.convert<int>(json['limit']);
	if (limit != null) {
		payPlanEntity.limit = limit;
	}
	final String? price = jsonConvert.convert<String>(json['price']);
	if (price != null) {
		payPlanEntity.price = price;
	}
	final int? duration = jsonConvert.convert<int>(json['duration']);
	if (duration != null) {
		payPlanEntity.duration = duration;
	}
	final String? created = jsonConvert.convert<String>(json['created']);
	if (created != null) {
		payPlanEntity.created = created;
	}
	final String? modified = jsonConvert.convert<String>(json['modified']);
	if (modified != null) {
		payPlanEntity.modified = modified;
	}
	final int? id = jsonConvert.convert<int>(json['id']);
	if (id != null) {
		payPlanEntity.id = id;
	}
	final int? onlyOnce = jsonConvert.convert<int>(json['only_once']);
	if (onlyOnce != null) {
		payPlanEntity.onlyOnce = onlyOnce;
	}
	final int? xHide = jsonConvert.convert<int>(json['hide']);
	if (xHide != null) {
		payPlanEntity.xHide = xHide;
	}
	final int? level = jsonConvert.convert<int>(json['level']);
	if (level != null) {
		payPlanEntity.level = level;
	}
	final int? profileCredit = jsonConvert.convert<int>(json['profile_credit']);
	if (profileCredit != null) {
		payPlanEntity.profileCredit = profileCredit;
	}
	final String? category = jsonConvert.convert<String>(json['category']);
	if (category != null) {
		payPlanEntity.category = category;
	}
	final String? payload = jsonConvert.convert<String>(json['payload']);
	if (payload != null) {
		payPlanEntity.payload = payload;
	}
	final String? emailLimit = jsonConvert.convert<String>(json['email_limit']);
	if (emailLimit != null) {
		payPlanEntity.emailLimit = emailLimit;
	}
	final int? freeTrialDays = jsonConvert.convert<int>(json['free_trial_days']);
	if (freeTrialDays != null) {
		payPlanEntity.freeTrialDays = freeTrialDays;
	}
	final String? currency = jsonConvert.convert<String>(json['currency']);
	if (currency != null) {
		payPlanEntity.currency = currency;
	}
	final String? dmLimit = jsonConvert.convert<String>(json['dm_limit']);
	if (dmLimit != null) {
		payPlanEntity.dmLimit = dmLimit;
	}
	final int? emailCampaignCredit = jsonConvert.convert<int>(json['email_campaign_credit']);
	if (emailCampaignCredit != null) {
		payPlanEntity.emailCampaignCredit = emailCampaignCredit;
	}
	final int? tinySearchCredit = jsonConvert.convert<int>(json['tiny_search_credit']);
	if (tinySearchCredit != null) {
		payPlanEntity.tinySearchCredit = tinySearchCredit;
	}
	final int? displayCoreUserLimit = jsonConvert.convert<int>(json['display_core_user_limit']);
	if (displayCoreUserLimit != null) {
		payPlanEntity.displayCoreUserLimit = displayCoreUserLimit;
	}
	final int? apiLimit = jsonConvert.convert<int>(json['api_limit']);
	if (apiLimit != null) {
		payPlanEntity.apiLimit = apiLimit;
	}
	final int? productCredit = jsonConvert.convert<int>(json['product_credit']);
	if (productCredit != null) {
		payPlanEntity.productCredit = productCredit;
	}
	final int? showProfileLevel = jsonConvert.convert<int>(json['show_profile_level']);
	if (showProfileLevel != null) {
		payPlanEntity.showProfileLevel = showProfileLevel;
	}
	final String? promotion = jsonConvert.convert<String>(json['promotion']);
	if (promotion != null) {
		payPlanEntity.promotion = promotion;
	}
	final String? renewPrices = jsonConvert.convert<String>(json['renew_prices']);
	if (renewPrices != null) {
		payPlanEntity.renewPrices = renewPrices;
	}
	final int? hasCoupon = jsonConvert.convert<int>(json['has_coupon']);
	if (hasCoupon != null) {
		payPlanEntity.hasCoupon = hasCoupon;
	}
	final int? freeTrialPrice = jsonConvert.convert<int>(json['free_trial_price']);
	if (freeTrialPrice != null) {
		payPlanEntity.freeTrialPrice = freeTrialPrice;
	}
	final String? role = jsonConvert.convert<String>(json['role']);
	if (role != null) {
		payPlanEntity.role = role;
	}
	final int? coursePurchased = jsonConvert.convert<int>(json['course_purchased']);
	if (coursePurchased != null) {
		payPlanEntity.coursePurchased = coursePurchased;
	}
	final int? imageCredit = jsonConvert.convert<int>(json['image_credit']);
	if (imageCredit != null) {
		payPlanEntity.imageCredit = imageCredit;
	}
	final int? imagePreviewCredit = jsonConvert.convert<int>(json['image_preview_credit']);
	if (imagePreviewCredit != null) {
		payPlanEntity.imagePreviewCredit = imagePreviewCredit;
	}
	final int? affiliateRate = jsonConvert.convert<int>(json['affiliate_rate']);
	if (affiliateRate != null) {
		payPlanEntity.affiliateRate = affiliateRate;
	}
	final int? emailPlan = jsonConvert.convert<int>(json['email_plan']);
	if (emailPlan != null) {
		payPlanEntity.emailPlan = emailPlan;
	}
	final int? videoCredit = jsonConvert.convert<int>(json['video_credit']);
	if (videoCredit != null) {
		payPlanEntity.videoCredit = videoCredit;
	}
	final int? cartoonizeCredit = jsonConvert.convert<int>(json['cartoonize_credit']);
	if (cartoonizeCredit != null) {
		payPlanEntity.cartoonizeCredit = cartoonizeCredit;
	}
	final String? sku = jsonConvert.convert<String>(json['sku']);
	if (sku != null) {
		payPlanEntity.sku = sku;
	}
	final String? skuCategory = jsonConvert.convert<String>(json['sku_category']);
	if (skuCategory != null) {
		payPlanEntity.skuCategory = skuCategory;
	}
	final String? appleStorePlanId = jsonConvert.convert<String>(json['apple_store_plan_id']);
	if (appleStorePlanId != null) {
		payPlanEntity.appleStorePlanId = appleStorePlanId;
	}
	final String? googlePlayPlanId = jsonConvert.convert<String>(json['google_play_plan_id']);
	if (googlePlayPlanId != null) {
		payPlanEntity.googlePlayPlanId = googlePlayPlanId;
	}
	final int? aiAvatarCredit = jsonConvert.convert<int>(json['ai_avatar_credit']);
	if (aiAvatarCredit != null) {
		payPlanEntity.aiAvatarCredit = aiAvatarCredit;
	}
	final int? userId = jsonConvert.convert<int>(json['user_id']);
	if (userId != null) {
		payPlanEntity.userId = userId;
	}
	return payPlanEntity;
}

Map<String, dynamic> $PayPlanEntityToJson(PayPlanEntity entity) {
	final Map<String, dynamic> data = <String, dynamic>{};
	data['stripe_plan_id'] = entity.stripePlanId;
	data['plan_name'] = entity.planName;
	data['detail'] = entity.detail;
	data['type'] = entity.type;
	data['limit'] = entity.limit;
	data['price'] = entity.price;
	data['duration'] = entity.duration;
	data['created'] = entity.created;
	data['modified'] = entity.modified;
	data['id'] = entity.id;
	data['only_once'] = entity.onlyOnce;
	data['hide'] = entity.xHide;
	data['level'] = entity.level;
	data['profile_credit'] = entity.profileCredit;
	data['category'] = entity.category;
	data['payload'] = entity.payload;
	data['email_limit'] = entity.emailLimit;
	data['free_trial_days'] = entity.freeTrialDays;
	data['currency'] = entity.currency;
	data['dm_limit'] = entity.dmLimit;
	data['email_campaign_credit'] = entity.emailCampaignCredit;
	data['tiny_search_credit'] = entity.tinySearchCredit;
	data['display_core_user_limit'] = entity.displayCoreUserLimit;
	data['api_limit'] = entity.apiLimit;
	data['product_credit'] = entity.productCredit;
	data['show_profile_level'] = entity.showProfileLevel;
	data['promotion'] = entity.promotion;
	data['renew_prices'] = entity.renewPrices;
	data['has_coupon'] = entity.hasCoupon;
	data['free_trial_price'] = entity.freeTrialPrice;
	data['role'] = entity.role;
	data['course_purchased'] = entity.coursePurchased;
	data['image_credit'] = entity.imageCredit;
	data['image_preview_credit'] = entity.imagePreviewCredit;
	data['affiliate_rate'] = entity.affiliateRate;
	data['email_plan'] = entity.emailPlan;
	data['video_credit'] = entity.videoCredit;
	data['cartoonize_credit'] = entity.cartoonizeCredit;
	data['sku'] = entity.sku;
	data['sku_category'] = entity.skuCategory;
	data['apple_store_plan_id'] = entity.appleStorePlanId;
	data['google_play_plan_id'] = entity.googlePlayPlanId;
	data['ai_avatar_credit'] = entity.aiAvatarCredit;
	data['user_id'] = entity.userId;
	return data;
}