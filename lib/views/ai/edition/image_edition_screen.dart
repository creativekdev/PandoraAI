import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/models/enums/image_edition_function.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/li_pop_menu.dart';
import 'package:cartoonizer/views/ai/edition/controller/image_edition_controller.dart';
import 'package:cartoonizer/views/ai/edition/widget/adjust_options.dart';
import 'package:cartoonizer/views/ai/edition/widget/filter_options.dart';
import 'package:cartoonizer/views/mine/filter/Filter.dart';
import 'package:cartoonizer/views/transfer/controller/both_transfer_controller.dart';

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
    switch (controller.currentFunction) {
      case ImageEditionFunction.adjust:
        return controller.adjustController.resultBytes != null ? Image.memory(controller.adjustController.resultBytes!) : Container();
      case ImageEditionFunction.effect:
      case ImageEditionFunction.filter:
      case ImageEditionFunction.crop:
      case ImageEditionFunction.removeBg:
        return Image.file(
          controller.showOrigin ? controller.originFile : controller.resultFile ?? controller.originFile,
          fit: BoxFit.contain,
        );
      case ImageEditionFunction.UNDEFINED:
        return Container();
    }
  }

  Widget buildRightTab(BuildContext context, ImageEditionController controller) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Column(
          children: controller.functions.map((e) {
            bool visible = true;
            if (e == ImageEditionFunction.removeBg) {
              visible = controller.effectController.resultFile == null;
            }
            return Image.asset(
              e.icon(),
              width: $(24),
              height: $(24),
            )
                .intoContainer(
                  padding: EdgeInsets.all($(8)),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular($(32)),
                      gradient: controller.currentFunction == e
                          ? LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: const [Color(0xFF68F0AF), Color(0xFF05E0D5)])
                          : null),
                )
                .intoGestureDetector(onTap: () {
                  if (e == ImageEditionFunction.filter) {
                    controller.filterController.currentFunction = FilterEnum.NOR;
                    controller.currentFunction = e;
                  } else if (e == ImageEditionFunction.crop) {
                    if (controller.cropFilePath == null) {
                      //todo 裁减图片，然后切换tab
                    } else {
                      controller.currentFunction = e;
                    }
                  } else if (e == ImageEditionFunction.removeBg) {
                    if (controller.removedBgPath == null) {
                      // todo 去除背景，然后切换tab
                    } else {
                      controller.currentFunction = e;
                    }
                  } else {
                    controller.currentFunction = e;
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
    switch (controller.currentFunction) {
      case ImageEditionFunction.effect:
        return EffectOptions(
          imageEditionController: controller,
          photoType: widget.photoType,
          source: widget.source,
        );
      case ImageEditionFunction.filter:
        if (controller.filterController.originFilePath == null) {
          controller.filterController.originFilePath = controller.effectController.resultFile?.path ?? controller.resultFilePath ?? controller.originFile.path;
        }
        return FilterOptions(
          imageEditionController: controller,
          parentState: this,
        );
      case ImageEditionFunction.adjust:
        if (controller.adjustController.originFilePath == null) {
          controller.adjustController.originFilePath = controller.effectController.resultFile?.path ?? controller.resultFilePath ?? controller.originFile.path;
        }
        return AdjustOptions(imageEditionController: controller);
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
