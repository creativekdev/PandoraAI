import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/permissions_util.dart';
import 'package:cartoonizer/views/transfer/controller/all_transfer_controller.dart';

import 'im_effect_screen.dart';
import 'im_filter.dart';

class ImEffect {
  static Future<void> open(BuildContext context, {required String source, record, String? initKey, required EffectStyle style}) async {
    bool result = await PermissionsUtil.checkPermissions();
    if (result) {
      if (record == null) {
        return _open(context, source, initKey, style);
      } else {
        return _openFromRecent(context, source, record, initKey);
      }
    } else {
      return PermissionsUtil.permissionDenied(context);
    }
  }

  static Future<void> _open(BuildContext context, String source, String? initKey, EffectStyle style) async {
    Events.imEffectionLoading(source: source);
    var paiCameraEntity = await showPhotoTakeDialog(context);
    if (paiCameraEntity == null) {
      return;
    }
    CacheManager cacheManager = AppDelegate().getManager();
    var path = await ImageUtils.onImagePick(paiCameraEntity.xFile.path, cacheManager.storageOperator.imageDir.path);
    Navigator.push(
      context,
      MaterialPageRoute(
        settings: RouteSettings(name: "/ImFilterScreen"),
        builder: (context) => ImEffectScreen(
          tab: TABS.EFFECT,
          source: source,
          originFile: File(path),
          resultFile: File(path),
          photoType: paiCameraEntity.source,
          effectStyle: style,
          initKey: initKey,
        ),
      ),
    );
  }

  static Future<void> _openFromRecent(BuildContext context, String source, record, String? initKey) async {
    //todo
  }
}
