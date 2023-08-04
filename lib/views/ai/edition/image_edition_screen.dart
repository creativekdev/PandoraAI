import 'dart:convert';
import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/li_pop_menu.dart';
import 'package:cartoonizer/views/ai/edition/controller/filter_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/ie_base_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/image_edition_controller.dart';
import 'package:cartoonizer/views/ai/edition/widget/adjust_options.dart';
import 'package:cartoonizer/views/ai/edition/widget/filter_options.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';
import 'package:cartoonizer/views/transfer/controller/both_transfer_controller.dart';
import 'package:cartoonizer/views/transfer/controller/transfer_base_controller.dart';

import '../../../Common/Extension.dart';
import '../../../app/app.dart';
import '../../../app/thirdpart/thirdpart_manager.dart';
import '../../../app/user/user_manager.dart';
import '../../../utils/img_utils.dart';
import '../../share/ShareScreen.dart';
import 'widget/effect_options.dart';

class ImageEditionScreen extends StatefulWidget {
  String source;
  String filePath;
  String? initKey;
  EffectStyle style;
  String photoType;

  ImageEditionScreen({
    super.key,
    required this.source,
    required this.filePath,
    required this.initKey,
    required this.style,
    required this.photoType,
  });

  @override
  State<ImageEditionScreen> createState() => _ImageEditionScreenState();
}

class _ImageEditionScreenState extends AppState<ImageEditionScreen> {
  late ImageEditionController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ImageEditionController(originPath: widget.filePath, effectStyle: widget.style));
  }

  saveToAlbum() async {
    if (controller.currentItem.function == ImageEditionFunction.effect) {
      BothTransferController effectHolder = controller.currentItem.holder;
      await GallerySaver.saveImage(effectHolder.resultFile!.path, albumName: saveAlbumName);
    } else {
      ImageEditionBaseHolder holder = controller.currentItem.holder;
      await GallerySaver.saveImage(holder.resultFile!.path, albumName: saveAlbumName);
    }
    CommonExtension().showImageSavedOkToast(context);
  }

  shareToDiscovery() {
    //todo
  }

  shareOut() async {
    AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
    var userManager = AppDelegate().getManager<UserManager>();
    var uint8list;
    if (controller.currentItem.function == ImageEditionFunction.effect) {
      BothTransferController effectHolder = controller.currentItem.holder;
      uint8list = await ImageUtils.printStyleMorphDrawData(effectHolder.resultFile!, File(effectHolder.resultFile!.path), '@${userManager.user?.getShownName() ?? 'Pandora User'}');
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
    super.dispose();
  }

  PreferredSizeWidget? buildNavigationBar(BuildContext context) {
    return AppNavigationBar(
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
    return GetBuilder<ImageEditionController>(
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
    );
  }

  Widget buildContent(BuildContext context, ImageEditionController controller) {
    return Stack(
      fit: StackFit.expand,
      children: [
        getImageWidget(context, controller),
        Align(
          alignment: Alignment.centerRight,
          child: buildRightTab(context, controller),
        ),
      ],
    );
  }

  Widget getImageWidget(BuildContext context, ImageEditionController controller) {
    if (controller.currentItem.function == ImageEditionFunction.UNDEFINED) {
      return Container();
    }
    if (controller.currentItem.function == ImageEditionFunction.effect) {
      var effectController = controller.currentItem.holder as TransferBaseController;
      return Image.file(controller.showOrigin ? effectController.originFile : effectController.resultFile ?? effectController.originFile);
    } else {
      var holder = controller.currentItem.holder as ImageEditionBaseHolder;
      return Image.file(controller.showOrigin ? holder.originFile! : holder.resultFile ?? holder.originFile!);
    }
  }

  Widget buildRightTab(BuildContext context, ImageEditionController controller) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: controller.items.map((e) {
            bool visible = true;
            if (e.function == ImageEditionFunction.removeBg) {
              //  visible = controller.effectController.resultFile == null;
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
                  if (controller.currentItem.function == ImageEditionFunction.effect) {
                    //点击的是effect，
                    if (e.function == ImageEditionFunction.effect) {
                      //重复点击，不处理
                    } else {
                      //不是的话，需要切换数据，把图从effectController中搬到新的holder里。
                      var newHolder = e.holder as ImageEditionBaseHolder;
                      var effectController = controller.currentItem.holder as TransferBaseController;
                      newHolder.setOriginFilePath((effectController.resultFile ?? controller.originFile).path);
                      controller.currentItem = e;
                    }
                  } else {
                    //其他类型
                    if (e.function == controller.currentItem.function) {
                      //重复点击，看功能处理
                    } else {
                      //切换回effect，目前不处理
                      if (e.function == ImageEditionFunction.effect) {
                        //  应该需要换原图，然后重新生成，待确认。
                      } else {
                        //不是的话，需要切换数据，把图从oldHolder中搬到newHolder里。
                        if (e.function == ImageEditionFunction.filter) {
                          (e.holder as FilterHolder).currentFunction = FilterEnum.NOR;
                        }
                        var newHolder = e.holder as ImageEditionBaseHolder;
                        var oldHolder = controller.currentItem.holder as ImageEditionBaseHolder;
                        newHolder.setOriginFilePath((oldHolder.resultFile ?? oldHolder.originFile!).path);
                      }
                      controller.currentItem = e;
                    }
                  }
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
    ).intoContainer(margin: EdgeInsets.only(right: $(10)));
  }

  Widget buildOptions(BuildContext context, ImageEditionController controller) {
    switch (controller.currentItem.function) {
      case ImageEditionFunction.effect:
        return EffectOptions(
          controller: controller.currentItem.holder,
          photoType: widget.photoType,
          source: widget.source,
        );
      case ImageEditionFunction.filter:
        return FilterOptions(
          controller: controller.currentItem.holder,
          parentState: this,
        );
      case ImageEditionFunction.adjust:
        return AdjustOptions(controller: controller.currentItem.holder);
      case ImageEditionFunction.crop:
        return Container();
      case ImageEditionFunction.removeBg:
        return Container();
      case ImageEditionFunction.UNDEFINED:
        break;
    }
    return Container();
  }
}
