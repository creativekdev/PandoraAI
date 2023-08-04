import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/li_pop_menu.dart';
import 'package:cartoonizer/views/ai/edition/controller/adjust_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/filter_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/ie_base_holder.dart';
import 'package:cartoonizer/views/ai/edition/controller/image_edition_controller.dart';
import 'package:cartoonizer/views/ai/edition/controller/remove_bg_holder.dart';
import 'package:cartoonizer/views/ai/edition/widget/adjust_options.dart';
import 'package:cartoonizer/views/ai/edition/widget/crop_options.dart';
import 'package:cartoonizer/views/ai/edition/widget/filter_options.dart';
import 'package:cartoonizer/views/ai/edition/widget/remove_bg_options.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';
import 'package:cartoonizer/views/mine/filter/im_remove_bg_screen.dart';
import 'package:cartoonizer/views/transfer/controller/both_transfer_controller.dart';
import 'package:cartoonizer/views/transfer/controller/transfer_base_controller.dart';

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

  saveToAlbum() {
    //todo
  }

  shareToDiscovery() {
    //todo
  }

  shareOut() {
    //todo
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
    } else if (controller.currentItem.function == ImageEditionFunction.removeBg) {
      var holder = controller.currentItem.holder as RemoveBgHolder;
      return Image.file(controller.showOrigin ? holder.originFile! : holder.resultFile ?? holder.removedImage!);
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
                .intoGestureDetector(onTap: () async {
                  if (e.function == controller.currentItem.function) {
                    //重复点击，特殊情况考虑
                  } else {
                    if (e.function == ImageEditionFunction.effect) {
                      //跳转effect
                      controller.currentItem = e;
                      // 不处理
                    } else {
                      String originFilePath;
                      if (controller.currentItem.function == ImageEditionFunction.effect) {
                        // 从effect跳
                        var transferController = controller.currentItem.holder as BothTransferController;
                        originFilePath = (transferController.resultFile ?? transferController.originFile).path;
                      } else {
                        //其他的互相跳转
                        var baseHolder = controller.currentItem.holder as ImageEditionBaseHolder;
                        originFilePath = (baseHolder.resultFile ?? baseHolder.originFile!).path;
                      }
                      if (e.function == ImageEditionFunction.removeBg && (e.holder as RemoveBgHolder).removedImage == null) {
                        var image = await SyncFileImage(file: File(originFilePath)).getImage();
                        Navigator.push(
                          context,
                          NoAnimRouter(
                            ImRemoveBgScreen(
                              filePath: originFilePath,
                              imageRatio: image.image.width / image.image.height,
                              onGetRemoveBgImage: (String path) async {
                                SyncFileImage(file: File(path)).getImage().then((value) {
                                  var holder = e.holder as RemoveBgHolder;
                                  holder.ratio = value.image.width / value.image.height;
                                  holder.removedImage = File(path);
                                });
                              },
                            ),
                            // opaque: true,
                            settings: RouteSettings(name: "/ImRemoveBgScreen"),
                          ),
                        ).then((value) {
                          if (value == true) {
                            var newHolder = e.holder as ImageEditionBaseHolder;
                            newHolder.setOriginFilePath(originFilePath);
                            controller.currentItem = e;
                          }
                        });
                      } else {
                        var newHolder = e.holder as ImageEditionBaseHolder;
                        newHolder.setOriginFilePath(originFilePath);
                        controller.currentItem = e;
                      }
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
        return CropOptions(controller: controller.currentItem.holder);
      case ImageEditionFunction.removeBg:
        return RemoveBgOptions(controller: controller.currentItem.holder);
      case ImageEditionFunction.UNDEFINED:
        break;
    }
    return Container();
  }
}
