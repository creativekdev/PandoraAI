import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/effect_data_controller.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/api/app_api.dart';
import 'package:cartoonizer/api/color_fill_api.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/user/user_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/color_fill_result_entity.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/models/enums/app_tab_id.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/models/style_morph_result_entity.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/mine/refcode/submit_invited_code_screen.dart';
import 'package:cartoonizer/views/payment.dart';
import 'package:common_utils/common_utils.dart';

class AiColoringController extends GetxController {
  final String source;
  late String photoType;
  late File _originFile;

  File get originFile => _originFile;

  set originFile(File file) {
    _originFile = file;
  }

  String? resultPath;

  File? get resultFile {
    if (resultPath == null) {
      return null;
    }
    return File(resultPath!);
  }

  UserManager userManager = AppDelegate().getManager();
  CacheManager cacheManager = AppDelegate().getManager();
  RecentController recentController;
  UploadImageController uploadImageController;

  bool _showOrigin = false;

  set showOrigin(bool value) {
    _showOrigin = value;
    update();
  }

  bool get showOrigin => _showOrigin;

  late ColorFillApi api;
  late AppApi appApi;

  int generateCount = 0;

  AiColoringController({
    required RecentColoringEntity record,
    required this.recentController,
    required this.uploadImageController,
    required this.source,
    required this.photoType,
  }) {
    originFile = File(record.originFilePath!);
    resultPath = record.filePath;
  }

  @override
  void onInit() {
    super.onInit();
    api = ColorFillApi().bindController(this);
    appApi = AppApi().bindController(this);
  }

  @override
  void dispose() {
    api.unbind();
    appApi.unbind();
    super.dispose();
  }

  @override
  void onReady() {
    super.onReady();
  }

  changeOriginFile(BuildContext context, File file) {
    uploadImageController.imageUrl.value = '';
    resultPath = null;
    originFile = file;
    generateCount = 0;
    update();
    generate(context);
  }

  generate(BuildContext context) async {
    String key = await md5File(originFile);
    var needUpload = await uploadImageController.needUploadByKey(key);
    SimulateProgressBarController simulateProgressBarController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(
      context,
      needUploadProgress: needUpload,
      controller: simulateProgressBarController,
      config: SimulateProgressBarConfig.cartoonize(context),
    ).then((value) {
      if (value == null) {
        if (TextUtil.isEmpty(resultPath)) {
          Navigator.of(context).pop();
        }
      } else if (value.result) {
        Events.aiColoringCompleteSuccess(source: source, photoType: photoType);
        generateCount++;
        if (generateCount - 1 > 0) {
          Events.aiColoringGenerateAgain(time: generateCount - 1);
        }
      } else {
        if (value.error != null) {
          showLimitDialog(context, type: value.error!, function: 'aicoloring', source: 'ai_coloring_result');
        } else {
          if (TextUtil.isEmpty(resultPath)) {
            Navigator.of(context).pop();
          }
        }
      }
    });
    if (needUpload) {
      File compressedImage = await imageCompressAndGetFile(originFile, imageSize: Get.find<EffectDataController>().data?.imageMaxl ?? 512);
      await uploadImageController.uploadCompressedImage(compressedImage, key: key);
      if (TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
        simulateProgressBarController.onError();
      } else {
        simulateProgressBarController.uploadComplete();
      }
    }
    if (TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
      return;
    }
    var cachedId = await uploadImageController.getCachedIdByKey(key);
    _transfer(uploadImageController.imageUrl.value, cachedId, onFailed: (response) {
      uploadImageController.deleteUploadData(originFile, key: key);
    }).then((value) {
      if (value != null) {
        if (value.entity != null) {
          simulateProgressBarController.loadComplete();
          Events.aiColoringCompleteSuccess(source: source, photoType: photoType);
        } else {
          simulateProgressBarController.onError(error: value.type);
        }
      } else {
        simulateProgressBarController.onError();
      }
    });
  }

  Future<TransferResult?> _transfer(String imageUrl, String? cacheId, {onFailed}) async {
    var limitEntity = await appApi.getAiColoringLimit();
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
    var rootPath = cacheManager.storageOperator.recordTxt2imgDir.path;
    var baseEntity = await api.transfer(imageUrl: imageUrl, directoryPath: rootPath, onFailed: onFailed);
    if (baseEntity != null) {
      resultPath = baseEntity.filePath;
      update();
      recentController.onAiColoringUsed(
        RecentColoringEntity()
          ..originFilePath = originFile.path
          ..filePath = resultPath
          ..updateDt = DateTime.now().millisecondsSinceEpoch,
      );
      return TransferResult()..entity = baseEntity;
    } else {
      return null;
    }
  }
}

class TransferResult {
  ColorFillResultEntity? entity;
  AccountLimitType? type;

  TransferResult();
}
