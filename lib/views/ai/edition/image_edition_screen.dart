import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/controller/recent/recent_controller.dart';
import 'package:cartoonizer/controller/upload_image_controller.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/home_card_type.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/models/recent_entity.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/li_pop_menu.dart';
import 'package:cartoonizer/views/ai/edition/controller/ie_base_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/image_edition_controller.dart';
import 'package:cartoonizer/views/ai/edition/controller/remove_bg_holder.dart';
import 'package:cartoonizer/views/ai/edition/widget/adjust_options.dart';
import 'package:cartoonizer/views/ai/edition/widget/crop_options.dart';
import 'package:cartoonizer/views/ai/edition/widget/filter_options.dart';
import 'package:cartoonizer/views/ai/edition/widget/remove_bg_options.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:cartoonizer/views/transfer/controller/all_transfer_controller.dart';
import 'package:cartoonizer/views/transfer/controller/transfer_base_controller.dart';
import 'package:cartoonizer/widgets/app_navigation_bar.dart';
import 'package:cartoonizer/widgets/background_card.dart';
import 'package:cartoonizer/widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:common_utils/common_utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../../../app/app.dart';
import '../../../app/thirdpart/thirdpart_manager.dart';
import '../../../app/user/user_manager.dart';
import '../../../common/Extension.dart';
import '../../../utils/img_utils.dart';
import '../../print/print.dart';
import '../../share/ShareScreen.dart';
import 'image_edition.dart';
import 'widget/effect_options.dart';

class ImageEditionScreen extends StatefulWidget {
  String source;
  String filePath;
  String? initKey;
  EffectStyle style;
  String photoType;
  ImageEditionFunction initFunction;
  List<RecentEffectItem> recentEffectItems;
  List<RecentAdjustData> adjustData;
  FilterEnum filter;
  Rect cropRect;
  bool autoGenerate;

  ImageEditionScreen({
    super.key,
    required this.autoGenerate,
    required this.source,
    required this.filePath,
    required this.initKey,
    required this.style,
    required this.photoType,
    required this.initFunction,
    required this.recentEffectItems,
    required this.adjustData,
    required this.filter,
    required this.cropRect,
  });

  @override
  State<ImageEditionScreen> createState() => _ImageEditionScreenState();
}

class _ImageEditionScreenState extends AppState<ImageEditionScreen> {
  late ImageEditionController controller;
  Rx<bool> titleShow = false.obs;
  late StreamSubscription onRightTitleSwitchEvent;

