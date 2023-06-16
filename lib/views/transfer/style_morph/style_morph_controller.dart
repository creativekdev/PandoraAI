import 'dart:io';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/api/style_morph_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/models/style_morph_result_entity.dart';
import 'package:cartoonizer/utils/utils.dart';

class StyleMorphController extends GetxController {
  late File _originFile;

  File get originFile => _originFile;

  set originFile(File file) {
    _originFile = file;
    SyncFileImage(file: originFile).getImage().then((value) {
      originImageScale = value.image.width / value.image.height;
      calculatePosY();
    });
  }

  late List<EffectCategory> categories;
  EffectCategory? selectedTitle;
  EffectItem? selectedEffect;

  CacheManager cacheManager = AppDelegate().getManager();

  bool titleNeedScroll = true;

  Map<String, String> resultMap = {};

  late StyleMorphApi api;
  late CartoonizerApi cartoonizerApi;

  final String? initKey;
  double? originImageScale;
  Size? imageStackSize;
  double imagePosBottom = 0;
  double imagePosRight = 0;

  bool _showOrigin = false;

  set showOrigin(bool value) {
    _showOrigin = value;
    update();
  }

  bool get showOrigin => _showOrigin;

  RecentController recentController = Get.find<RecentController>();

  StyleMorphController({required RecentStyleMorphModel record, this.initKey}) {
    originFile = File(record.originalPath!);
    record.itemList.forEach((element) {
      resultMap[element.key!] = element.imageData!;
    });
  }

  @override
  void onInit() {
    super.onInit();
    cartoonizerApi = CartoonizerApi().bindController(this);
    api = StyleMorphApi().bindController(this);
    var controller = Get.find<EffectDataController>();
    categories = controller.data?.stylemorph.children ?? [];
    if (categories.isNotEmpty) {
      if (resultMap.isNotEmpty) {
        categories.forEach((category) {
          category.effects.forEach((effect) {
            if (effect.key == (initKey ?? resultMap.keys.first)) {
              selectedTitle = category;
              selectedEffect = effect;
            }
          });
        });
      } else {
        if (initKey != null) {
          categories.forEach((category) {
            category.effects.forEach((effect) {
              if (initKey == effect.key) {
                selectedTitle = category;
                selectedEffect = effect;
              }
            });
          });
        } else {
          selectedTitle = categories.first;
        }
      }
    }
  }

  calculatePosY() {
    if (originImageScale == null || imageStackSize == null) {
      return;
    }
    double sizeScale = imageStackSize!.width / imageStackSize!.height;
    if (originImageScale! > sizeScale) {
      var height = imageStackSize!.width / originImageScale!;
      imagePosBottom = (imageStackSize!.height - height) / 2;
      imagePosRight = 0;
    } else {
      var width = imageStackSize!.height * originImageScale!;
      imagePosRight = (imageStackSize!.width - width) / 2;
      imagePosBottom = 0;
    }
    update();
  }

  @override
  void dispose() {
    cartoonizerApi.unbind();
    api.unbind();
    super.dispose();
  }

  void onError() {}

  void onSuccess() {}

  Future<TransferResult?> startTransfer(String imageUrl, String? cachedId, {onFailed}) async {
    if (selectedEffect == null) {
      CommonExtension().showToast('Please select template');
      return null;
    }
    var styleMorphLimitEntity = await cartoonizerApi.getStyleMorphLimit();
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
    var baseEntity = await api.startTransfer(initImage: imageUrl, templateName: selectedEffect!.key, directoryPath: rootPath, onFailed: onFailed);
    if (baseEntity != null) {
      resultMap[selectedEffect!.key] = baseEntity.filePath;
      update();
      recentController.onStyleMorphUsed(selectedEffect!, original: originFile, imageData: baseEntity.filePath);
      return TransferResult()..entity = baseEntity;
    } else {
      return null;
    }
  }

  void onTitleSelected(int index) {
    if (selectedTitle == categories[index]) {
      return;
    }
    selectedTitle = categories[index];
    update();
  }

  void onItemSelected(int index) {
    if (selectedEffect == selectedTitle!.effects[index]) {
      if (resultMap[selectedEffect!.key] != null) {
        selectedEffect = null;
      }
    } else {
      selectedEffect = selectedTitle!.effects[index];
    }
    update();
  }
}

class TransferResult {
  StyleMorphResultEntity? entity;
  AccountLimitType? type;

  TransferResult();
}
