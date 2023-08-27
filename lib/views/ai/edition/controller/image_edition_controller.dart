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
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/ai/edition/controller/crop_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/filter_adjust_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/remove_bg_holder.dart';
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
  late String _originPath;
  late AppState state;
  late Size showImageSize;
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

  imgLib.Image? _shownLibImage;

  setShownImage(imgLib.Image? image, {bool isUpdate = true}) async {
    _shownLibImage = image;
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
    required this.showImageSize,
  }) {
    _originPath = originPath;
  }

  @override
  void onInit() {
    super.onInit();
    var effectHolder = AllTransferController(originalPath: _originPath, itemList: recentItemList, style: effectStyle, initKey: initKey)
      ..parent = this
      ..onInit();
    var filterAdjustHolder = FilterAdjustHolder(parent: this)..onInit();
    var cropHolder = CropHolder(parent: this)..onInit();
    var removeBgHolder = RemoveBgHolder(parent: this)..onInit();
    items = [
      EditionItem()
        ..function = ImageEditionFunction.effect
        ..holder = effectHolder,
      EditionItem()
        ..function = ImageEditionFunction.filter
        ..holder = filterAdjustHolder,
      EditionItem()
        ..function = ImageEditionFunction.adjust
        ..holder = filterAdjustHolder,
      EditionItem()
        ..function = ImageEditionFunction.crop
        ..holder = cropHolder,
      EditionItem()
        ..function = ImageEditionFunction.removeBg
        ..holder = removeBgHolder,
    ];
    currentItem = items.pick((t) => t.function == initFunction) ?? items.first;
    if (currentItem.function != ImageEditionFunction.effect) {
      var holder = currentItem.holder as ImageEditionBaseHolder;
      holder.setOriginFilePath(_originPath);
    }
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
    final imageSize = Size(ScreenUtil.screenSize.width, ScreenUtil.screenSize.height - (kNavBarPersistentHeight + ScreenUtil.getStatusBarHeight() + $(140)));
    await Navigator.push(
      Get.context!,
      NoAnimRouter(
        ImRemoveBgScreen(
          bottomPadding: bottomHeight + ScreenUtil.getBottomPadding(Get.context!),
          filePath: _originPath,
          imageRatio: image.image.width / image.image.height,
          imageHeight: image.image.height.toDouble(),
          imageWidth: image.image.width.toDouble(),
          onGetRemoveBgImage: (String path) async {
            var imageInfo = await SyncFileImage(file: File(path)).getImage();
            var holder = currentItem.holder as RemoveBgHolder;
            holder.ratio = imageInfo.image.width / imageInfo.image.height;
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

  onRightTabClick(BuildContext context, EditionItem e) async {
    var bool = await preSwitch(context, e, currentItem);
    if (bool) {
      currentItem = e;
    }
  }

  Future<bool> preSwitch(BuildContext context, EditionItem target, EditionItem currentItem) async {
    if (target.holder == currentItem.holder) {
      if (target.holder is FilterAdjustHolder) {
        await (target.holder as FilterAdjustHolder).buildThumbnails();
        return true;
      }
    }
    if (target.function == currentItem.function) {
      if (target.function == ImageEditionFunction.removeBg && (target.holder as RemoveBgHolder).removedImage == null) {
        startRemoveBg();
      }
      return false;
    }
    if (target.function == ImageEditionFunction.effect) {
      if (currentItem.holder is TransferBaseController) {
        var oldController = currentItem.holder as TransferBaseController;
        var targetController = target.holder as TransferBaseController;
        if (oldController.originalPath != targetController.originalPath) {
          targetController.setOriginPath(oldController.originalPath);
        }
      } else {
        var oldHolder = currentItem.holder as ImageEditionBaseHolder;
        var targetController = target.holder as TransferBaseController;
        state.showLoading();
        await oldHolder.saveToResult();
        state.hideLoading();
        if (oldHolder.resultFilePath != targetController.originalPath) {
          targetController.setOriginPath(oldHolder.resultFilePath!);
        }
      }
      //跳转effect或者sticker
      return true;
    }
    if (currentItem.function == ImageEditionFunction.effect) {
      //从effect跳出
      var oldController = currentItem.holder as TransferBaseController;
      String oldPath = (oldController.resultFile ?? oldController.originFile).path;
      var targetHolder = target.holder as ImageEditionBaseHolder;
      String? targetPath = targetHolder.resultFilePath ?? targetHolder.originFilePath;
      if (oldPath == targetPath) {
        //没切换effect，不需要做任何处理
        return true;
      }
      state.showLoading();
      await targetHolder.setOriginFilePath(oldPath);
      state.hideLoading();
      if (target.function == ImageEditionFunction.removeBg && (target.holder as RemoveBgHolder).removedImage == null) {
        return false;
      }
      return true;
    } else {
      // if (target.function == ImageEditionFunction.removeBg) {
      //跳转removeBg，
      state.showLoading();
      var oldHolder = currentItem.holder as ImageEditionBaseHolder;
      await oldHolder.saveToResult();
      var targetHolder = target.holder as ImageEditionBaseHolder;
      String oldPath = oldHolder.resultFilePath ?? oldHolder.originFilePath!;
      String? targetPath = targetHolder.resultFilePath ?? targetHolder.originFilePath;
      if (oldPath == targetPath) {
        state.hideLoading();
        return true;
      } else {
        await targetHolder.setOriginFilePath(oldPath);
        state.hideLoading();
      }
      if (target.function == ImageEditionFunction.removeBg && (target.holder as RemoveBgHolder).removedImage == null) {
        return false;
      }
      return true;
      // } else {
      //   //其他Holder互相跳转，
      //   var oldHolder = currentItem.holder as ImageEditionBaseHolder;
      //   await oldHolder.saveToResult();
      //   var targetHolder = target.holder as ImageEditionBaseHolder;
      //   await targetHolder.onSwitchImage(oldHolder.shownImage!);
      //   return true;
      // }
    }
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
    );
  }

  Future<String?> saveResult() async {
    if (_shownLibImage == null) {
      return _originPath;
    }
    CacheManager cacheManager = AppDelegate().getManager();
    var dir = cacheManager.storageOperator.imageDir;
    var projName = EncryptUtil.encodeMd5(_originPath);
    var directory = Directory(dir.path + projName);
    await mkdir(directory);
    var fileName = getFileName(originFile.path);
    var targetFile = File(directory.path + '/${DateTime.now().millisecondsSinceEpoch}' + fileName.replaceFirst(".jpg", ".png"));
    var resultBytes = Uint8List.fromList(imgLib.encodePng(_shownLibImage!));
    await targetFile.writeAsBytes(resultBytes);
    return targetFile.path;
  }

// Widget buildShownImage(Size size) {
//   var imageData;
//   if (currentItem.function == ImageEditionFunction.adjust) {
//     if (adjustOperator.lastFun!.holder is TransferBaseController) {
//       var controller = adjustOperator.lastFun!.holder as TransferBaseController;
//       imageData = controller.resultFile ?? controller.originFile;
//     } else {
//       imageData = shownImage!;
//     }
//   }
//   if (imageData == null) {
//     return CustomPaint(
//         painter: BackgroundPainter(
//           bgColor: Colors.transparent,
//           w: 10,
//           h: 10,
//         ),
//         child: Image.file(originFile));
//   }
//   if (textureSource == null) {
//     return FutureBuilder<TextureSource?>(
//         future: getData(imageData),
//         builder: (c, s) {
//           final image = s.data;
//           if (image == null) {
//             return const CircularProgressIndicator();
//           }
//           var targetCoverRect = ImageUtils.getTargetCoverRect(size, Size(image.width.toDouble(), image.height.toDouble()));
//           var w = targetCoverRect.width;
//           var h = targetCoverRect.height;
//           return PipelineImageShaderPreview(
//             configuration: adjustOperator.buildConfiguration(),
//             texture: image,
//           ).intoContainer(width: w, height: h).intoCenter().intoContainer(width: size.width, height: size.height);
//         });
//   } else {
//     var targetCoverRect = ImageUtils.getTargetCoverRect(size, Size(textureSource!.width.toDouble(), textureSource!.height.toDouble()));
//     var w = targetCoverRect.width;
//     var h = targetCoverRect.height;
//     return PipelineImageShaderPreview(
//       configuration: adjustOperator.buildConfiguration(),
//       texture: textureSource!,
//     ).intoContainer(width: w, height: h).intoCenter().intoContainer(width: size.width, height: size.height);
//   }
//   // return FilterPreviewCard(data: imageData!, configuration: adjustOperator.buildConfiguration(), width: size.width, height: size.height);
//   // return LibImageWidget(
//   //   image: shownImage!,
//   //   width: size.width,
//   //   height: size.height,
//   // );
// }
//
// TextureSource? textureSource;
//
// Future<TextureSource?> getData(dynamic data) async {
//   if (data is Uint8List) {
//     textureSource = await TextureSource.fromMemory(data);
//   } else if (data is File) {
//     textureSource = await TextureSource.fromFile(data);
//   } else if (data is ui.Image) {
//     textureSource = TextureSource.fromImage(data);
//   } else if (data is String) {
//     textureSource = await TextureSource.fromAsset(data);
//   }
//   return textureSource;
// }
}

class EditionStep {}

class EditionItem {
  late ImageEditionFunction function;
  late dynamic holder;

  EditionItem();
}