  late TimerUtil timer;
  String? title;
  late Size imageSize;
  late StreamSubscription onLimitDialogCancelListener;
  Rx<bool> generateAgainVisible = false.obs;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'image_edition_screen');
    imageSize = ImageEdition.getShownImageSize();
    controller = Get.put(ImageEditionController(
      originPath: widget.filePath,
      effectStyle: widget.style,
      initFunction: widget.initFunction,
      initKey: widget.initKey,
      photoType: widget.photoType,
      source: widget.source,
      recentFilter: widget.filter,
      recentAdjust: widget.adjustData,
      recentCropRect: widget.cropRect,
      recentItemList: widget.recentEffectItems,
      imageContainerSize: imageSize,
      autoGenerate: widget.autoGenerate,
    )..state = this);
    controller.bottomHeight = $(140) + ScreenUtil.getBottomPadding(Get.context!);
    timer = TimerUtil()
      ..setInterval(2000)
      ..setOnTimerTickCallback(
        (millisUntilFinished) {
          if (millisUntilFinished > 0) {
            titleShow.value = false;
            timer.cancel();
          }
        },
      );
    onRightTitleSwitchEvent = EventBusHelper().eventBus.on<OnEditionRightTabSwitchEvent>().listen((event) {
      timer.cancel();
      title = event.data;
      titleShow.value = true;
      timer.startTimer();
    });
    onLimitDialogCancelListener = EventBusHelper().eventBus.on<OnLimitDialogCancelEvent>().listen((event) {
      controller.switchBack(context);
    });
  }

  @override
  onBlankTap() {
    EventBusHelper().eventBus.fire(OnHideDeleteStatusEvent());
  }

  Future<String> saveRecent() async {
    var holder = controller.currentItem.holder as ImageEditionBaseHolder;
    String value = await holder.saveToResult(force: true);
    var recentController = Get.find<RecentController>();
    String originPath = holder.originFile!.path;
    if (controller.currentItem.holder is RemoveBgHolder) {
      originPath = value;
    }
    var filtersHolder = controller.filtersHolder;
    recentController.onImageEditionUsed(
      originPath,
      value,
      filtersHolder.filterOperator.currentFilter,
      filtersHolder.adjustOperator.adjustList
          .map((e) => RecentAdjustData()
            ..mAdjustFunction = e.function
            ..value = e.value)
          .toList(),
      filtersHolder.cropOperator.getFinalRect(),
      [],
    );
    return value;
  }

  saveToAlbum() async {
    await showLoading();
    if (controller.currentItem.function == ImageEditionFunction.effect) {
      TransferBaseController effectHolder = controller.currentItem.holder;
      String path = (effectHolder.resultFile ?? effectHolder.originFile).path;
      await GallerySaver.saveImage(path.replaceFirst('.jpg', '.png'), albumName: saveAlbumName);
    } else {
      String value = await saveRecent();
      await GallerySaver.saveImage(value, albumName: saveAlbumName);
    }
    await hideLoading();
    Events.styleImageEditionCompleteSave(source: controller.source, type: 'image');
    CommonExtension().showImageSavedOkToast(context);
  }

  shareToDiscovery() async {
    String? resultPath;
    HomeCardType type = HomeCardType.imageEdition;
    String effectKey = 'image_edition';
    showLoading();
    if (controller.currentItem.holder is TransferBaseController) {
      var baseController = controller.currentItem.holder as TransferBaseController;
      resultPath = baseController.resultFile?.path;
      if (baseController.getCategory() == 'cartoonize') {
        type = HomeCardType.cartoonize;
      } else {
        type = HomeCardType.stylemorph;
      }
      effectKey = baseController.selectedEffect?.key ?? '';
    } else if (controller.currentItem.holder is ImageEditionBaseHolder) {
      var holder = controller.currentItem.holder as ImageEditionBaseHolder;
      resultPath = await holder.saveToResult(force: true);
    }
    if (TextUtil.isEmpty(resultPath)) {
      hideLoading();
      return;
    }
    UploadImageController uploadImageController = Get.find();
    String? imageUrl = uploadImageController.imageUrl(controller.originFile).value;
    if (TextUtil.isEmpty(imageUrl)) {
      imageUrl = await uploadImageController.upload(file: controller.originFile);
      if (TextUtil.isEmpty(imageUrl)) {
        hideLoading();
        return;
      } else {
        hideLoading();
      }
    } else {
      hideLoading();
    }
    AppDelegate.instance.getManager<UserManager>().doOnLogin(context, logPreLoginAction: 'share_discovery_from_image_edition', callback: () {
      var file = File(resultPath!);
      ShareDiscoveryScreen.push(
        context,
        effectKey: effectKey,
        originalUrl: imageUrl,
        image: base64Encode(file.readAsBytesSync()),
        isVideo: false,
        category: type,
      ).then((value) {
        if (value ?? false) {
          Events.styleImageEditionCompleteDiscovery(source: controller.source, type: 'image');
          showShareSuccessDialog(context);
        }
      });
    }, autoExec: true);
  }

  gotoPrint() async {
    String? resultPath;
    showLoading();
    if (controller.currentItem.holder is TransferBaseController) {
      var baseController = controller.currentItem.holder as TransferBaseController;
      resultPath = (baseController.resultFile ?? baseController.originFile).path;
    } else if (controller.currentItem.holder is ImageEditionBaseHolder) {
      var holder = controller.currentItem.holder as ImageEditionBaseHolder;
      resultPath = await holder.saveToResult(force: true);
    }
    hideLoading();
    File? file = null;
    if (resultPath != null) {
      file = File(resultPath);
    } else {
      return;
    }
    Events.styleImageEditionCompletePrint(source: widget.source);
    Print.open(context, source: widget.source, file: file);
  }

  shareOut() async {
    showLoading();
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
    var userManager = AppDelegate().getManager<UserManager>();
    var uint8list;
    if (controller.currentItem.function == ImageEditionFunction.effect) {
      TransferBaseController effectHolder = controller.currentItem.holder;
      if (effectHolder.resultFile != null) {
        if (effectHolder.getCategory() == 'cartoonize') {
          uint8list =
              await ImageUtils.printCartoonizeDrawData(controller.originFile, File(effectHolder.resultFile!.path), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
        } else if (effectHolder.getCategory() == 'stylemorph') {
          uint8list =
              await ImageUtils.printStyleMorphDrawData(controller.originFile, File(effectHolder.resultFile!.path), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
        } else {
          throw Exception('未定义的effectStyle');
        }
      } else {
        uint8list = await controller.originFile.readAsBytes();
      }
    } else {
      var holder = controller.currentItem.holder as ImageEditionBaseHolder;
      var s = await holder.saveToResult(force: true);
      uint8list = await File(s).readAsBytes();
    }
    hideLoading();
    ShareScreen.startShare(context, backgroundColor: Color(0x77000000), style: "image_edition", image: base64Encode(uint8list), isVideo: false, originalUrl: null, effectKey: "",
        onShareSuccess: (platform) {
      Events.styleFilterCompleteShare(source: widget.source, platform: platform, type: 'image');
    });
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
  }

  @override
  void dispose() {
    Get.delete<ImageEditionController>();
    timer.cancel();
    onLimitDialogCancelListener.cancel();
    onRightTitleSwitchEvent.cancel();
    super.dispose();
  }

  PreferredSizeWidget buildNavigationBar(BuildContext context) {
    return AppNavigationBar(
      backAction: () {
        _willPopCallback(context);
      },
      middle: Image.asset(
        Images.ic_download,
        height: $(24),
        width: $(24),
      ).intoContainer(padding: EdgeInsets.all($(8))).intoGestureDetector(onTap: () => saveToAlbum()),
      trailing: Image.asset(
        Images.ic_more,
        width: $(24),
      ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(8), vertical: $(8)), color: Colors.transparent).intoGestureDetector(onTap: () async {
        LiPopMenu.showLinePop(
          context,
          listData: [
            ListPopItem(text: S.of(context).share_to_discovery, icon: Images.ic_share_discovery, onTap: () => shareToDiscovery()),
            ListPopItem(text: S.of(context).share_out, icon: Images.ic_share, onTap: () => shareOut()),
            ListPopItem(text: S.of(context).print, icon: Images.ic_share_print, onTap: () => gotoPrint()),
          ],
        );
      }),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
        child: GetBuilder<ImageEditionController>(
          builder: (controller) {
            return Scaffold(
              body: Column(children: [
                buildNavigationBar(context),
                Expanded(child: Stack(
                  fit: StackFit.expand,
                  children: [
                    buildContent(context, controller).intoContainer(
                      margin: EdgeInsets.only(bottom: $(140) + ScreenUtil.getBottomPadding(context)),
                    ),
                    Align(
                      child: buildOptions(context, controller).intoContainer(
                        padding: EdgeInsets.only(top: $(15)),
                        height: $(140) + ScreenUtil.getBottomPadding(context),
                        decoration: BoxDecoration(
                            gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [
                              ColorConstant.BackgroundColor.withOpacity(0),
                              ColorConstant.BackgroundColor.withOpacity(0.2),
                              ColorConstant.BackgroundColor.withOpacity(0.4),
                              ColorConstant.BackgroundColor.withOpacity(0.6),
                              ColorConstant.BackgroundColor.withOpacity(0.8),
                              ColorConstant.BackgroundColor,
                              ColorConstant.BackgroundColor,
                              ColorConstant.BackgroundColor,
                            ])),
                      ),
                      alignment: Alignment.bottomCenter,
                    )
                  ],
                )),
              ],),
            );
          },
          init: Get.find<ImageEditionController>(),
        ),
        onWillPop: () async {
          return _willPopCallback(context);
        });
  }

  Future<bool> _willPopCallback(BuildContext context) async {
    showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: $(20)),
          TitleTextWidget(S.of(context).exit_msg, ColorConstant.White, FontWeight.w600, 18),
          SizedBox(height: $(15)),
          TitleTextWidget(S.of(context).exit_msg1, ColorConstant.HintColor, FontWeight.w400, 14),
          SizedBox(height: $(15)),
          TitleTextWidget(
            S.of(context).exit_editing,
            ColorConstant.White,
            FontWeight.w600,
            16,
          )
              .intoContainer(
            margin: EdgeInsets.symmetric(horizontal: $(25)),
            padding: EdgeInsets.symmetric(vertical: $(10)),
            width: double.maxFinite,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(6), color: ColorConstant.BlueColor),
          )
              .intoGestureDetector(onTap: () {
            Navigator.pop(context, true);
          }),
          TitleTextWidget(
            S.of(context).cancel,
            ColorConstant.White,
            FontWeight.w400,
            16,
          ).intoPadding(padding: EdgeInsets.only(top: $(15), bottom: $(25))).intoGestureDetector(onTap: () {
            Navigator.pop(context);
          }),
        ],
      ).intoContainer(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        decoration: BoxDecoration(
          color: ColorConstant.EffectFunctionGrey,
          borderRadius: BorderRadius.only(topLeft: Radius.circular($(32)), topRight: Radius.circular($(32))),
        ),
      ),
    ).then((value) {
      if (value ?? false) {
        Navigator.pop(context);
      }
    });
    return false;
  }

  Widget buildContent(BuildContext context, ImageEditionController controller) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Obx(() => BackgroundCard(
            bgColor: Colors.transparent,
            child: SizedBox(
              width: controller.showImageSize.value.width,
              height: controller.showImageSize.value.height,
            )).intoCenter()),
        getImageWidget(context, controller).hero(tag: ImageEdition.TagImageEditView).intoCenter(),
        Obx(
          () => Align(
            child: generateAgainBtn(context, () {
              if (controller.currentItem.function == ImageEditionFunction.effect) {
                controller.generate(context, controller.currentItem.holder);
              } else if (controller.currentItem.function == ImageEditionFunction.removeBg) {
                controller.removeBgHolder.initData();
              }
            }).intoContainer(padding: EdgeInsets.only(bottom: (imageSize.height - controller.showImageSize.value.height) / 2)),
            alignment: Alignment.bottomCenter,
          ).visibility(visible: generateAgainVisible.value),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: buildMenus(context, controller),
        ),
        Align(
          alignment: Alignment.center,
          child: Obx(
            () => Text(
              title ?? '',
              style: TextStyle(color: Color(0xfff9f9f9), fontSize: $(18), fontWeight: FontWeight.bold),
            ).visibility(visible: titleShow.value),
          ),
        )
      ],
    );
  }

  syncShowImageSizeInEffect(File file, bool showOrigin) {
    SyncFileImage(file: file).getImage().then((value) {
      if (showOrigin == controller.showOrigin) {
        controller.showImageSize.value = ImageUtils.getTargetCoverRect(imageSize, Size(value.image.width.toDouble(), value.image.height.toDouble())).size;
      }
    });
  }

  Widget getImageWidget(BuildContext context, ImageEditionController controller) {
    if (controller.currentItem.function == ImageEditionFunction.UNDEFINED) {
      return Container();
    }
    if (controller.currentItem.function == ImageEditionFunction.effect) {
      var effectController = controller.currentItem.holder as AllTransferController;
      generateAgainVisible.value = effectController.selectedEffect?.parent == 'stylemorph' && effectController.resultFile != null;
      var file = controller.showOrigin ? controller.originFile : effectController.resultFile ?? effectController.originFile;
      syncShowImageSizeInEffect(file, controller.showOrigin);
      return Image.file(
        file,
        fit: BoxFit.cover,
        width: imageSize.width,
      );
    } else if (controller.currentItem.function == ImageEditionFunction.removeBg) {
      var removeBgHolder = controller.currentItem.holder as RemoveBgHolder;
      var file = controller.showOrigin ? controller.originFile : (removeBgHolder.removedImage == null ? removeBgHolder.originFile : removeBgHolder.removedImage);
      if (file != null) {
        SyncFileImage(file: file).getImage().then((value) {
          controller.showImageSize.value = ImageUtils.getTargetCoverRect(imageSize, Size(value.image.width.toDouble(), value.image.height.toDouble())).size;
        });
      }
      // 使用RX变量监听showImageSize的变化
      return controller.showOrigin
          ? Image.file(controller.originFile)
          : removeBgHolder.buildShownImage(imageSize, controller.showImageSize, (needGenerateAgain) {
              generateAgainVisible.value = needGenerateAgain;
            });
    } else {
      generateAgainVisible.value = false;
      if (controller.showOrigin) {
        SyncFileImage(file: controller.originFile).getImage().then((value) {
          controller.showImageSize.value = ImageUtils.getTargetCoverRect(imageSize, Size(value.image.width.toDouble(), value.image.height.toDouble())).size;
        });
      }
      return controller.showOrigin ? Image.file(controller.originFile) : controller.buildShownImage(imageSize);
    }
  }

  Widget generateAgainBtn(BuildContext context, Function onTap) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(Images.ic_edition_generate, color: Colors.white, width: $(20)),
        SizedBox(width: $(4)),
        TitleTextWidget(S.of(context).generate_again, ColorConstant.White, FontWeight.w500, $(13)),
      ],
    )
        .intoContainer(
          padding: EdgeInsets.symmetric(vertical: $(6), horizontal: $(10)),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular($(32)),
              gradient: LinearGradient(colors: [
                Color(0xff243CFF),
                Color(0xffB477FC),
              ], begin: Alignment.topLeft, end: Alignment.bottomRight)),
        )
        .intoContainer(
            padding: EdgeInsets.all($(2)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular($(32)),
              color: Color(0x33000000),
            ))
        .intoGestureDetector(onTap: () {
      onTap.call();
    }).intoContainer(
      alignment: Alignment.center,
      height: $(54),
    );
  }

  Widget buildMenus(BuildContext context, ImageEditionController controller) {
    bool canReset = false;
    if (controller.currentItem.function == ImageEditionFunction.effect) {
      canReset = false;
    } else {
      if (controller.currentItem.function == ImageEditionFunction.adjust) {
        canReset = controller.filtersHolder.adjustOperator.diffWithOri();
      } else {
        canReset = (controller.currentItem.holder as ImageEditionBaseHolder).canReset;
      }
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          children: controller.items.map((e) {
            return Image.asset(e.function.icon(), width: $(24), height: $(24))
                .intoContainer(
                    padding: EdgeInsets.all($(8)),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular($(32)),
                      border: Border.all(color: controller.currentItem == e ? Color(0xffa3a3a3) : Colors.transparent, width: 1.4),
                      color: controller.currentItem == e ? Color(0x5e000000) : Colors.transparent,
                    ))
                .intoGestureDetector(onTap: () => controller.onRightTabClick(context, e))
                .intoContainer(margin: EdgeInsets.symmetric(vertical: $(0.5)));
          }).toList(),
        ).intoContainer(
          padding: EdgeInsets.symmetric(horizontal: $(4), vertical: $(4)),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular($(32)), color: Color(0xff555555).withOpacity(0.4)),
        ),
        SizedBox(height: $(50)),
        Row(
          children: [
            Image.asset(Images.ic_edition_reset, width: $(24), height: $(24))
                .intoContainer(
                  padding: EdgeInsets.all($(12)),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular($(32)), color: Color(0xff555555).withOpacity(0.4)),
                )
                .intoGestureDetector(onTap: () => onResetClick(context, controller))
                .visibility(visible: canReset),
            Expanded(child: Container()),
            Image.asset(Images.ic_switch_images, width: $(24), height: $(24))
                .intoContainer(
              padding: EdgeInsets.all($(12)),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular($(32)), color: Color(0xff555555).withOpacity(0.4)),
            )
                .intoGestureDetector(
              onTapDown: (details) {
                controller.showOrigin = true;
              },
              onTapUp: (details) {
                controller.showOrigin = false;
              },
              onTapCancel: () {
                controller.showOrigin = false;
              },
            ),
          ],
        ),
      ],
    ).intoContainer(margin: EdgeInsets.only(right: $(8), left: $(8))).listenSizeChanged(onSizeChanged: (size) {
      var bottomPadding = ScreenUtil.getBottomPadding(context);
      var paddingB = (ScreenUtil.screenSize.height - ScreenUtil.getStatusBarHeight() - controller.bottomHeight - bottomPadding - kNavBarPersistentHeight - size.height) / 2;
      controller.switchButtonBottomToScreen = controller.bottomHeight + paddingB + bottomPadding;
    });
  }

  Widget buildOptions(BuildContext context, ImageEditionController controller) {
    switch (controller.currentItem.function) {
      case ImageEditionFunction.effect:
        return EffectOptions(
          controller: controller.currentItem.holder,
        );
      case ImageEditionFunction.filter:
        return FilterOptions(
          controller: controller.currentItem.holder,
          parentState: this,
        );
      case ImageEditionFunction.adjust:
        return AdjustOptions(controller: controller.currentItem.holder);
      case ImageEditionFunction.crop:
        return CropOptions(controller: controller.currentItem.holder);
      case ImageEditionFunction.removeBg:
        return RemoveBgOptions(
          parentState: this,
          controller: controller.currentItem.holder,
          bottomPadding: controller.bottomHeight + ScreenUtil.getBottomPadding(Get.context!),
          switchButtonPadding: controller.switchButtonBottomToScreen,
        );
      case ImageEditionFunction.UNDEFINED:
        break;
    }
    return Container();
  }

  onResetClick(BuildContext context, ImageEditionController controller) {
    if (controller.currentItem.function == ImageEditionFunction.effect) {
      // nothing
    } else {
      (controller.currentItem.holder as ImageEditionBaseHolder).onResetClick();
    }
  }
}
