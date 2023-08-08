import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
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
import 'package:cartoonizer/views/mine/filter/im_remove_bg_screen.dart';
import 'package:cartoonizer/views/transfer/controller/all_transfer_controller.dart';
import 'package:cartoonizer/views/transfer/controller/transfer_base_controller.dart';
import 'package:common_utils/common_utils.dart';
import 'package:posthog_flutter/posthog_flutter.dart';

import '../../../Common/Extension.dart';
import '../../../app/app.dart';
import '../../../app/thirdpart/thirdpart_manager.dart';
import '../../../app/user/user_manager.dart';
import '../../../utils/img_utils.dart';
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

  ImageEditionScreen({
    super.key,
    required this.source,
    required this.filePath,
    required this.initKey,
    required this.style,
    required this.photoType,
    required this.initFunction,
    required this.recentEffectItems,
  });

  @override
  State<ImageEditionScreen> createState() => _ImageEditionScreenState();
}

class _ImageEditionScreenState extends AppState<ImageEditionScreen> {
  late ImageEditionController controller;
  Rx<bool> titleShow = false.obs;
  late StreamSubscription onRightTitleSwitchEvent;
  late TimerUtil timer;

  @override
  void initState() {
    super.initState();
    Posthog().screenWithUser(screenName: 'image_edition_screen');
    controller = Get.put(ImageEditionController(
      originPath: widget.filePath,
      effectStyle: widget.style,
      initFunction: widget.initFunction,
      initKey: widget.initKey,
      photoType: widget.photoType,
      source: widget.source,
      recentItemList: widget.recentEffectItems,
    ));
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
      titleShow.value = true;
      timer.startTimer();
    });
  }

  saveToAlbum() async {
    if (controller.currentItem.function == ImageEditionFunction.effect) {
      AllTransferController effectHolder = controller.currentItem.holder;
      await GallerySaver.saveImage(effectHolder.resultFile!.path, albumName: saveAlbumName);
    } else {
      ImageEditionBaseHolder holder = controller.currentItem.holder;
      await GallerySaver.saveImage(holder.resultFile!.path, albumName: saveAlbumName);
    }
    CommonExtension().showImageSavedOkToast(context);
  }

  shareToDiscovery() {
    CommonExtension().showToast('还需要和web端对一下配置，不然可能会影响web端');
    //todo
  }

  shareOut() async {
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
    var userManager = AppDelegate().getManager<UserManager>();
    var uint8list;
    if (controller.currentItem.function == ImageEditionFunction.effect) {
      AllTransferController effectHolder = controller.currentItem.holder;
      if (effectHolder.getCategory() == 'cartoonize') {
        uint8list =
            await ImageUtils.printCartoonizeDrawData(effectHolder.resultFile!, File(effectHolder.resultFile!.path), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
      } else if (effectHolder.getCategory() == 'stylemorph') {
        uint8list =
            await ImageUtils.printStyleMorphDrawData(effectHolder.resultFile!, File(effectHolder.resultFile!.path), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
      } else {
        throw Exception('未定义的effectStyle');
      }
    } else {
      ImageEditionBaseHolder holder = controller.currentItem.holder;
      uint8list = await ImageUtils.printStyleMorphDrawData(holder.resultFile!, File(holder.resultFile!.path), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
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
              appBar: buildNavigationBar(context),
              body: Column(
                children: [
                  Expanded(child: buildContent(context, controller)),
                  buildOptions(context, controller).intoContainer(padding: EdgeInsets.only(top: $(20)), height: $(140) + ScreenUtil.getBottomPadding(context)),
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
        getImageWidget(context, controller).hero(tag: ImageEdition.TagImageEditView),
        Align(
          alignment: Alignment.centerRight,
          child: buildRightTab(context, controller),
        ),
        Align(
          alignment: Alignment.center,
          child: Obx(
            () => Text(
              controller.currentItem.function.title(),
              style: TextStyle(color: Color(0xfff9f9f9), fontSize: $(18)),
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
    if (controller.currentItem.function == ImageEditionFunction.effect || controller.currentItem.function == ImageEditionFunction.sticker) {
      var effectController = controller.currentItem.holder as TransferBaseController;
      return Image.file(controller.showOrigin ? effectController.originFile : effectController.resultFile ?? effectController.originFile);
    } else {
      return controller.showOrigin ? Image.file(controller.originFile) : (controller.currentItem.holder as ImageEditionBaseHolder).buildShownImage();
    }
  }

  Widget buildRightTab(BuildContext context, ImageEditionController controller) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: controller.items.map((e) {
            bool visible = true;
            if (e.function == ImageEditionFunction.removeBg) {
              var effectItem = controller.items.pick((t) => t.function == ImageEditionFunction.effect);
              bool effectVisible = true;
              if (effectItem != null) {
                var c = effectItem.holder as TransferBaseController;
                visible = c.resultFile == null;
              }
              bool stickerVisible = true;
              var stickerItem = controller.items.pick((t) => t.function == ImageEditionFunction.sticker);
              if (stickerItem != null) {
                var c = stickerItem.holder as TransferBaseController;
                stickerVisible = c.resultFile == null;
              }
              visible = effectVisible && stickerVisible;
            }
            return Image.asset(
              e.function.icon(),
              width: $(24),
              height: $(24),
            )
                .intoContainer(
                  padding: EdgeInsets.all($(8)),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular($(32)),
                      gradient: controller.currentItem == e
                          ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: const [Color(0xFF68F0AF), Color(0xFF05E0D5)])
                          : null),
                )
                .intoGestureDetector(onTap: () {
                  controller.onRightTabClick(context, e);
                })
                .intoContainer(margin: EdgeInsets.symmetric(vertical: $(2)))
                .visibility(visible: visible);
          }).toList(),
        ).intoContainer(
          padding: EdgeInsets.symmetric(horizontal: $(4), vertical: $(4)),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular($(32)), color: Color(0x88000000)),
        ),
        SizedBox(height: $(50)),
        Image.asset(Images.ic_switch_images, width: $(24), height: $(24))
            .intoContainer(
          padding: EdgeInsets.all($(8)),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular($(32)), color: Color(0x88000000)),
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
    ).intoContainer(margin: EdgeInsets.only(right: $(10))).listenSizeChanged(onSizeChanged: (size) {
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
      case ImageEditionFunction.sticker:
        return StickerOptions(
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
          controller: controller.currentItem.holder,
          bottomPadding: controller.bottomHeight + ScreenUtil.getBottomPadding(Get.context!),
          switchButtonPadding: controller.switchButtonBottomToScreen,
        );
      case ImageEditionFunction.UNDEFINED:
        break;
    }
    return Container();
  }
}
