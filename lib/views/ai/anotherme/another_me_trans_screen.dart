import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/storage_operator.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/gallery_saver.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_controller.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/trans_result_card.dart';
import 'package:cartoonizer/views/share/ShareScreen.dart';
import 'package:cartoonizer/views/share/share_discovery_screen.dart';
import 'package:common_utils/common_utils.dart';

import 'anotherme.dart';
import 'widgets/am_opt_container.dart';

class AnotherMeTransScreen extends StatefulWidget {
  XFile file;

  AnotherMeTransScreen({
    Key? key,
    required this.file,
  }) : super(key: key);

  @override
  State<AnotherMeTransScreen> createState() => _AnotherMeTransScreenState();
}

class _AnotherMeTransScreenState extends State<AnotherMeTransScreen> {
  late XFile file;
  AnotherMeController controller = Get.find();
  UploadImageController uploadImageController = Get.find();
  late TransResultController transResultController;

  @override
  void initState() {
    super.initState();
    file = widget.file;
    delay(() {
      generate(context, controller);
    });
  }

  void generate(BuildContext context, AnotherMeController controller) {
    SimulateProgressBarController simulateProgressBarController = SimulateProgressBarController();
    SimulateProgressBar.startLoading(context, controller: simulateProgressBarController).then((value) {
      controller.update();
      if (!TextUtil.isEmpty(controller.transKey)) {
        transResultController.bindData(File(controller.transKey!));
        transResultController.showResult();
      }
    });
    controller.onTakePhoto(file, uploadImageController).then((value) {
      if (value) {
        controller.startTransfer(uploadImageController.imageUrl.value).then((value) {
          simulateProgressBarController.loadComplete();
        });
      } else {
        simulateProgressBarController.loadComplete();
      }
    });
  }

  @override
  Widget build(BuildContext context) => GetBuilder<AnotherMeController>(
        init: controller,
        builder: (controller) {
          return Scaffold(
            backgroundColor: ColorConstant.BackgroundColor,
            body: Stack(
              children: [
                TransResultCard(
                  originalImage: File(file.path),
                  onCreate: (c) {
                    transResultController = c;
                  },
                  width: ScreenUtil.screenSize.width,
                  height: ScreenUtil.screenSize.height,
                ),
                Image.asset(
                  Images.ic_back,
                  height: $(24),
                  width: $(24),
                )
                    .intoContainer(
                      padding: EdgeInsets.all($(10)),
                      margin: EdgeInsets.only(top: ScreenUtil.getStatusBarHeight(), left: $(5)),
                    )
                    .hero(tag: AnotherMe.logoBackTag)
                    .intoGestureDetector(onTap: () {
                  Navigator.pop(context);
                }),
                Positioned(
                  child: AMOptContainer(
                    onChoosePhotoTap: () {
                      controller.clear(uploadImageController);
                      Navigator.of(context).pop(true);
                    },
                    onDownloadTap: () async {
                      if (TextUtil.isEmpty(controller.transKey)) {
                        return;
                      }
                      var file = File(controller.transKey!);
                      await GallerySaver.saveImage(file.path, albumName: saveAlbumName);
                      CommonExtension().showImageSavedOkToast(context);
                    },
                    onGenerateAgainTap: () {
                      controller.clearTransKey();
                      transResultController.showOriginal();
                      generate(context, controller);
                    },
                    onShareDiscoveryTap: () {
                      if (TextUtil.isEmpty(controller.transKey)) {
                        return;
                      }
                      var file = File(controller.transKey!);
                      ShareDiscoveryScreen.push(
                        context,
                        effectKey: 'Me-taverse',
                        originalUrl: uploadImageController.imageUrl.value,
                        image: base64Encode(file.readAsBytesSync()),
                        isVideo: false,
                        category: DiscoveryCategory.another_me,
                      ).then((value) {
                        if (value ?? false) {
                          showShareSuccessDialog(context);
                        }
                      });
                    },
                    onShareTap: () {
                      if (TextUtil.isEmpty(controller.transKey)) {
                        return;
                      }
                      var file = File(controller.transKey!);
                      AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = true;
                      ShareScreen.startShare(
                        context,
                        backgroundColor: Color(0x77000000),
                        style: 'Me-taverse',
                        image: base64Encode(file.readAsBytesSync()),
                        isVideo: false,
                        originalUrl: null,
                        effectKey: 'Me-taverse',
                      );
                      AppDelegate.instance.getManager<ThirdpartManager>().adsHolder.ignore = false;
                    },
                  ),
                  bottom: ScreenUtil.getBottomPadding(context, padding: 32),
                )
              ],
            ),
          );
        },
      );
}
