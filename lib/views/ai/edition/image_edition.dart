import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/permissions_util.dart';
import 'package:cartoonizer/views/ai/edition/image_edition_screen.dart';
import 'package:cartoonizer/views/transfer/controller/all_transfer_controller.dart';

class ImageEdition {
  static String TagAppbarTagBack = "ImageEditionAppbarTagBack";
  static String TagAppbarTagTitle = "ImageEditionAppbarTagTitle";
  static String TagAppbarTagTraining = "ImageEditionAppbarTagTraining";
  static String TagImageEditView = "ImageEditView";

  static Future<void> open(
    BuildContext context, {
    required String source,
    String? initKey,
    required EffectStyle style,
    required ImageEditionFunction function,
    record,
  }) async {
    var hasPermission = await PermissionsUtil.checkPermissions();
    if (!hasPermission) {
      PermissionsUtil.permissionDenied(context);
    } else {
      if (record == null) {
        await _open(context, source: source, initKey: initKey, style: style, function: function);
      } else {
        await _openFromRecent(context, source: source, initKey: initKey, style: style, function: function, record: record);
      }
    }
  }

  static Future<void> _open(
    BuildContext context, {
    required String source,
    required EffectStyle style,
    String? initKey,
    required ImageEditionFunction function,
  }) async {
    var paiCameraEntity = await showPhotoTakeDialog(context);
    if (paiCameraEntity == null) {
      return;
    }
    CacheManager cacheManager = AppDelegate().getManager();
    var path = await ImageUtils.onImagePick(paiCameraEntity.xFile.path, cacheManager.storageOperator.imageDir.path, compress: true, size: 640);
    await Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: '/ImageEditionScreen'),
        builder: (_) => ImageEditionScreen(
          source: source,
          filePath: path,
          initKey: initKey,
          style: style,
          photoType: paiCameraEntity.source,
          initFunction: function,
          recentEffectItems: [],
        ),
      ),
    );
  }

  static Future<void> _openFromRecent(
    BuildContext context, {
    required String source,
    required String? initKey,
    required EffectStyle style,
    required ImageEditionFunction function,
    required record,
  }) async {
    List<RecentEffectItem> items = [];
    if (record is RecentEffectModel) {
      items = record.itemList;
    } else if (record is RecentStyleMorphModel) {
      items = record.itemList;
    }
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => ImageEditionScreen(
        source: source,
        filePath: record.originalPath!,
        style: style,
        photoType: 'recent',
        initFunction: function,
        initKey: initKey,
        recentEffectItems: items,
      ),
    ));
  }
}
