import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/permissions_util.dart';
import 'package:cartoonizer/views/ai/edition/image_edition_screen.dart';
import 'package:cartoonizer/views/transfer/controller/both_transfer_controller.dart';

class ImageEdition {
  static String TagAppbarTagBack = "ImageEditionAppbarTagBack";
  static String TagAppbarTagTitle = "ImageEditionAppbarTagTitle";
  static String TagAppbarTagTraining = "ImageEditionAppbarTagTraining";

  static Future<void> open(
    BuildContext context, {
    required String source,
    String? initKey,
    required EffectStyle style,
  }) async {
    var hasPermission = await PermissionsUtil.checkPermissions();
    if (!hasPermission) {
      PermissionsUtil.permissionDenied(context);
    } else {
      _open(context, source: source, initKey: initKey, style: style);
    }
  }

  static Future<void> _open(
    BuildContext context, {
    required String source,
    required EffectStyle style,
    String? initKey,
  }) async {
    var paiCameraEntity = await showPhotoTakeDialog(context);
    if (paiCameraEntity == null) {
      return;
    }
    CacheManager cacheManager = AppDelegate().getManager();
    var path = await ImageUtils.onImagePick(paiCameraEntity.xFile.path, cacheManager.storageOperator.imageDir.path, compress: true, size: 640);
    Navigator.of(context).push(
      MaterialPageRoute(
        settings: RouteSettings(name: '/ImageEditionScreen'),
        builder: (_) => ImageEditionScreen(source: source, filePath: path, initKey: initKey, style: style, photoType: paiCameraEntity.source),
      ),
    );
  }
}
