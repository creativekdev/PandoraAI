import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/ai/edition/controller/adjust_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/crop_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/filter_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/remove_bg_holder.dart';
import 'package:cartoonizer/views/mine/filter/im_remove_bg_screen.dart';
import 'package:cartoonizer/views/transfer/controller/all_transfer_controller.dart';
import 'package:cartoonizer/views/transfer/controller/sticker_controller.dart';
import 'package:cartoonizer/views/transfer/controller/transfer_base_controller.dart';
import 'package:common_utils/common_utils.dart';

class ImageEditionController extends GetxController {
  final String photoType;
  final String source;
  final String? initKey;
  final ImageEditionFunction initFunction;
  late String _originPath;

  double bottomHeight = 0;
  double switchButtonBottomToScreen = 0;

  File get originFile => File(_originPath);

  final EffectStyle effectStyle;

  ///----------------------------------------------------------------------------------------

  List<EditionStep> activeSteps = [];
  List<EditionStep> checkmateSteps = [];

  ///----------------------------------------------------------------------------------------
  late EditionItem _currentItem;

  EditionItem get currentItem => _currentItem;

  set currentItem(EditionItem func) {
    _currentItem = func;
    update();
  }

  List<EditionItem> items = [];

  bool _showOrigin = false;

  bool get showOrigin => _showOrigin;

  set showOrigin(bool value) {
    _showOrigin = value;
    update();
  }

  UploadImageController uploadImageController = Get.find();
  int generateCount = 0;


  List<RecentEffectItem> recentItemList = [];

  ImageEditionController({
    required String originPath,
    required this.effectStyle,
    required this.initFunction,
    required this.initKey,
    required this.source,
    required this.photoType,
    required this.recentItemList,
  }) {
    _originPath = originPath;
  }

  @override
  void onInit() {
    super.onInit();
    AllTransferController? effectHolder;
    StickerController? stickerHolder;
    if (initFunction != ImageEditionFunction.removeBg) {
      effectHolder = AllTransferController(originalPath: _originPath, itemList: recentItemList, style: effectStyle, initKey: initKey)
        ..parent = this
        ..onInit();
      stickerHolder = StickerController(originalPath: _originPath, itemList: recentItemList, initKey: initKey)
        ..parent = this
        ..onInit();
    }
    var filterHolder = FilterHolder(parent: this)..onInit();
    var adjustHolder = AdjustHolder(parent: this)..onInit();
    var cropHolder = CropHolder(parent: this)..onInit();
    var removeBgHolder = RemoveBgHolder(parent: this)..onInit();
    items = [
      EditionItem()
        ..function = ImageEditionFunction.filter
        ..holder = filterHolder,
      EditionItem()
        ..function = ImageEditionFunction.adjust
        ..holder = adjustHolder,
      EditionItem()
        ..function = ImageEditionFunction.crop
        ..holder = cropHolder,
      EditionItem()
        ..function = ImageEditionFunction.removeBg
        ..holder = removeBgHolder,
    ];
    if (effectHolder != null) {
      items.insert(
        0,
        EditionItem()
          ..function = ImageEditionFunction.effect
          ..holder = effectHolder,
      );
    }
    if (stickerHolder != null) {
      items.add(
        EditionItem()
          ..function = ImageEditionFunction.sticker
          ..holder = stickerHolder,
      );
    }
    currentItem = items.pick((t) => t.function == initFunction) ?? items.first;
    if (currentItem.function == ImageEditionFunction.removeBg) {
      var holder = currentItem.holder as RemoveBgHolder;
      holder.setOriginFilePath(_originPath);
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (currentItem.function == ImageEditionFunction.removeBg) {
      startRemoveBg();
    } else if (currentItem.function == ImageEditionFunction.effect || currentItem.function == ImageEditionFunction.sticker) {
      var holder = currentItem.holder as TransferBaseController;
      if (holder.selectedEffect != null && holder.resultFile == null) {
        generate(Get.context!, holder);
      }
    }
  }

  @override
  void dispose() {
    for (var item in items) {
      item.holder.dispose();
    }
    super.dispose();
  }

  startRemoveBg() async {
    var image = await SyncFileImage(file: originFile).getImage();
    Navigator.push(
      Get.context!,
      NoAnimRouter(
        ImRemoveBgScreen(
          bottomPadding: bottomHeight + ScreenUtil.getBottomPadding(Get.context!),
          filePath: _originPath,
          imageRatio: image.image.width / image.image.height,
          onGetRemoveBgImage: (String path) async {
            SyncFileImage(file: File(path)).getImage().then((value) {
              var holder = currentItem.holder as RemoveBgHolder;
              holder.ratio = value.image.width / value.image.height;
              holder.removedImage = File(path);
            });
          },
        ),
        // opaque: true,
        settings: RouteSettings(name: "/ImRemoveBgScreen"),
      ),
    );
  }

  generate(BuildContext context, TransferBaseController controller) async {
    var needUpload = TextUtil.isEmpty(uploadImageController.imageUrl(controller.originFile).value);
    SimulateProgressBarController simulateProgressBarController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(
      context,
      needUploadProgress: needUpload,
      controller: simulateProgressBarController,
      config: SimulateProgressBarConfig.cartoonize(context),
    ).then((value) {
      if (value == null) {
        controller.onError();
      } else if (value.result) {
        controller.onGenerateSuccess(source: source, photoType: photoType, style: controller.selectedEffect?.key ?? '');
        generateCount++;
        if (generateCount - 1 > 0) {
          controller.onGenerateAgainSuccess(source: source, photoType: photoType, time: generateCount - 1, style: controller.selectedEffect?.key ?? '');
        }
        controller.onSuccess();
      } else {
        controller.onError();
        if (value.error != null) {
          showLimitDialog(context, type: value.error!, function: controller.getCategory(), source: 'image_edition_page');
        } else {
          // Navigator.of(context).pop();
        }
      }
    });

    uploadImageController.upload(file: controller.originFile).then((value) async {
      if (TextUtil.isEmpty(value)) {
        simulateProgressBarController.onError();
      } else {
        simulateProgressBarController.uploadComplete();
        var cachedId = await uploadImageController.getCachedId(controller.originFile);
        controller.startTransfer(value!, cachedId, onFailed: (response) {
          uploadImageController.deleteUploadData(controller.originFile);
        }).then((value) {
          if (value != null) {
            if (value.entity != null) {
              simulateProgressBarController.loadComplete();
            } else {
              simulateProgressBarController.onError(error: value.type);
            }
          } else {
            simulateProgressBarController.onError();
          }
        });
      }
    });
  }
}

class EditionStep {}

class EditionItem {
  late ImageEditionFunction function;
  late dynamic holder;

  EditionItem();
}
