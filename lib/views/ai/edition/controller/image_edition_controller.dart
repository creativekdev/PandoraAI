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
import 'ie_base_holder.dart';

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
  Size _showImageSize = Size.zero;

  Size get showImageSize => _showImageSize;

  set showImageSize(Size size) {
    _showImageSize = size;
    update();
  }

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

  setShownImage(imgLib.Image? image, {bool isUpdate = true}) async {
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
            filtersHolder.cropOperator.cropData = Rect.zero;
            var imageInfo = await SyncFileImage(file: File(path)).getImage();
            holder.config.ratio = imageInfo.image.width / imageInfo.image.height;
            holder.removedImage = File(path);
            holder.imageUiFront = await getImage(File(path));
            var imageFront = await getLibImage(holder.imageUiFront!);
            holder.shownImage = imageFront;
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
      //跳转effect
      var oldHolder = currentItem.holder as ImageEditionBaseHolder;
      var targetController = target.holder as TransferBaseController;
      state.showLoading();
      String filePath = await oldHolder.saveToResult();
      state.hideLoading();
      if (filePath != targetController.originalPath && !TextUtil.isEmpty(filePath)) {
        await targetController.setOriginPath(filePath);
      }
      return true;
    }
    if (currentItem.function == ImageEditionFunction.effect) {
      //从effect跳出
      var oldController = currentItem.holder as TransferBaseController;
      String oldPath = (oldController.resultFile ?? oldController.originFile).path;
      var targetHolder = target.holder as ImageEditionBaseHolder;
      if (oldPath == targetHolder.originFilePath || oldPath == targetHolder.resultFilePath) {
        //没切换file，不需要做任何处理
        return true;
      }
      // bool needRemove = await needRemoveBg(context, target);
      state.showLoading();
      await targetHolder.setOriginFilePath(oldPath, conf: true);
      state.hideLoading();
      if (target.function == ImageEditionFunction.removeBg && (target.holder as RemoveBgHolder).removedImage == null) {
        return false;
      }
      return true;
    } else {
      //其他跳转
      state.showLoading();
      var oldHolder = currentItem.holder as ImageEditionBaseHolder;
      String filePath = await oldHolder.saveToResult();
      if (TextUtil.isEmpty(filePath)) {
        state.hideLoading();
        return true;
      }
      var targetHolder = target.holder as ImageEditionBaseHolder;
      String? targetPath = targetHolder.originFilePath;
      if (filePath == targetPath) {
        state.hideLoading();
        if (target.function == ImageEditionFunction.removeBg && (target.holder as RemoveBgHolder).removedImage == null) {
          startRemoveBg();
        }
        return true;
      } else {
        bool needRemove = await needRemoveBg(context, target);
        await targetHolder.setOriginFilePath(filePath, conf: needRemove);
        state.hideLoading();
      }
      if (target.function == ImageEditionFunction.removeBg && (target.holder as RemoveBgHolder).removedImage == null) {
        return false;
      }
      return true;
    }
  }

  Future<bool> needRemoveBg(BuildContext context, EditionItem target) async {
    bool needRemove = true;
    if (target.function == ImageEditionFunction.removeBg) {
      var holder = target.holder as RemoveBgHolder;
      if (holder.removedImage != null) {
        var bool = await showEnsureToSwitchRemoveBg(context);
        if (bool == null || bool == false) {
          needRemove = false;
        }
      }
    }
    return needRemove;
  }

  Widget buildShownImage(Size size) {
    if (shownImage == null) {
      return Image.file(originFile);
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
          showImageSize = imageRect.size;
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
