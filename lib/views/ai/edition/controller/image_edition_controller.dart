import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/lib_image_widget/lib_image_widget.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/ai/edition/controller/filters/filters_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/remove_bg_holder.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';
import 'package:cartoonizer/views/mine/filter/im_remove_bg_screen.dart';
import 'package:cartoonizer/views/transfer/controller/all_transfer_controller.dart';
import 'package:cartoonizer/views/transfer/controller/transfer_base_controller.dart';
import 'package:common_utils/common_utils.dart';
import 'package:image/image.dart' as imgLib;

import '../../../../Widgets/app_navigation_bar.dart';
import '../../../../utils/utils.dart';

class ImageEditionController extends GetxController {
  final String photoType;
  final String source;
  final String? initKey;
  final ImageEditionFunction initFunction;
  final List<RecentAdjustData> recentAdjust;
  final FilterEnum recentFilter;
  final Rect recentCropRect;

  late String _originPath;

  late AppState state;
  late Size imageContainerSize;

  Rx<Size> showImageSize = Size.zero.obs;

  double bottomHeight = 0;
  double switchButtonBottomToScreen = 0;

  File get originFile => File(_originPath);

  final EffectStyle effectStyle;

  late EditionItem _currentItem;

  EditionItem get currentItem => _currentItem;

  set currentItem(EditionItem func) {
    _currentItem = func;
    EventBusHelper().eventBus.fire(OnEditionRightTabSwitchEvent(data: func.function.title()));
    update();
  }

  EditionItem? _lastItem;

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

  setUiShownImage(imgLib.Image? image, {bool isUpdate = true}) async {
    if (image == null) {
      _shownImage = null;
    } else {
      _shownImage = await toImage(image);
    }
    if (isUpdate) {
      update();
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
    required this.imageContainerSize,
    required this.recentFilter,
    required this.recentAdjust,
    required this.recentCropRect,
  }) {
    _originPath = originPath;
  }

  late FiltersHolder filtersHolder;
  late RemoveBgHolder removeBgHolder;

