import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AnotherMe {
  static String logoBackTag = 'am_back_logo';
  static String takeItemTag = 'am_take_item';

  static Future<void> open(BuildContext context, {RecentMetaverseEntity? entity, required String source}) async {
    Events.metaverseLoading(source: source);
    return await Navigator.push<void>(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/AnotherMeScreen"),
        builder: (context) => AnotherMeScreen(
          entity: entity,
        ),
      ),
    );
  }

  static Future<bool> checkPermissions() async {
    var list = [Permission.microphone, Permission.camera, Permission.storage];
    var deviceInfoPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      var androidInfo = await deviceInfoPlugin.androidInfo;
      if (androidInfo.version.sdkInt > 31) {
        list.add(Permission.photos);
      }
    } else if (Platform.isIOS) {
      list.add(Permission.photos);
    }
    var values = await list.request();
    for (var result in values.values) {
      if (result.isDenied || result.isPermanentlyDenied) {
        return false;
      }
    }
    return true;
  }
}
