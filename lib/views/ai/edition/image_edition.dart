import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/controller/recent/recent_controller.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/permissions_util.dart';
import 'package:cartoonizer/views/ai/edition/image_edition_screen.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';
import 'package:cartoonizer/views/transfer/controller/all_transfer_controller.dart';
import 'package:cartoonizer/widgets/dialog/dialog_widget.dart';

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
        bool autoGenerate = true;
        if (initKey == null) {
          autoGenerate = false;
          RecentController recentController = Get.find();
          var firstWhereOrNull = recentController.recordList.firstWhereOrNull((element) {
            return element is RecentEffectModel || element is RecentStyleMorphModel;
          });
          if (firstWhereOrNull != null) {
            initKey = firstWhereOrNull.itemList?.first?.key;
          }
        }
        await _open(context, source: source, initKey: initKey, style: style, function: function, isShowRecent: isShowRecent, autoGenerate: autoGenerate);
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
    required bool autoGenerate,
  }) async {
    var paiCameraEntity = await showPhotoTakeDialog(
      context,
      isShowRecent,
    );
    if (paiCameraEntity == null) {
      return;
    }
    CacheManager cacheManager = AppDelegate().getManager();
    var path = await ImageUtils.onImagePick(
      paiCameraEntity.xFile.path,
      cacheManager.storageOperator.imageDir.path,
      compress: true,
      size: 1536,
      showLoading: true,
      maxM: 2,
      imageSize: Size(paiCameraEntity.width.toDouble(), paiCameraEntity.height.toDouble()),
      cropSize: getShownImageSize(),
    );
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
          autoGenerate: autoGenerate,
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
          autoGenerate: false,
        );
      },
    ));
  }

  static Size getShownImageSize() {
    return Size(ScreenUtil.screenSize.width,
        ScreenUtil.screenSize.height - (kNavBarPersistentHeight + ScreenUtil.getStatusBarHeight() + $(140) + ScreenUtil.getBottomPadding()));
  }
}
