import 'dart:io';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/social_user_info.dart';

import 'package:cartoonizer/common/importFile.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:kochava_tracker/kochava_tracker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

class Events {
  static Future<void> avatarCreate({required String source}) => logEvent("avatar_create", eventValues: {'source': source});

  static Future<void> avatarWhatToExpectContinue({required bool isChangeTemplate}) =>
      logEvent("whattoexpect_continue_click", eventValues: {'is_change_template': isChangeTemplate ? 1 : 0});

  static Future<void> avatarStyleContinue({required String style}) => logEvent('avatarstyle_continue_click', eventValues: {'style': style});

  static Future<void> avatarPhotoSelect() => logEvent('avatarphoto_select-click');

  static Future<void> avatarSelectOk({required int photoCount}) => logEvent('avatarphoto_select_ok_click', eventValues: {'chosen_photos': photoCount});

  static Future<void> avatarPhotoUploadClick() => logEvent('avatarphoto_upload_click');

  static Future<void> avatarPhotoMoreClick() => logEvent('avatarphoto_more_click');

  static Future<void> avatarPhotoCancelClick() => logEvent('avatarphoto_cancel_click');

  static Future<void> avatarPlanShow() => logEvent('avatar_plan_loading');

  static Future<void> avatarPlanLeave() => logEvent('avatar_plan_leave');

  static Future<void> avatarPlanPurchase({required String plan}) => logEvent('avatar_plan_purchase_click', eventValues: {'plan': plan});

  static Future<void> avatarUploadSuccess() => logEvent('avatar_upload_success');

  static Future<void> avatarResultShow() => logEvent('avatar_result_loading');

  static Future<void> avatarResultDetailShow() => logEvent('avatar_result_detail_loading');

  static Future<void> avatarResultDetailMediaShareSuccess({required String platform}) => logEvent('avatar_result_detail_mediashare_success', eventValues: {'platform': platform});

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

  static Future<void> avatarResultDownloadOkClick({required String saveType}) => logEvent('avatar_result_download_ok_click', eventValues: {'source': saveType});

  static Future<void> loginShow({required String source}) => logEvent('sign_in_loading', eventValues: {'source': source});

  static Future<void> loginSuccessShow({required String source}) => logEvent('sign_in_ok_click', eventValues: {'source': source});

  static Future<void> signupShow({
    required String source,
    String? prePage,
  }) =>
      logEvent('sign_up_loading', eventValues: {'source': source, 'pre_page': prePage});

  static Future<void> signupOkShow({
    required String source,
    String? prePage,
  }) =>
      logEvent('sign_up_ok_click', eventValues: {'source': source, 'pre_page': prePage});

  static Future<void> payShow({required String source}) => logEvent('subscribe_loading', eventValues: {'source': source});

  static Future<void> paySuccess({required String source}) => logEvent('subscribe_loading', eventValues: {'source': source});

  static Future<void> noticeLoading() => logEvent('notice_loading');

  static Future<void> facetoonLoading({required String source}) => logEvent('facetoon_loading', eventValues: {'source': source});

  static Future<void> facetoonGenerated({required String style}) => logEvent('facetoon_generate', eventValues: {'style': style});

  static Future<void> facetoonResultShare({required String platform}) => logEvent('facetoon_result_share', eventValues: {'platform': platform});

  static Future<void> facetoonResultSave({required String type}) => logEvent('facetoon_result_save', eventValues: {'type': type});

  static Future<void> metaverseLoading({required String source}) => logEvent('metaverse_loading', eventValues: {'source': source});

  static Future<void> metaverseCompleteSuccess({required String photo}) => logEvent('metaverse_completed_success', eventValues: {'photo': photo});

  static Future<void> metaverseCompleteShare({
    required String source,
    required String platform,
    required String type,
  }) =>
      logEvent('metaverse_completed_share', eventValues: {
        'source': source,
        'platform': platform,
        'type': type,
      });

  static Future<void> metaverseCompleteDownload({required String type}) => logEvent('metaverse_completed_download', eventValues: {'type': type});

  static Future<void> metaverseCompleteGenerateAgain({required int time}) => logEvent('metaverse_completed_generateagain', eventValues: {'time': '${time}'});

  static Future<void> metaverseCompleteTakeAgain() => logEvent('metaverse_completed_takeagain');

  static Future<void> metaverseCompletePreview() => logEvent('metaverse_completed_preview');

  static Future<void> txt2imgShow({
    required String source,
  }) async {
    logEvent('txt2img_loading', eventValues: {'source': source});
  }

  static Future<void> txt2imgResultShow({
    required bool isUseSuggestion,
    required String? style,
    required bool isUploadReference,
  }) async {
    logEvent('txt2img_result_loading', eventValues: {
      'is_use_suggestion': isUseSuggestion ? 1 : 0,
      'style': style ?? 'none',
      'is_upload_reference': isUploadReference ? 1 : 0,
    });
  }

  static Future<void> txt2imgCompleteShare({
    required String source,
    required String platform,
    required String type,
    required bool textDisplay,
  }) async {
    logEvent('txt2img_completed_share', eventValues: {
      'source': source,
      'platform': platform,
      'type': type,
      'text_display': textDisplay ? 1 : 0,
    });
  }

  static Future<void> txt2imgCompleteDownload({
    required String type,
    required bool textDisplay,
  }) async {
    logEvent('txt2img_completed_download', eventValues: {
      'type': type,
      'text_display': textDisplay ? 1 : 0,
    });
  }

  static Future<void> txt2imgCompleteGenerateAgain({required int time}) async {
    logEvent('txt2img_completed_generate_again', eventValues: {'time': '${time}'});
  }

  static Future<void> discoveryLoading() => logEvent('discovery_loading');

  static Future<void> discoveryDetailLoading({
    required String source,
    required String style,
  }) =>
      logEvent('discovery_detail_loading', eventValues: {'source': source, 'style': style});

  static Future<void> discoveryTemplateClick({
    required String source,
    required String style,
  }) =>
      logEvent('discovery_detail_trytemplate_click', eventValues: {'source': source, 'style': style});

  static Future<void> discoveryLikeClick({
    required String source,
    required String style,
  }) =>
      logEvent('discovery_detail_like_click', eventValues: {'source': source, 'style': style});

  static Future<void> discoveryCommentClick({
    required String source,
    required String style,
  }) =>
      logEvent('discovery_detail_comment_click', eventValues: {'source': source, 'style': style});

  static Future<void> recentlyLoading() => logEvent('recently_loading');

  static Future<void> shareApp() => logEvent('shareapp_click');

  static Future<void> rateUs() => logEvent('rate_us');
}

Future<void> logEvent(String eventName, {Map<String, dynamic>? eventValues}) async {
  SocialUserInfo? user = AppDelegate().getManager<UserManager>().user;
  PackageInfo packageInfo = await PackageInfo.fromPlatform();

  var defaultValues = {"app_platform": Platform.operatingSystem, "app_version": packageInfo.version, "app_build": packageInfo.buildNumber};
  if (user != null) {
    defaultValues["user_id"] = user.id.toString();
    defaultValues["user_email"] = user.getShownEmail();
  }
  var values = eventValues == null ? defaultValues : {...defaultValues, ...eventValues};
  // log Kochava
  logKochavaEvent(eventName, eventValues: values);
  // log firebase analytics
  FirebaseAnalytics.instance.logEvent(name: eventName, parameters: values);
  Posthog().capture(eventName: eventName, properties: values);
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
