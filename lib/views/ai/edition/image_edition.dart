import 'dart:io';

import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/permissions_util.dart';
import 'package:cartoonizer/views/ai/edition/image_edition_screen.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';
import 'package:cartoonizer/views/transfer/controller/all_transfer_controller.dart';

import '../../../models/enums/home_card_type.dart';

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
    required HomeCardType cardType,
  }) async {
    var hasPermission = await PermissionsUtil.checkPermissions();
    if (!hasPermission) {
      PermissionsUtil.permissionDenied(context);
    } else {
      if (record == null) {
        bool isShowRecent = cardType == HomeCardType.imageEdition;
        await _open(context, source: source, initKey: initKey, style: style, function: function, isShowRecent: isShowRecent);
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
    required bool isShowRecent,
  }) async {
    var paiCameraEntity = await showPhotoTakeDialog(
      context,
      isShowRecent,
    );
    if (paiCameraEntity == null) {
      return;
    }
    CacheManager cacheManager = AppDelegate().getManager();
    var path = await onPrePickImage(paiCameraEntity.xFile.path, paiCameraEntity.width, paiCameraEntity.height);
    path = await ImageUtils.onImagePick(path, cacheManager.storageOperator.imageDir.path, compress: true, size: 1536, showLoading: true, maxM: 2);
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
          filter: FilterEnum.NOR,
          adjustData: [],
          cropRect: Rect.zero,
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
    String path = '';
    List<RecentEffectItem> items = [];
    List<RecentAdjustData> adjustData = [];
    Rect cropRect = Rect.zero;
    FilterEnum filter = FilterEnum.NOR;
    if (record is RecentEffectModel) {
      path = record.originalPath!;
      items = record.itemList;
    } else if (record is RecentStyleMorphModel) {
      path = record.originalPath!;
      items = record.itemList;
    } else if (record is RecentImageEditionEntity) {
      items = record.itemList;
      filter = record.filter ?? FilterEnum.NOR;
      adjustData = record.adjustData;
      cropRect = record.cropRect;
      path = record.originFilePath!;
    }
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) {
        return ImageEditionScreen(
          source: source,
          filePath: path,
          style: style,
          photoType: 'recent',
          initFunction: function,
          initKey: initKey,
          recentEffectItems: items,
          adjustData: adjustData,
          filter: filter,
          cropRect: cropRect,
        );
      },
    ));
  }

  static Future<String> onPrePickImage(String path, int width, int height) async {
    var shownImageSize = getShownImageSize();
    var containerRatio = shownImageSize.width / shownImageSize.height;
    var imageRatio = width / height;
    if (imageRatio < containerRatio) {
      //图片更细长，需要裁减缩放, 先获取图片裁减区域
      var targetCoverRect = ImageUtils.getTargetCoverRect(Size(width.toDouble(), height.toDouble()), shownImageSize);
      var imageInfo = await SyncFileImage(file: File(path)).getImage();
      var uint8list = await cropFile(imageInfo.image, targetCoverRect);
      var s = path + "crop_${containerRatio}." + getFileType(path);
      await File(s).writeAsBytes(uint8list);
      return s;
    }
    return path;
  }

  static Size getShownImageSize() {
    return Size(ScreenUtil.screenSize.width,
        ScreenUtil.screenSize.height - (kNavBarPersistentHeight + ScreenUtil.getStatusBarHeight() + $(65) + ScreenUtil.getBottomPadding(Get.context!)));
  }
}
