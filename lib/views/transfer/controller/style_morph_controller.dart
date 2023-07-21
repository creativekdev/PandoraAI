import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/api/style_morph_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/models/style_morph_result_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/transfer/controller/transfer_base_controller.dart';

class StyleMorphController extends TransferBaseController<StyleMorphResultEntity> {
  late StyleMorphApi styleApi;

  StyleMorphController({
    required super.originalPath,
    required super.itemList,
    super.initKey,
  });

  @override
  void onInit() {
    super.onInit();
    styleApi = StyleMorphApi().bindController(this);
  }

  @override
  List<EffectCategory> buildCategories() {
    var controller = Get.find<EffectDataController>();
    return controller.data?.stylemorph?.children ?? [];
  }

  @override
  void dispose() {
    styleApi.unbind();
    super.dispose();
  }

  @override
  Future<TransferResult<StyleMorphResultEntity>?> startTransfer(String imageUrl, String? cachedId, {onFailed}) async {
    if (selectedEffect == null) {
      CommonExtension().showToast('Please select template');
      return null;
    }
    var styleMorphLimitEntity = await api.getStyleMorphLimit();
    if (styleMorphLimitEntity != null) {
      if (styleMorphLimitEntity.usedCount >= styleMorphLimitEntity.dailyLimit) {
        if (AppDelegate.instance.getManager<UserManager>().isNeedLogin) {
          return TransferResult()..type = AccountLimitType.guest;
        } else if (isVip()) {
          return TransferResult()..type = AccountLimitType.vip;
        } else {
          return TransferResult()..type = AccountLimitType.normal;
        }
      }
    }
    var rootPath = cacheManager.storageOperator.recordTxt2imgDir.path;
    var baseEntity = await styleApi.startTransfer(initImage: imageUrl, templateName: selectedEffect!.key, directoryPath: rootPath, onFailed: onFailed);
    if (baseEntity != null) {
      resultMap[selectedEffect!.key] = baseEntity.filePath;
      update();
      recentController.onStyleMorphUsed(selectedEffect!, original: originFile, imageData: baseEntity.filePath);
      return TransferResult()..entity = baseEntity;
    } else {
      return null;
    }
  }

  @override
  onGenerateSuccess({required String source, required String style}) {
    Events.styleMorphCompleteSuccess(source: source, style: style);
  }

  @override
  onResultShare({required String source, required String platform, required String photo}) {
    Events.styleMorphCompleteShare(source: source, platform: platform, type: photo);
  }

  @override
  onSavePhoto({required String photo}) {
    Events.styleMorphDownload(type: photo);
  }

  @override
  onGenerateAgainSuccess({required int time, required String source, required String style}) {
    Events.styleMorphGenerateAgain(time: time, source: source, style: style);
  }
}