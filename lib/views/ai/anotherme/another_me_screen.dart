import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Common/photo_introduction_config.dart';
import 'package:cartoonizer/Controller/upload_image_controller.dart';
import 'package:cartoonizer/Widgets/camera/app_camera.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album.dart';
import 'package:cartoonizer/Widgets/gallery/pick_album_helper.dart';
import 'package:cartoonizer/Widgets/image/medium_image_provider.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_controller.dart';
import 'package:cartoonizer/views/ai/anotherme/another_me_trans_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:photo_gallery/photo_gallery.dart';

import 'anotherme.dart';
import 'widgets/take_photo_button.dart';

class AnotherMeScreen extends StatefulWidget {
  const AnotherMeScreen({Key? key}) : super(key: key);

  @override
  State<AnotherMeScreen> createState() => _AnotherMeScreenState();
}

class _AnotherMeScreenState extends AppState<AnotherMeScreen> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  late double sourceImageSize;
  late double galleryImageSize;
  late double cameraWidth;
  late double cameraHeight;
  AnotherMeController controller = Get.put(AnotherMeController());
  UploadImageController uploadImageController = Get.put(UploadImageController());
  CameraController? cameraController;
  Future<void>? _initializeControllerFuture;
  GlobalKey screenShotKey = GlobalKey();
  bool isFront = true;

  late Axis widgetDirection;

  CameraImage? lastScreenShot;
  int lastScreenShotStamp = 0;
  bool takingPhoto = false;
  late AnimationController _animationController;
  late CurvedAnimation _anim;
  List<String> loadFailedList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _anim = CurvedAnimation(parent: _animationController, curve: Curves.elasticIn);
    sourceImageSize = ScreenUtil.screenSize.width;
    galleryImageSize = ScreenUtil.screenSize.width / 7.5;
    cameraWidth = ScreenUtil.screenSize.width;
    cameraHeight = ScreenUtil.screenSize.height;
    widgetDirection = cameraWidth / cameraHeight > 1 ? Axis.horizontal : Axis.vertical;
    availableCameras().then((value) {
      if (!mounted) {
        return;
      }
      if (value.isEmpty) {
        return;
      }
      var pick = value.pick((t) => t.lensDirection == CameraLensDirection.front) ?? value.first;
      setState(() {
        isFront = pick.lensDirection == CameraLensDirection.front;
        cameraController = CameraController(
          pick,
          ResolutionPreset.medium,
          imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : null,
        );
        _initializeControllerFuture = cameraController!.initialize();
      });
    });
    delay(() {
      controller.initialConfig = anotherMeInitialConfig(context);
    });
  }

  @override
  void dispose() {
    Get.delete<AnotherMeController>();
    Get.delete<UploadImageController>();
    cameraController?.stopImageStream().onError((error, stackTrace) {}).whenComplete(() {
      cameraController?.dispose();
    });
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final CameraController? cc = cameraController;

    // App state changed before we got the chance to initialize.
    if (cc == null || !cc.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cc.dispose();
    } else if (state == AppLifecycleState.resumed) {
      cameraController = CameraController(
        cc.description,
        ResolutionPreset.medium,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : null,
      );
      _initializeControllerFuture = cameraController!.initialize();
      setState(() {});
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstant.BackgroundColor,
      body: Stack(
        children: [
          FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              const defaultWidget = const Center(child: CircularProgressIndicator());
              if (cameraController == null) {
                return defaultWidget;
              }
              if (snapshot.connectionState == ConnectionState.done) {
                lastScreenShotStamp = DateTime.now().millisecondsSinceEpoch;
                if (cameraController != null) {
                  cameraController!.startImageStream((image) {
                    if (takingPhoto) {
                      return;
                    }
                    var currentTime = DateTime.now().millisecondsSinceEpoch;
                    if (currentTime - lastScreenShotStamp > 200) {
                      lastScreenShot = image;
                      lastScreenShotStamp = currentTime;
                    }
                  }).onError((error, stackTrace) {});
                }
                // If the Future is complete, display the preview.
                var ratio = cameraController!.value.aspectRatio;
                var surfaceWidth = cameraHeight / ratio;
                var offsetX = (surfaceWidth - cameraWidth) / 2;
                var surface = cameraController!.buildPreview().intoContainer(
                      width: surfaceWidth,
                      height: cameraHeight,
                    );
                var scrollController = ScrollController(initialScrollOffset: offsetX);
                var view = SingleChildScrollView(
                  child: RepaintBoundary(key: screenShotKey, child: surface),
                  controller: scrollController,
                  physics: NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                );
                return view;
              } else {
                return defaultWidget;
              }
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
                    AnimatedBuilder(
                      animation: _anim,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(-_animationController.value * ScreenUtil.screenSize.width, 0),
                          child: child,
                        );
                      },
                      child: galleryContainer(context, controller),
                    ),
                    SizedBox(height: $(16)),
                    AnimatedBuilder(
                      animation: _anim,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _animationController.value * $(80)),
                          child: child,
                        );
                      },
                      child: Row(
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
                              if (_animationController.isAnimating) {
                                return;
                              }
                              takePhoto().then((value) {
                                if (value != null) {
                                  _animationController.forward();
                                  delay(() => startTransfer(context, value.value, value.key), milliseconds: 300);
                                } else {
                                  CommonExtension().showToast('Take Photo Failed');
                                }
                              });
                            },
                            onTakeVideoEnd: () {
                              // cameraController.stopTakeVideo();
                            },
                            onTakeVideoStart: () async {
                              // cameraController.takeVideo(maxDuration: 8).then((value) {
                              //   print(value);
                              // });
                              return true;
                            },
                            maxSecond: 8,
                          ),
                          Image.asset(
                            Images.ic_camera_switch,
                            width: 44,
                            height: 44,
                          ).intoContainer(width: 44, height: 44, decoration: BoxDecoration(color: Color(0x88000000), borderRadius: BorderRadius.circular(32))).intoGestureDetector(
                              onTap: () {
                            switchCamera();
                          }),
                        ],
                      ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
                    ),
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
                  decoration: BoxDecoration(color: Color(0x38ffffff), borderRadius: BorderRadius.circular(4)))
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
                padding: EdgeInsets.symmetric(vertical: $(6), horizontal: $(6)),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return ClipRRect(
                      child: Image(
                        image: MediumImage(
                          list[index],
                          width: 256,
                          height: 256,
                          failedImageAssets: Images.ic_netimage_failed,
                          onError: (medium) {
                            if (!loadFailedList.contains(medium.id)) {
                              loadFailedList.add(medium.id);
                            }
                          },
                        ),
                        width: galleryImageSize,
                        height: galleryImageSize,
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ).intoGestureDetector(onTap: () async {
                      var medium = list[index];
                      if (loadFailedList.contains(medium.id)) {
                        CommonExtension().showToast(S.of(context).wrong_image);
                        return;
                      }
                      var xFile = XFile((await medium.getFile()).path);
                      var ratio = medium.height! / medium.width!;
                      startTransfer(context, xFile, ratio);
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

  startTransfer(BuildContext context, XFile xFile, double ratio) {
    controller.clear(uploadImageController);
    Navigator.of(context)
        .push<bool>(
      FadeRouter(
          child: AnotherMeTransScreen(
        file: xFile,
        ratio: ratio,
      )),
    )
        .then((value) {
      if (value == null) {
        Navigator.of(context).pop();
      } else {
        _animationController.reverse();
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
        var medium = value.first;
        var xFile = XFile((await medium.getFile()).path);
        startTransfer(context, xFile, medium.height! / medium.width!);
      }
    });
  }

  switchCamera() {
    cameraController?.stopImageStream().whenComplete(() {
      cameraController?.dispose().whenComplete(() {
        availableCameras().then((value) {
          var pick = value.pick((t) => isFront ? t.lensDirection != CameraLensDirection.front : t.lensDirection == CameraLensDirection.front) ?? value.first;
          setState(() {
            isFront = pick.lensDirection == CameraLensDirection.front;
            cameraController = CameraController(
              pick,
              ResolutionPreset.medium,
              imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : null,
            );
            _initializeControllerFuture = cameraController!.initialize();
          });
        });
      });
    }).onError((error, stackTrace) {});
  }

  Future<MapEntry<double, XFile>?> takePhoto() async {
    if (lastScreenShot == null) {
      return null;
    }
    if (takingPhoto) {
      return null;
    }
    takingPhoto = true;
    var list = await convertImagetoPng(isFront, lastScreenShot!, widgetDirection);
    if (list == null) {
      takingPhoto = false;
      return null;
    }
    var operator = AppDelegate.instance.getManager<CacheManager>().storageOperator;
    String filePath = '${operator.imageDir.path}${DateTime.now().millisecondsSinceEpoch}.png';
    var uint8list = Uint8List.fromList(list);
    var imageInfo = (await SyncMemoryImage(list: uint8list).getImage()).image;
    double ratio = cameraHeight / cameraWidth;
    double canvasRatio = imageInfo.height / imageInfo.width;
    Rect rect;
    if (ratio > canvasRatio) {
      var newWidth = imageInfo.height / ratio;
      var d = (newWidth - imageInfo.width).abs() / 2;
      rect = Rect.fromLTWH(d, 0, newWidth, imageInfo.height.toDouble());
    } else {
      var newHeight = imageInfo.width / ratio;
      var d = (newHeight - imageInfo.height).abs() / 2;
      rect = Rect.fromLTWH(0, d, imageInfo.width.toDouble(), newHeight);
    }
    File file = await cropFileToTarget(
      imageInfo,
      rect,
      filePath,
    );
    takingPhoto = false;
    return MapEntry(ratio, XFile(file.path));
  }
}
