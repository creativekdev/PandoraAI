import 'dart:io';

import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/social_user_info.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

extension PosthogEx on Posthog {
  screenWithUser({required String screenName, Map<String, dynamic>? eventValues}) async {
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
    screen(screenName: screenName, properties: values);
  }
}