  @override
  void onInit() {
    filtersHolder = FiltersHolder(
      parent: this,
      filter: recentFilter,
      adjust: recentAdjust,
      crop: recentCropRect,
    )..onInit();
    removeBgHolder = RemoveBgHolder(parent: this)..onInit();
    items = [
      EditionItem()
        ..function = ImageEditionFunction.filter
        ..holder = filtersHolder,
      EditionItem()
        ..function = ImageEditionFunction.adjust
        ..holder = filtersHolder,
      EditionItem()
        ..function = ImageEditionFunction.crop
        ..holder = filtersHolder,
      EditionItem()
        ..function = ImageEditionFunction.removeBg
        ..holder = removeBgHolder,
    ];
    if (initFunction != ImageEditionFunction.removeBg) {
      var effectHolder = AllTransferController(originalPath: _originPath, itemList: recentItemList, style: effectStyle, initKey: initKey)
        ..parent = this
        ..onInit();
      items.insert(
        0,
        EditionItem()
          ..function = ImageEditionFunction.effect
          ..holder = effectHolder,
      );
    }
    currentItem = items.pick((t) => t.function == initFunction) ?? items.first;
    filtersHolder.setOriginFilePath(_originPath, conf: true);
    if (initFunction == ImageEditionFunction.removeBg) {
      removeBgHolder.setOriginFilePath(_originPath);
    }
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    if (currentItem.function == ImageEditionFunction.effect) {
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
    final imageSize = Size(ScreenUtil.screenSize.width,
        ScreenUtil.screenSize.height - (kNavBarPersistentHeight + ScreenUtil.getStatusBarHeight() + $(140) + ScreenUtil.getBottomPadding(Get.context!)));
    var holder = currentItem.holder as RemoveBgHolder;
    await Navigator.push(
      Get.context!,
      NoAnimRouter(
        ImRemoveBgScreen(
          bottomPadding: bottomHeight + ScreenUtil.getBottomPadding(Get.context!),
          filePath: holder.originFilePath ?? _originPath,
          imageRatio: image.image.width / image.image.height,
          imageHeight: image.image.height.toDouble(),
          imageWidth: image.image.width.toDouble(),
          onGetRemoveBgImage: (String path) async {
            filtersHolder.cropOperator.currentItem = null;
            filtersHolder.cropOperator.setCropData(Rect.zero);
            var imageInfo = await SyncFileImage(file: File(path)).getImage();
            holder.config.ratio = imageInfo.image.width / imageInfo.image.height;
            holder.removedImage = File(path);
            holder.imageUiFront = await getImage(File(path));
            var imageFront = await getLibImage(holder.imageUiFront!);
            await holder.setShownImage(imageFront);
            holder.imageFront = imageFront;
            holder.bgController.setBackgroundData(null, Colors.transparent);
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

  switchBack(BuildContext context) async {
    if (_lastItem == null) {
      Navigator.of(context).pop();
    } else {
      currentItem = _lastItem!;
    }
  }

  onRightTabClick(BuildContext context, EditionItem e) async {
    var bool = await preSwitch(context, e, currentItem);
    _lastItem = currentItem;
    if (bool) {
      currentItem = e;
      delay(() {
        if (e.function == ImageEditionFunction.filter) {
          filtersHolder.filterOperator.restorePos();
        } else if (e.function == ImageEditionFunction.adjust) {
          filtersHolder.adjustOperator.restorePos();
        } else if (e.function == ImageEditionFunction.crop) {
          filtersHolder.cropOperator.restorePos();
        }
      }, milliseconds: 30);
    }
  }

  Future<bool> preSwitch(BuildContext context, EditionItem target, EditionItem currentItem) async {
    if (target.holder == currentItem.holder) {
      if (target.holder is FiltersHolder) {
        if (target.function == ImageEditionFunction.filter && _currentItem.function != ImageEditionFunction.filter) {
          await (target.holder as FiltersHolder).buildThumbnails();
        }
        return true;
      } else {
        if (target.function == ImageEditionFunction.removeBg && (target.holder as RemoveBgHolder).removedImage == null) {
          startRemoveBg();
        }
        return false;
      }
    }
    if (target.function == ImageEditionFunction.effect) {
      return await jumpToEffect(context, target);
    }
    if (target.function == ImageEditionFunction.filter || target.function == ImageEditionFunction.adjust || target.function == ImageEditionFunction.crop) {
      return await jumpToFilters(context, target);
    }
    if (target.function == ImageEditionFunction.removeBg) {
      return await jumpToRemoveBg(context, target);
    }
    return false;
  }

  Future<bool> jumpToEffect(BuildContext context, EditionItem target) async {
    //跳转effect
    var targetController = target.holder as TransferBaseController;
    if (currentItem.holder is FiltersHolder) {
      var oldHolder = currentItem.holder as FiltersHolder;
      state.showLoading();
      String? filePath = await oldHolder.saveToResult();
      state.hideLoading();
      if (TextUtil.isEmpty(filePath)) {
        filePath = oldHolder.originFilePath;
      }
      if (TextUtil.isEmpty(filePath)) {
        return true;
      }
      await targetController.setOriginPath(filePath!);
      return true;
    } else if (currentItem.holder is RemoveBgHolder) {
      var oldHolder = currentItem.holder as RemoveBgHolder;
      state.showLoading();
      String filePath = await oldHolder.saveToResult();
      state.hideLoading();
      await targetController.setOriginPath(filePath);
      return true;
    }
    return false;
  }

  Future<bool> jumpToFilters(BuildContext context, EditionItem target) async {
    var targetHolder = target.holder as FiltersHolder;
    if (currentItem.holder is TransferBaseController) {
      var oldHolder = currentItem.holder as TransferBaseController;
      var oldPath = (oldHolder.resultFile ?? oldHolder.originFile).path;
      if (oldPath == targetHolder.originFilePath) {
        return true;
      }
      await targetHolder.setOriginFilePath(oldPath);
      return true;
    } else if (currentItem.holder is RemoveBgHolder) {
      var oldHolder = currentItem.holder as RemoveBgHolder;
      state.showLoading();
      String filePath = await oldHolder.saveToResult();
      state.hideLoading();
      await targetHolder.setOriginFilePath(filePath);
      return true;
    }
    return false;
  }

  Future<bool> jumpToRemoveBg(BuildContext context, EditionItem target) async {
    var targetHolder = target.holder as RemoveBgHolder;
    if (currentItem.holder is TransferBaseController) {
      var oldHolder = currentItem.holder as TransferBaseController;
      var oldPath = (oldHolder.resultFile ?? oldHolder.originFile).path;
      if (targetHolder.originFilePath == oldPath || targetHolder.resultFilePath == oldPath) {
        //没操作过，直接切换
        return true;
      }
      var needRemove = await needRemoveBg(context, targetHolder);
      if (!needRemove) {
        return false;
      }
      if (targetHolder.originFilePath != oldPath) {
        await targetHolder.setOriginFilePath(oldPath, conf: needRemove);
      }
      return true;
    } else if (currentItem.holder is FiltersHolder) {
      var oldHolder = currentItem.holder as FiltersHolder;
      var oldPath = oldHolder.originFilePath;
      if (oldHolder.initHash == oldHolder.getConfigKey() && (targetHolder.originFilePath == oldPath || targetHolder.resultFilePath == oldPath)) {
        //没操作过，直接切换
        return true;
      }
      var needRemove = await needRemoveBg(context, targetHolder);
      if (!needRemove) {
        return false;
      }
      if (needRemove) {
        oldPath = await oldHolder.saveToResult(force: true);
      }
      if (targetHolder.originFilePath != oldPath) {
        await targetHolder.setOriginFilePath(oldPath, conf: needRemove);
      }
      return true;
    }
    return false;
  }

  Future<bool> needRemoveBg(BuildContext context, RemoveBgHolder holder) async {
    bool needRemove = true;
    if (holder.removedImage != null) {
      var bool = await showEnsureToSwitchRemoveBg(context);
      if (bool == null || bool == false) {
        needRemove = false;
      }
    }
    return needRemove;
  }

  Widget buildShownImage(Size size) {
    if (shownImage == null) {
      return Container(
        width: size.width,
        height: size.height,
      );
    }
    int w = shownImage!.width;
    int h = shownImage!.height;
    double wScale = w.toDouble() / size.width.toDouble();
    double hScale = h.toDouble() / size.height.toDouble();
    if (wScale < hScale) {
      w = (w / hScale).toInt();
      h = size.height.toInt();
    } else {
      h = (h / wScale).toInt();
      w = size.width.toInt();
    }

    return LibImageWidget(
      image: shownImage!,
      width: w.toDouble(),
      height: h.toDouble(),
      onResized: (imageRect) {
        delay(() {
          showImageSize.value = imageRect.size;
        });
      },
    );
  }
}

class EditionStep {}

class EditionItem {
  late ImageEditionFunction function;
  late dynamic holder;

  EditionItem();
}
