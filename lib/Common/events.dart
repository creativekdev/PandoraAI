import 'dart:io';
import 'package:cartoonizer/common/utils.dart';
import 'package:cartoonizer/models/UserModel.dart';
import 'package:flutter/foundation.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/config.dart';

class Events {
  static String open_app = "open app";
  static String login = "login";
  static String signup = "signup"; // method, signup_through
  static String choose_home_cartoon_type = "choose_home_cartoon_type"; // category, style: face|full_body
  static String upload_photo = "upload_photo"; // method:photo|camera, from:center|result
  static String photo_cartoon_result = "photo_cartoon_result"; // success, category:3d, effect:3d1, original_face
  static String result_signup_get_credit = "result_signup_get_credit";
  static String result_share = "result_share"; // channel, effect
  static String result_download = "result_download"; // effect
  static String result_back = "result_back";
  static String homepage_loading = "homepage_loading";
  static String upload_page_loading = "upload_page_loading";
  static String profile_page_loading = "profile_page_loading";
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
}

logEvent(String eventName, {Map<String, dynamic>? eventValues}) {
  // log appsflyer
  logAppsflyerEvent(eventName, eventValues: eventValues);
  // log firebase analytics
  FirebaseAnalytics.instance.logEvent(name: eventName, parameters: eventValues);
}

logAppsflyerEvent(String eventName, {Map<String, dynamic>? eventValues}) async {
  UserModel user = await getUser();
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  var defaultValues = {"app_platform": Platform.operatingSystem, "app_version": packageInfo.version, "app_build": packageInfo.buildNumber};
  if (user.email != "") {
    defaultValues["user_id"] = user.id.toString();
    defaultValues["user_email"] = user.email;
    Appsflyer.instance.setCustomerUserId(user.id.toString());
  }
  var values = eventValues == null ? defaultValues : {...defaultValues, ...eventValues};
  Appsflyer.instance.logEvent(eventName, values);
}

logSystemEvent(String eventName, {Map<String, dynamic>? eventValues}) {
  // log appsflyer
  logAppsflyerEvent(eventName, eventValues: eventValues);

  // log firebase analytics
  switch (eventName) {
    case "open_app":
      FirebaseAnalytics.instance.logAppOpen();
      break;
    default:
  }
}

class Appsflyer {
  Appsflyer._init();

  static AppsflyerSdk? _instance;

  static AppsflyerSdk get instance {
    _instance ??= _initSdk();
    return _instance!;
  }

  static AppsflyerSdk _initSdk() {
    AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
      afDevKey: Config.instance.appsflyerKey,
      appId: IOS_APP_ID,
      showDebug: kDebugMode,
      timeToWaitForATTUserAuthorization: 60, // for iOS 14.5
      // appInviteOneLink: oneLinkID, // Optional field
      disableAdvertisingIdentifier: false, // Optional field
      disableCollectASA: false,
    ); // Optional field

    AppsflyerSdk appsflyerSdk = AppsflyerSdk(appsFlyerOptions);

    appsflyerSdk.onAppOpenAttribution((res) {
      print("onAppOpenAttribution res: " + res.toString());
    });
    appsflyerSdk.onInstallConversionData((res) {
      print("onInstallConversionData res: " + res.toString());
    });
    appsflyerSdk.onDeepLinking((DeepLinkResult dp) {
      switch (dp.status) {
        case Status.FOUND:
          print(dp.deepLink?.toString());
          print("deep link value: ${dp.deepLink?.deepLinkValue}");
          break;
        case Status.NOT_FOUND:
          print("deep link not found");
          break;
        case Status.ERROR:
          print("deep link error: ${dp.error}");
          break;
        case Status.PARSE_ERROR:
          print("deep link status parsing error");
          break;
      }
      print("onDeepLinking res: " + dp.toString());
    });

    appsflyerSdk.initSdk(registerConversionDataCallback: true, registerOnAppOpenAttributionCallback: true, registerOnDeepLinkingCallback: true);
    return appsflyerSdk;
  }
}
