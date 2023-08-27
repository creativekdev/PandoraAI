import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/recent/recent_controller.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/background_card.dart';
import 'package:cartoonizer/Widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/Widgets/skeletons.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
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
import 'package:common_utils/common_utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';
import 'package:skeletons/skeletons.dart';

import '../../../Common/Extension.dart';
import '../../../app/app.dart';
import '../../../app/thirdpart/thirdpart_manager.dart';
import '../../../app/user/user_manager.dart';
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

  ImageEditionScreen({
    super.key,
    required this.source,
    required this.filePath,
    required this.initKey,
    required this.style,
    required this.photoType,
    required this.initFunction,
    required this.recentEffectItems,
    required this.adjustData,
    required this.filter,
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

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'image_edition_screen');
    imageSize = Size(ScreenUtil.screenSize.width,
        ScreenUtil.screenSize.height - (kNavBarPersistentHeight + ScreenUtil.getStatusBarHeight() + $(140) + ScreenUtil.getBottomPadding(Get.context!)));
    controller = Get.put(ImageEditionController(
      originPath: widget.filePath,
      effectStyle: widget.style,
      initFunction: widget.initFunction,
      initKey: widget.initKey,
      photoType: widget.photoType,
      source: widget.source,
      recentItemList: widget.recentEffectItems,
      imageContainerSize: imageSize,
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
  }

  @override
  onBlankTap() {
    EventBusHelper().eventBus.fire(OnHideDeleteStatusEvent());
  }

  saveToAlbum() async {
    await showLoading();
    if (controller.currentItem.function == ImageEditionFunction.effect) {
      TransferBaseController effectHolder = controller.currentItem.holder;
      String path = (effectHolder.resultFile ?? effectHolder.originFile).path;
      await GallerySaver.saveImage(path.replaceFirst('.jpg', '.png'), albumName: saveAlbumName);
    } else {
      var holder = controller.currentItem.holder as ImageEditionBaseHolder;
      holder.saveToResult().then((value) async {
        var recentController = Get.find<RecentController>();
        var filtersHolder = controller.filtersHolder;
        recentController.onImageEditionUsed(
          controller.originFile.path,
          value,
          filtersHolder.filterOperator.currentFilter,
          filtersHolder.adjustOperator.adjustList
                  .map((e) => RecentAdjustData()
                    ..mAdjustFunction = e.function
                    ..value = e.value)
                  .toList() ??
              [],
          [],
        );
        hideLoading();
        await GallerySaver.saveImage(value, albumName: saveAlbumName);
      });
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
      resultPath = await holder.saveToResult();
    }
    if (TextUtil.isEmpty(resultPath)) {
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
      resultPath = await holder.saveToResult();
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
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
    var userManager = AppDelegate().getManager<UserManager>();
    var uint8list;
    if (controller.currentItem.function == ImageEditionFunction.effect) {
      TransferBaseController effectHolder = controller.currentItem.holder;
      if (effectHolder.resultFile != null) {
        if (effectHolder.getCategory() == 'cartoonize') {
          uint8list =
              await ImageUtils.printCartoonizeDrawData(effectHolder.originFile!, File(effectHolder.resultFile!.path), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
        } else if (effectHolder.getCategory() == 'stylemorph') {
          uint8list =
              await ImageUtils.printStyleMorphDrawData(effectHolder.originFile!, File(effectHolder.resultFile!.path), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
        } else {
          throw Exception('未定义的effectStyle');
        }
      } else {
        uint8list = await effectHolder.originFile!.readAsBytes();
      }
    } else {
      var holder = controller.currentItem.holder as ImageEditionBaseHolder;
      var s = await holder.saveToResult();
      uint8list = await File(s).readAsBytes();
    }
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
    super.dispose();
  }

  PreferredSizeWidget? buildNavigationBar(BuildContext context) {
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
  Widget buildLoadingWidget(BuildContext context) {
    return SkeletonTheme(
      themeMode: ThemeMode.dark,
      shimmerGradient: LinearGradient(
        colors: [
          Color(0xFFD8E3E7),
          Color(0xFFC8D5DA),
          Color(0xFFD8E3E7),
        ],
        stops: [0.1, 0.5, 0.9],
      ),
      darkShimmerGradient: LinearGradient(
        colors: [
          Color(0x22000000),
          Color(0x44000000),
          Color(0x66000000),
          Color(0x44000000),
          Color(0x22000000),
        ],
        stops: [0.0, 0.2, 0.5, 0.8, 1],
        begin: Alignment(-2.4, -0.2),
        end: Alignment(2.4, 0.2),
        tileMode: TileMode.clamp,
      ),
      child: SkeletonLoading(
        style: SkeletonAvatarStyle(width: ScreenUtil.screenSize.width, height: ScreenUtil.screenSize.height),
      ),
    );
  }

  @override
  Widget buildWidget(BuildContext context) {
    return WillPopScope(
        child: GetBuilder<ImageEditionController>(
          builder: (controller) {
            return Scaffold(
              appBar: buildNavigationBar(context),
              body: Column(
                children: [
                  Expanded(child: buildContent(context, controller)),
                  buildOptions(context, controller).intoContainer(padding: EdgeInsets.only(top: $(15)), height: $(140) + ScreenUtil.getBottomPadding(context)),
                ],
              ),
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
        BackgroundCard(
            bgColor: Colors.transparent,
            child: SizedBox(
              width: controller.backgroundCardSize.width,
              height: controller.backgroundCardSize.height,
            )).intoCenter(),
        getImageWidget(context, controller).hero(tag: ImageEdition.TagImageEditView).intoCenter(),
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

  Widget getImageWidget(BuildContext context, ImageEditionController controller) {
    if (controller.currentItem.function == ImageEditionFunction.UNDEFINED) {
      return Container();
    }
    if (controller.currentItem.function == ImageEditionFunction.effect) {
      var effectController = controller.currentItem.holder as AllTransferController;
      bool needGenerateAgain = effectController.selectedEffect?.parent == 'stylemorph' && effectController.resultFile != null;
      var image = Image.file(controller.showOrigin ? effectController.originFile : effectController.resultFile ?? effectController.originFile);
      if (needGenerateAgain) {
        return Stack(
          fit: StackFit.loose,
          children: [
            image,
            Positioned(
              child: generateAgainBtn(context),
              bottom: 0,
            ),
          ],
        );
      } else {
        return image;
      }
    } else if (controller.currentItem.function == ImageEditionFunction.removeBg) {
      var removeBgHolder = controller.currentItem.holder as RemoveBgHolder;
      return controller.showOrigin
          ? Image.file(controller.originFile)
          : removeBgHolder.removedImage == null
              ? Image.file(removeBgHolder.originFile!)
              : removeBgHolder.buildShownImage(imageSize, controller.backgroundCardSize.size);
    } else {
      var baseHolder = controller.currentItem.holder as ImageEditionBaseHolder;
      return controller.showOrigin ? Image.file(baseHolder.originFile!) : controller.buildShownImage(imageSize);
    }
  }

  Widget generateAgainBtn(BuildContext context) {
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
      controller.generate(context, controller.currentItem.holder);
    }).intoContainer(
      width: ScreenUtil.screenSize.width,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: $(8)),
    );
  }

  Widget buildMenus(BuildContext context, ImageEditionController controller) {
    bool canReset = false;
    if (controller.currentItem.function == ImageEditionFunction.effect) {
      canReset = false;
    } else {
      if (controller.currentItem.function == ImageEditionFunction.adjust) {
        canReset = false;
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
