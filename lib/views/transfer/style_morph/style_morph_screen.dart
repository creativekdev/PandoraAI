import 'dart:io';

import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:common_utils/common_utils.dart';

import 'style_morph_controller.dart';

class StyleMorphScreen extends StatefulWidget {
  String source;

  String path;

  StyleMorphScreen({
    Key? key,
    required this.source,
    required this.path,
  }) : super(key: key);

  @override
  State<StyleMorphScreen> createState() => _StyleMorphScreenState();
}

class _StyleMorphScreenState extends State<StyleMorphScreen> {
  late String source;
  late StyleMorphController controller;
  late UploadImageController uploadImageController;
  late double itemWidth;

  @override
  void initState() {
    super.initState();
    source = widget.source;
    uploadImageController = Get.put(UploadImageController());
    controller = Get.put(StyleMorphController(originFile: File(widget.path)));
    itemWidth = ScreenUtil.screenSize.width / 6;
  }

  generate() async {
    String key = (await uploadImageController.getCachedId(controller.originFile))!;
    var needUpload = await uploadImageController.needUploadByKey(key);
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
        Events.metaverseCompleteSuccess(photo: 'gallery');
        controller.onSuccess();
      } else {
        controller.onError();
        if (value.error != null) {
          // showLimitDialog(context, value.error!);
        } else {
          Navigator.of(context).pop();
        }
      }
    });
    if (needUpload) {
      File compressedImage = await imageCompressAndGetFile(controller.originFile, imageSize: 768);
      await uploadImageController.uploadCompressedImage(compressedImage);
      if (TextUtil.isEmpty(uploadImageController.imageUrl.value)) {
        simulateProgressBarController.onError();
      } else {
        simulateProgressBarController.uploadComplete();
        var cachedId = await uploadImageController.getCachedIdByKey(key);
        controller.startTransfer(cachedId);
      }
    }
  }

  @override
  void dispose() {
    Get.delete<StyleMorphController>();
    Get.delete<UploadImageController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      appBar: AppNavigationBar(
        backgroundColor: ColorConstant.BackgroundColor,
      ),
      body: GetBuilder<StyleMorphController>(
          builder: (controller) {
            return Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(controller.originFile, fit: BoxFit.fill),
                      Image.file(
                        controller.originFile,
                        fit: BoxFit.contain,
                      ).intoCenter().blur()
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(Images.ic_camera, height: $(24), width: $(24))
                        .intoGestureDetector(
                          onTap: () => pickFromRecent(context),
                        )
                        .intoContainer(padding: EdgeInsets.all($(15))),
                    Image.asset(Images.ic_download, height: $(24), width: $(24))
                        .intoGestureDetector(
                          onTap: () => showSavePhotoDialog(context),
                        )
                        .intoContainer(padding: EdgeInsets.all($(15))),
                    Image.asset(Images.ic_share_discovery, height: $(24), width: $(24))
                        .intoGestureDetector(
                          onTap: () => shareToDiscovery(),
                        )
                        .intoContainer(padding: EdgeInsets.all($(15))),
                  ],
                ),
                ScrollablePositionedList.builder(
                  itemCount: 10,
                  itemBuilder: (context, index) {
                    return SizedBox(
                      width: itemWidth,
                      height: itemWidth,
                      child: Image.asset(Images.ic_signup_cartoon),
                    );
                  },
                  scrollDirection: Axis.horizontal,
                ).intoContainer(height: itemWidth),
                SizedBox(height: ScreenUtil.getBottomPadding(context)),
              ],
            );
          },
          init: Get.find<StyleMorphController>()),
    );
  }

  pickFromRecent(BuildContext context) {}

  showSavePhotoDialog(BuildContext context) {}

  shareToDiscovery() {}
}
