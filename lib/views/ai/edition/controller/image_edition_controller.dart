import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/background_card.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/lib_image_widget/lib_image_widget.dart';
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
import 'package:image/image.dart' as imgLib;

import '../../../../Widgets/app_navigation_bar.dart';
import '../../../../utils/utils.dart';
import 'ie_base_holder.dart';

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
    EventBusHelper().eventBus.fire(OnEditionRightTabSwitchEvent(data: func.function.title()));
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

  ui.Image? _shownImage;

  ui.Image? get shownImage => _shownImage;

  setShownImage(imgLib.Image? image) async {
    if (image == null) {
      _shownImage = null;
    } else {
      _shownImage = await toImage(image);
    }
  }

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
    var filterHolder = FilterHolder(parent: this)..onInit();
    var adjustHolder = AdjustHolder(parent: this)..onInit();
    var cropHolder = CropHolder(parent: this)..onInit();
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
    ];
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
    if (effectHolder != null) {
      items.insert(
        0,
        EditionItem()
          ..function = ImageEditionFunction.effect
          ..holder = effectHolder,
      );
    }
    if (initFunction != ImageEditionFunction.effect && initFunction != ImageEditionFunction.sticker) {
      var removeBgHolder = RemoveBgHolder(parent: this)..onInit();
      items.add(
        EditionItem()
          ..function = ImageEditionFunction.removeBg
          ..holder = removeBgHolder,
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
    if (currentItem.function != ImageEditionFunction.effect && currentItem.function != ImageEditionFunction.sticker) {
      var holder = currentItem.holder as ImageEditionBaseHolder;
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
    final imageSize = Size(ScreenUtil.screenSize.width, ScreenUtil.screenSize.height - (kNavBarPersistentHeight + ScreenUtil.getStatusBarHeight() + $(140)));
    Navigator.push(
      Get.context!,
      NoAnimRouter(
        ImRemoveBgScreen(
          bottomPadding: bottomHeight + ScreenUtil.getBottomPadding(Get.context!),
          filePath: _originPath,
          imageRatio: image.image.width / image.image.height,
          imageHeight: image.image.height.toDouble(),
          imageWidth: image.image.width.toDouble(),
          onGetRemoveBgImage: (String path) async {
            SyncFileImage(file: File(path)).getImage().then((value) async {
              var holder = currentItem.holder as RemoveBgHolder;
              holder.ratio = value.image.width / value.image.height;
              holder.removedImage = File(path);
              holder.imageUiFront = await getImage(File(path));
              var imageFront = await getLibImage(holder.imageUiFront!);
              holder.imageFront = imageFront;
              await holder.setBackgroundImage(null, false);
              holder.backgroundColor = holder.rgbaToAbgr(Colors.transparent);
              await holder.saveImageWithColor(holder.rgbaToAbgr(Colors.transparent), true);
              // holder.resultFilePath = path;
            });
          },
          size: imageSize,
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

  onRightTabClick(BuildContext context, EditionItem e) async {
    if (e.function == currentItem.function) {
      //重复点击，特殊情况考虑
    } else {
      if (e.function == ImageEditionFunction.effect || e.function == ImageEditionFunction.sticker) {
        //跳转effect或者sticker
        currentItem = e;
        // 不处理
      } else {
        String originFilePath;
        if (currentItem.function == ImageEditionFunction.effect || currentItem.function == ImageEditionFunction.sticker) {
          // 从effect或sticker跳其他
          var transferController = currentItem.holder as TransferBaseController;
          if (transferController.resultFile != null) {
            originFilePath = transferController.resultFile!.path;
          } else {
            var targetHolder = e.holder as ImageEditionBaseHolder;
            if (targetHolder.originFilePath != null) {
              currentItem = e;
              return;
            } else {
              originFilePath = transferController.originalPath;
            }
          }
        } else {
          //其他的互相跳转
          var baseHolder = currentItem.holder as ImageEditionBaseHolder;
          originFilePath = (baseHolder.resultFile ?? baseHolder.originFile!).path;
        }
        if (e.function == ImageEditionFunction.removeBg && (e.holder as RemoveBgHolder).removedImage == null) {
          var image = await SyncFileImage(file: File(originFilePath)).getImage();
          final imageSize = Size(ScreenUtil.screenSize.width, ScreenUtil.screenSize.height - (kNavBarPersistentHeight + ScreenUtil.getStatusBarHeight() + $(140)));

          Navigator.push(
            context,
            NoAnimRouter(
              ImRemoveBgScreen(
                bottomPadding: bottomHeight + ScreenUtil.getBottomPadding(context),
                filePath: originFilePath,
                imageRatio: image.image.width / image.image.height,
                imageHeight: image.image.height.toDouble(),
                imageWidth: image.image.width.toDouble(),
                onGetRemoveBgImage: (String path) async {
                  SyncFileImage(file: File(path)).getImage().then((value) {
                    var holder = e.holder as RemoveBgHolder;
                    holder.ratio = value.image.width / value.image.height;
                    holder.removedImage = File(path);
                    holder.resultFilePath = path;
                  });
                },
                size: imageSize,
              ),
              // opaque: true,
              settings: RouteSettings(name: "/ImRemoveBgScreen"),
            ),
          ).then((value) {
            if (value == true) {
              var newHolder = e.holder as ImageEditionBaseHolder;
              newHolder.setOriginFilePath(originFilePath);
              currentItem = e;
            }
          });
        } else {
          var newHolder = e.holder as ImageEditionBaseHolder;
          newHolder.setOriginFilePath(originFilePath);
          currentItem = e;
        }
      }
    }
  }

  Widget buildShownImage(Size size) {
    if (shownImage == null) {
      return CustomPaint(
          painter: BackgroundPainter(
            bgColor: Colors.transparent,
            w: 10,
            h: 10,
          ),
          child: Image.file(originFile));
    }
    return LibImageWidget(
      image: shownImage!,
      width: size.width,
      height: size.height,
    );
  }
}

class EditionStep {}

class EditionItem {
  late ImageEditionFunction function;
  late dynamic holder;

  EditionItem();
}
