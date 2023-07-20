import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/cartoonizer_result_entity.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/models/style_morph_result_entity.dart';
import 'package:cartoonizer/utils/utils.dart';

class CartoonizerController extends GetxController {
  late File _originFile;

  File get originFile => _originFile;

  set originFile(File file) {
    _originFile = file;
  }

  late List<EffectCategory> categories;
  EffectCategory? selectedTitle;
  EffectItem? selectedEffect;

  CacheManager cacheManager = AppDelegate().getManager();

  bool titleNeedScroll = true;

  Map<String, String> resultMap = {};

  late CartoonizerApi cartoonizerApi;
  late AppApi api;

  final String? initKey;

  bool _showOrigin = false;

  File? get resultFile {
    if (selectedEffect == null || resultMap[selectedEffect!.key] == null) {
      return null;
    }
    return File(resultMap[selectedEffect!.key]!);
  }

  set showOrigin(bool value) {
    _showOrigin = value;
    update();
  }

  bool get showOrigin => _showOrigin;

  Rx<bool> containsOriginal = false.obs;

  RecentController recentController = Get.find<RecentController>();

  CartoonizerController({required RecentEffectModel record, this.initKey}) {
    originFile = File(record.originalPath!);
    record.itemList.forEach((element) {
      resultMap[element.key!] = element.imageData!;
    });
  }

  @override
  void onInit() {
    super.onInit();
    api = AppApi().bindController(this);
    cartoonizerApi = CartoonizerApi().bindController(this);
    var controller = Get.find<EffectDataController>();
    categories = controller.data?.cartoonize?.children ?? [];
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
          if (selectedEffect == null) {
            selectedTitle = categories.first;
          }
        } else {
          selectedTitle = categories.first;
        }
      }
    }
  }

  @override
  void dispose() {
    cartoonizerApi.unbind();
    api.unbind();
    super.dispose();
  }

  Future<TransferResult?> startTransfer(String imageUrl, String? cachedId, {onFailed}) async {
    if (selectedEffect == null) {
      CommonExtension().showToast('Please select template');
      return null;
    }
    var limitEntity = await api.getCartoonizeLimit();
    if (limitEntity != null) {
      if (limitEntity.usedCount >= limitEntity.dailyLimit) {
        if (AppDelegate.instance.getManager<UserManager>().isNeedLogin) {
          return TransferResult()..type = AccountLimitType.guest;
        } else if (isVip()) {
          return TransferResult()..type = AccountLimitType.vip;
        } else {
          return TransferResult()..type = AccountLimitType.normal;
        }
      }
    }
    var rootPath = cacheManager.storageOperator.recordCartoonizeDir.path;
    var baseEntity = await cartoonizerApi.startTransfer(
      initImage: imageUrl,
      directoryPath: rootPath,
      selectEffect: selectedEffect!,
      onFailed: onFailed,
    );
    if (baseEntity != null) {
      resultMap[selectedEffect!.key] = baseEntity.filePath;
      update();
      recentController.onEffectUsed(selectedEffect!, original: originFile, imageData: baseEntity.filePath, isVideo: false, hasWatermark: false);
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
  CartoonizerResultEntity? entity;
  AccountLimitType? type;

  TransferResult();
}
