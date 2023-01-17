import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Common/photo_introduction_config.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/camera/app_camera.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album_helper.dart';
import 'package:cartoonizer/Widgets/image/medium_image_provider.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_controller.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_trans_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_gallery/photo_gallery.dart';

import 'anotherme.dart';
import 'widgets/take_photo_button.dart';

class AnotherMeScreen extends StatefulWidget {
  const AnotherMeScreen({Key? key}) : super(key: key);

  @override
  State<AnotherMeScreen> createState() => _AnotherMeScreenState();
}

class _AnotherMeScreenState extends AppState<AnotherMeScreen> {
  late double sourceImageSize;
  late double galleryImageSize;
  late double cameraWidth;
  late double cameraHeight;
  AnotherMeController controller = Get.put(AnotherMeController());
  UploadImageController uploadImageController = Get.put(UploadImageController());
  late AppCameraController cameraController;

  @override
  void initState() {
    super.initState();
    sourceImageSize = ScreenUtil.screenSize.width;
    galleryImageSize = ScreenUtil.screenSize.width / 7.5;
    cameraWidth = ScreenUtil.screenSize.width;
    cameraHeight = ScreenUtil.screenSize.height;
    delay(() {
      controller.initialConfig = anotherMeInitialConfig(context);
    });
  }

  @override
  void dispose() {
    Get.delete<AnotherMeController>();
    Get.delete<UploadImageController>();
    super.dispose();
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: Stack(
        children: [
          AppCamera(
            width: cameraWidth,
            height: cameraHeight,
            onCreate: (c) {
              cameraController = c;
              controller.viewInit = true;
            },
          ).hero(tag: AnotherMe.takeItemTag),
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
            bottom: ScreenUtil.getBottomPadding(context) + 10,
            child: GetBuilder<AnotherMeController>(
              init: controller,
              builder: (controller) {
                return Column(
                  children: [
                    galleryContainer(context, controller),
                    SizedBox(height: $(16)),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 50,
                          height: 50,
                        ),
                        TakePhotoButton(
                          size: $(68),
                          onTakePhoto: () {
                            cameraController.takePhoto().then((value) {
                              if (value != null) {
                                startTransfer(context, value);
                              } else {
                                CommonExtension().showToast('Take Photo Failed');
                              }
                            });
                          },
                          onTakeVideoEnd: () {
                            cameraController.stopTakeVideo();
                          },
                          onTakeVideoStart: () async {
                            cameraController.takeVideo(maxDuration: 8).then((value) {
                              print(value);
                            });
                            return true;
                          },
                          maxSecond: 8,
                        ),
                        Image.asset(
                          Images.ic_camera_switch,
                          width: 50,
                          height: 50,
                        ).intoContainer(width: 50, height: 50, decoration: BoxDecoration(color: Color(0x88000000), borderRadius: BorderRadius.circular(32))).intoGestureDetector(
                            onTap: () {
                          cameraController.switchCamera();
                        }),
                      ],
                    ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
                  ],
                ).intoContainer(
                  width: ScreenUtil.screenSize.width,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget galleryContainer(BuildContext context, AnotherMeController controller) => Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Icon(
            Icons.add,
            size: $(28),
            color: ColorConstant.White,
          )
              .intoContainer(
                  alignment: Alignment.center,
                  width: galleryImageSize,
                  height: galleryImageSize,
                  margin: EdgeInsets.all($(6)),
                  decoration: BoxDecoration(color: Color(0x55ffffff), borderRadius: BorderRadius.circular(4)))
              .intoGestureDetector(onTap: () {
            choosePhoto(context, controller);
          }),
          Container(
            height: galleryImageSize,
            width: 2,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.black),
          ),
          FutureBuilder<List<Medium>>(
            builder: (context, snap) {
              var list = snap.data ?? [];
              return Container(
                width: ScreenUtil.screenSize.width - 2 - galleryImageSize - $(28),
                height: galleryImageSize + $(12),
                padding: EdgeInsets.symmetric(vertical: $(6)),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: $(6)),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      child: Image(
                        image: MediumImage(list[index], width: 256, height: 256),
                        width: galleryImageSize,
                        height: galleryImageSize,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ).intoGestureDetector(onTap: () async {
                      var medium = list[index];
                      var xFile = XFile((await medium.getFile()).path);
                      startTransfer(context, xFile);
                    }).intoContainer(margin: EdgeInsets.only(left: index == 0 ? 0 : $(6)));
                  },
                  itemCount: list.length,
                ),
              );
            },
            future: PickAlbumHelper.getNewest(),
          ),
        ],
      ).intoContainer(
          width: ScreenUtil.screenSize.width - $(16),
          margin: EdgeInsets.symmetric(horizontal: $(8)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Color(0x88010101),
          ));

  startTransfer(BuildContext context, XFile xFile) {
    controller.clear(uploadImageController);
    Navigator.of(context)
        .push<bool>(
      FadeRouter(child: AnotherMeTransScreen(file: xFile)),
    )
        .then((value) {
      if (value == null) {
        Navigator.of(context).pop();
      }
    });
  }

  choosePhoto(BuildContext context, AnotherMeController controller) async {
    PickAlbumScreen.pickImage(
      context,
      count: 1,
      switchAlbum: true,
    ).then((value) async {
      if (value != null && value.isNotEmpty) {
        var xFile = XFile((await value.first.getFile()).path);
        startTransfer(context, xFile);
      }
    });
  }
}
