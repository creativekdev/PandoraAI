import 'dart:io';
import 'dart:math';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/api/cartoonizer_api.dart';
import 'package:cartoonizer/api/style_morph_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/models/style_morph_result_entity.dart';
import 'package:cartoonizer/utils/utils.dart';

class StyleMorphController extends GetxController {
  late File originFile;

  late List<ChooseTitleInfo> titleList;
  late List<ChooseTabItemInfo> dataList;

  int titlePos = 0;

  ChooseTabItemInfo? selectedEffect;
  CacheManager cacheManager = AppDelegate().getManager();

  late ItemScrollController titleScrollController;
  late ItemPositionsListener titlePositionsListener;
  late ItemScrollController itemScrollController;
  late ItemPositionsListener itemPositionsListener;
  bool titleNeedScroll = true;

  Map<String, String> resultMap = {};

  late StyleMorphApi api;
  late CartoonizerApi cartoonizerApi;

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

  StyleMorphController({required this.originFile});

  @override
  void onInit() {
    super.onInit();
    SyncFileImage(file: originFile).getImage().then((value) {
      originImageScale = value.image.width / value.image.height;
      calculatePosY();
    });
    cartoonizerApi = CartoonizerApi().bindController(this);
    api = StyleMorphApi().bindController(this);
    var controller = Get.find<EffectDataController>();
    titleList = [];
    dataList = [];
    var effectData = controller.data?.stylemorph;
    var categories = effectData?.children ?? [];
    var tabKey = effectData?.key ?? '';
    for (int i = 0; i < categories.length; i++) {
      var category = categories[i];
      titleList.add(ChooseTitleInfo(title: category.title, categoryKey: category.key, tabKey: tabKey));
      for (int j = 0; j < category.effects.length; j++) {
        var effect = category.effects[j];
        dataList.add(ChooseTabItemInfo(data: effect, tabKey: tabKey, categoryKey: category.key, categoryIndex: i, childIndex: j));
      }
    }
    titleScrollController = ItemScrollController();
    itemScrollController = ItemScrollController();
    titlePositionsListener = ItemPositionsListener.create();
    itemPositionsListener = ItemPositionsListener.create();
    var listener = () {
      var pos = min(itemPositionsListener.itemPositions.value.first.index, itemPositionsListener.itemPositions.value.last.index);
      var targetPos;
      if (pos > dataList.length - 6) {
        targetPos = dataList.length - 6;
      } else {
        targetPos = pos;
      }
      if (selectedEffect == null) {
        onTitleSelected(dataList[targetPos].categoryIndex, autoScroll: false);
      }
    };
    itemPositionsListener.itemPositions.removeListener(listener);
    itemPositionsListener.itemPositions.addListener(listener);
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
  void onReady() {
    cartoonizerApi.unbind();
    api.unbind();
    super.onReady();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onError() {}

  void onSuccess() {}

  Future<TransferResult?> startTransfer(String imageUrl, String? cachedId) async {
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
    var baseEntity = await api.startTransfer(initImage: imageUrl, templateName: selectedEffect!.data.key, directoryPath: rootPath);
    if (baseEntity != null) {
      resultMap[selectedEffect!.data.key] = baseEntity.filePath;
      update();
      return TransferResult()..entity = baseEntity;
    } else {
      return null;
    }
  }

  void onTitleSelected(int index, {bool autoScroll = true}) {
    titlePos = index;
    if (autoScroll) {
      var pos = dataList.findPosition((data) => data.categoryIndex == index) ?? 0;
      itemScrollController.jumpTo(index: pos);
    }
    update();
  }

  void onItemSelected(int index) {
    if (selectedEffect == dataList[index]) {
      if (resultMap[selectedEffect!.data.key] != null) {
        selectedEffect = null;
      }
    } else {
      selectedEffect = dataList[index];
      titlePos = selectedEffect!.categoryIndex;
    }
    update();
  }
}

class TransferResult {
  StyleMorphResultEntity? entity;
  AccountLimitType? type;

  TransferResult();
}
