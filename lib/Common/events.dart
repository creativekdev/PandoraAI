import 'dart:io';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/social_user_info.dart';
import 'package:flutter/foundation.dart';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/config.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:kochava_tracker/kochava_tracker.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Events {
  static String open_app = "open app";
  static String login = "login";
  static String signup = "signup"; // method, signup_through
  static String choose_home_cartoon_type = "choose_home_cartoon_type"; // category, style: face|full_body
  static String upload_photo = "upload_photo"; // method:photo|camera, from:center|result
  static String photo_cartoon_result = "photo_cartoon_result"; // success, category:3d, effect:3d1, original_face
  static String result_signup_get_credit = "result_signup_get_credit";
  static String result_share = "result_share"; // channel, effect
  static String result_url_share = "result_url_share"; // effect
  static String result_download = "result_download"; // effect
  static String result_back = "result_back";
  static String homepage_loading = "homepage_loading";
  static String upload_page_loading = "upload_page_loading";

  // static String profile_page_loading = "profile_page_loading";
  static String setting_page_loading = "setting_page_loading";
  static String login_page_loading = "login_page_loading";
  static String signup_page_loading = "signup_page_loading";
  static String premium_page_loading = "premium_page_loading";
  static String edit_profile_page_loading = "edit_profile_page_loading";
  static String rate_us = "rate_us";
  static String share_app = "share_app";
  static String open_help_center = "open_help_center";
  static String open_terms = "open_terms";
  static String open_privacy = "open_privacy";
  static String logout = "logout";
  static String contact_socialmedia = "contact_socialmedia"; // channel
  static String premium_continue = "premium_continue";
  static String paid_success = "paid_success"; // plan_id, product_id, price, currency, quantity},
  static String open_my_discovery = "open_my_discovery";
  static String open_user_profile = "open_user_profile";
  static String delete_account = "delete_account";
  static String tab_effect_loading = "tab_effect_loading";
  static String tab_discovery_loading = "tab_discovery_loading";
  static String tab_me_loading = "tab_me_loading";
  static String tab_ai_loading = "tab_ai_loading";
  static String user_discovery_loading = "user_discovery_loading";
  static String discovery_detail_loading = "discovery_detail_loading";
  // static String discovery_comment_loading = "discovery_comment_loading";
  static String discovery_secondary_comment_loading = "discovery_secondary_comment_loading";
  static String create_discovery_share = "create_discovery_share";
  static String reward_advertisement_loading = "reward_advertisement_loading";
  static String effect_child_tab_switch = "effect_child_tab_switch";
  static String feed_back_loading = "feed_back_loading";
  static String rate_dialog_loading = "rate_dialog_loading";
  static String recent_loading = "recent_loading";
  static String rate_no_thanks = "rate_no_thanks";
  static String admob_source_data = 'admob_source_data';
  static String transform_img_failed = 'transform_img_failed';
  static String avatar_list_loading = 'avatar_list_loading';
  static String avatar_detail_loading = 'avatar_detail_loading';
  static String avatar_create_loading = 'avatar_create_loading';
  static String avatar_introduce_loading = 'avatar_introduce_loading';
  static String avatar_submit_photos = 'avatar_submit_photos';
  static String avatar_cancel_submit_photos = 'avatar_cancel_submit_photos';
}

logEvent(String eventName, {Map<String, dynamic>? eventValues}) {
  // log Kochava
  logKochavaEvent(eventName, eventValues: eventValues);
  // log firebase analytics
  FirebaseAnalytics.instance.logEvent(name: eventName, parameters: eventValues);
}

logKochavaEvent(String eventName, {Map<String, dynamic>? eventValues}) async {
  SocialUserInfo? user = AppDelegate()
      .getManager<UserManager>()
      .user;
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  var defaultValues = {"app_platform": Platform.operatingSystem, "app_version": packageInfo.version, "app_build": packageInfo.buildNumber};
  if (user != null) {
    defaultValues["user_id"] = user.id.toString();
    defaultValues["user_email"] = user.getShownEmail();
  }
  var values = eventValues == null ? defaultValues : {...defaultValues, ...eventValues};
  KochavaTracker.instance.sendEventWithDictionary(eventName, values);
}

logSystemEvent(String eventName, {Map<String, dynamic>? eventValues}) {
  // log appsflyer
  logKochavaEvent(eventName, eventValues: eventValues);

  // log firebase analytics
  switch (eventName) {
    case "open_app":
      FirebaseAnalytics.instance.logAppOpen();
      break;
    default:
  }
}
