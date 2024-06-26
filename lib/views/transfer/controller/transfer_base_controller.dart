import 'dart:io';

import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/controller/recent/recent_controller.dart';
import 'package:cartoonizer/models/api_config_entity.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/views/ai/edition/controller/image_edition_controller.dart';

abstract class TransferBaseController<ResultType> extends GetxController {
  late String _originalPath;

  String get originalPath => _originalPath;

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

  ImageEditionController? parent;

  late ItemScrollController titleScrollController;
  late ItemScrollController scrollController;

  setOriginPath(String path) {
    _originalPath = path;
    originFile = File(_originalPath);
    resultMap.clear();
    update();
  }

  @override
  update([List<Object>? ids, bool condition = true]) {
    super.update(ids, condition);
    parent?.update();
  }

  TransferBaseController({required String originalPath, required List<RecentEffectItem> itemList, this.initKey}) {
    _originalPath = originalPath;
    originFile = File(_originalPath);
    itemList.forEach((element) {
      resultMap[element.key!] = element.imageData!;
    });
  }

  @override
  void onInit() {
    super.onInit();
    api = AppApi().bindController(this);
    categories = buildCategories();
    scrollController = ItemScrollController();
    titleScrollController = ItemScrollController();
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
        if (selectedTitle == null) {
          selectedTitle = categories.first;
        }
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

  String getControllerStyle();

  @protected
  List<EffectCategory> buildCategories();

  @override
  void dispose() {
    api.unbind();
    super.dispose();
  }

  String getCategory();

  onError() {}

  onSuccess() {}

  onSavePhoto({required String photo});

  onResultShare({
    required String source,
    required String platform,
    required String photo,
  });

  onGenerateSuccess({
    required String source,
    required String photoType,
    required String style,
  });

  onGenerateAgainSuccess({
    required int time,
    required String source,
    required String photoType,
    required String style,
  }) {}

  Future<TransferResult<ResultType>?> startTransfer(String imageUrl, String? cachedId, {onFailed, bool needRecord = true});

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

class TransferResult<T> {
  T? entity;
  AccountLimitType? type;

  TransferResult();
}
