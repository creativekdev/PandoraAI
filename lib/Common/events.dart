import 'dart:io';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/social_user_info.dart';

import 'package:cartoonizer/common/importFile.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:kochava_tracker/kochava_tracker.dart';
import 'package:package_info_plus/package_info_plus.dart';

class Events {
  static Future<void> avatarCreate({
    required String source,
  }) =>
      logEvent("avatar_create", eventValues: {'source': source});

  static Future<void> avatarWhatToExpectContinue({
    required bool isChangeTemplate,
  }) =>
      logEvent("whattoexpect_continue_click", eventValues: {'is_change_template': isChangeTemplate ? 1 : 0});

  static Future<void> avatarStyleContinue({
    required String style,
  }) =>
      logEvent('avatarstyle_continue_click', eventValues: {'style': style});

  static Future<void> avatarPhotoSelect() => logEvent('avatarphoto_select-click');

  static Future<void> avatarSelectOk({
    required int photoCount,
  }) =>
      logEvent('avatarphoto_select_ok_click', eventValues: {'chosen_photos': photoCount});

  static Future<void> avatarPhotoUploadClick() => logEvent('avatarphoto_upload_click');

  static Future<void> avatarPhotoMoreClick() => logEvent('avatarphoto_more_click');

  static Future<void> avatarPhotoCancelClick() => logEvent('avatarphoto_cancel_click');

  static Future<void> avatarPlanShow() => logEvent('avatar_plan_show');

  static Future<void> avatarPlanLeave() => logEvent('avatar_plan_leave');

  static Future<void> avatarPlanPurchase({
    required String plan,
  }) =>
      logEvent('avatar_plan_purchase_click', eventValues: {'plan': plan});

  static Future<void> avatarUploadSuccess() => logEvent('avatar_upload_success');

  static Future<void> avatarResultShow() => logEvent('avatar_result_show');

  static Future<void> avatarResultDetailShow() => logEvent('avatar_result_detail_show');

  static Future<void> avatarResultDetailMediaShareSuccess({
    required String platform,
  }) =>
      logEvent('avatar_result_detail_mediashare_success', eventValues: {'platform': platform});

  static Future<void> avatarResultDetailPreviewSave({
    required String url,
    required String style,
  }) =>
      logEvent('avatar_result_detail_preview_save', eventValues: {'url': url, 'style': style});

  static Future<void> avatarResultDetailPreviewShareChoose({
    required String style,
    required String url,
    required String platform,
  }) =>
      logEvent('avatar_result_detail_preview_share_choose', eventValues: {'url': url, 'style': style, 'platform': platform});

  static Future<void> avatarResultDownloadOkClick({
    required String saveType,
  }) =>
      logEvent('avatar_result_download_ok_click', eventValues: {'source': saveType});
}

Future<void> logEvent(String eventName, {Map<String, dynamic>? eventValues}) async {
  SocialUserInfo? user = AppDelegate().getManager<UserManager>().user;
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  var defaultValues = {"app_platform": Platform.operatingSystem, "app_version": packageInfo.version, "app_build": packageInfo.buildNumber};
  if (user != null) {
    defaultValues["user_id"] = user.id.toString();
    defaultValues["user_email"] = user.getShownEmail();
  } else {
    var deviceInfoPlugin = DeviceInfoPlugin();
    final deviceInfo = await deviceInfoPlugin.deviceInfo;
    var data = deviceInfo.data;
    print(data);
  }
  var values = eventValues == null ? defaultValues : {...defaultValues, ...eventValues};
  // log Kochava
  logKochavaEvent(eventName, eventValues: values);
  // log firebase analytics
  FirebaseAnalytics.instance.logEvent(name: eventName, parameters: values);
}

logKochavaEvent(String eventName, {Map<String, dynamic>? eventValues}) {
  KochavaTracker.instance.sendEventWithDictionary(eventName, eventValues ?? {});
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
