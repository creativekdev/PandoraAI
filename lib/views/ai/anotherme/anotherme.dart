import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/utils/permissions_util.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_screen.dart';
import 'package:device_info_plus/device_info_plus.dart';

class AnotherMe {
  static String logoBackTag = 'am_back_logo';
  static String takeItemTag = 'am_take_item';

  static Future<void> open(BuildContext context, {RecentMetaverseEntity? entity, required String source}) async {
    var result = await PermissionsUtil.checkPermissions();
    if (result) {
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
    } else {
      PermissionsUtil.permissionDenied(context);
    }
  }
}
