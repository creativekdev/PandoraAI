import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cartoonizer/common/event_bus_helper.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/dialog/dialog_widget.dart';
import 'package:cartoonizer/widgets/gallery/pick_album.dart';
import 'package:cartoonizer/widgets/gallery/pick_album_helper.dart';
import 'package:cartoonizer/widgets/image/medium_image_provider.dart';
import 'package:cartoonizer/widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/common/Extension.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/permissions_util.dart';
import 'package:cartoonizer/utils/sensor_helper.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/anotherme.dart';
import 'package:cartoonizer/views/ai/anotherme/libcopy/camera_controller.dart';
import 'package:cartoonizer/views/ai/anotherme/libcopy/camera_preview.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/rotate_widget.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/take_photo_button.dart';
import 'package:image/image.dart' as imglib;
import 'package:photo_manager/photo_manager.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AppCamera extends StatefulWidget {
  Function(XFile file, double ratio, String source) onTakePhoto;

  AppCamera({
    Key? key,
    required this.onTakePhoto,
  }) : super(key: key);

  @override
  State<AppCamera> createState() => _AppCameraState();
}

class _AppCameraState extends State<AppCamera> with TickerProviderStateMixin, WidgetsBindingObserver {
  late double sourceImageSize;
  late double galleryImageSize;
  late double cameraWidth;
  late double cameraHeight;
  late double appBarHeight;
  late double bottomBarHeight;
  CustomCameraController? cameraController;
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
  double zoomLevel = 1;
  List<AssetEntity> assetList = [];

  late AnimationController _rotateAnimController;

  late PoseState pose;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _anim = CurvedAnimation(parent: _animationController, curve: Curves.elasticIn);
    _rotateAnimController = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    sourceImageSize = ScreenUtil.screenSize.width;
    galleryImageSize = ScreenUtil.screenSize.width / 7.5;
    appBarHeight = 44 + ScreenUtil.getStatusBarHeight();
    bottomBarHeight = $(198);
    cameraWidth = ScreenUtil.screenSize.width;
    cameraHeight = ScreenUtil.screenSize.height - appBarHeight - bottomBarHeight + $(66);
    widgetDirection = cameraWidth / cameraHeight > 1 ? Axis.horizontal : Axis.vertical;
    pose = PoseState.stand;
    availableCameras().then((value) {
      if (!mounted) {
        return;
      }
      if (value.isEmpty) {
        return;
      }
      var pick = value.pick((t) => t.lensDirection == CameraLensDirection.front) ?? value.first;
      initCameraController(pick);
    });
    delay(() {
      accelerometerEvents.listen((AccelerometerEvent event) {
        var nextPose = SensorHelper.getPose(event.x, event.y, event.z);
        if (nextPose != null) {
          if (nextPose != this.pose) {
            if (mounted) {
              EventBusHelper().eventBus.fire(OnPoseStateChangeEvent(data: nextPose));
              setState(() {
                pose = nextPose;
              });
            }
          }
        }
      });
      PickAlbumHelper.getNewest().then((value) {
        setState(() {
          assetList = value;
        });
      });
    });
  }

  @override
  void dispose() {
    cameraController?.stopImageStream().onError((error, stackTrace) {}).whenComplete(() {
      cameraController?.dispose();
    });
    _animationController.dispose();
    _rotateAnimController.dispose();
    accelerometerEvents.listen(null);
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final CustomCameraController? cc = cameraController;

    // App state changed before we got the chance to initialize.
    if (cc == null || !cc.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cc.dispose();
    } else if (state == AppLifecycleState.resumed) {
      initCameraController(cc.description);
    }
  }

  initCameraController(CameraDescription description) {
    cameraController = CustomCameraController(
      description,
      ResolutionPreset.medium,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.yuv420 : null,
    );
    _initializeControllerFuture = cameraController!.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
          case 'CameraAccessDeniedWithoutPrompt':
          case 'CameraAccessRestricted':
            // Handle access errors here.
            break;
          case 'AudioAccessDenied':
          case 'AudioAccessDeniedWithoutPrompt':
          case 'AudioAccessRestricted':
            break;
          default:
            // Handle other errors here.
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned(
          child: FutureBuilder<void>(
            future: _initializeControllerFuture,
            builder: (context, snapshot) {
              var defaultWidget = Center(child: CircularProgressIndicator()).intoContainer(
                width: cameraWidth,
                height: cameraHeight,
              );
              if (cameraController == null) {
                return defaultWidget;
              }
              try {
                if (snapshot.connectionState == ConnectionState.done) {
                  lastScreenShotStamp = DateTime.now().millisecondsSinceEpoch;
                  if (cameraController != null && !cameraController!.disposed()) {
                    cameraController!.startImageStream((image) {
                      if (cameraController?.disposed() ?? true) {
                        return;
                      }
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
                  var ratio = cameraController?.value.aspectRatio ?? cameraHeight / cameraWidth;
                  var surfaceWidth = cameraHeight / ratio;
                  var offsetX = (surfaceWidth - cameraWidth) / 2;
                  var surface = CustomIOSCameraPreview(
                    cameraController!,
                  ).intoCenter().intoContainer(
                        width: surfaceWidth,
                        height: cameraHeight,
                        transform: Matrix4.translationValues(-offsetX, 0, 0),
                        alignment: Alignment.center,
                      );
                  var view = RepaintBoundary(key: screenShotKey, child: surface);
                  return GestureDetector(
                    child: view,
                    onScaleUpdate: (details) {
                      if (cameraController == null || (cameraController?.disposed() ?? true)) {
                        return;
                      }
                      var scale = details.scale;
                      if (scale == 1) {
                        return;
                      }
                      var zoom = zoomLevel;
                      if (scale > 1) {
                        if (zoom == 2) {
                          return;
                        }
                        zoom = zoomLevel + scale * 0.02;
                        if (zoom > 2) {
                          zoom = 2;
                        }
                      } else {
                        if (zoom == 1) {
                          return;
                        }
                        zoom = zoomLevel - scale * 0.02;
                        if (zoom < 1) {
                          zoom = 1;
                        }
                      }
                      if (cameraController != null) {
                        if (!cameraController!.disposed()) {
                          cameraController?.setZoomLevel(zoom).onError((error, stackTrace) {});
                          setState(() {
                            zoomLevel = zoom;
                          });
                        }
                      }
                    },
                  );
                } else {
                  return defaultWidget;
                }
              } on CameraException catch (e) {
                return defaultWidget;
              }
            },
          ),
          top: appBarHeight,
          bottom: bottomBarHeight - $(66),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: RotateWidget(
            pose: pose,
            child: Text(
              '${zoomLevel.toStringAsFixed(1)}x',
              style: TextStyle(color: Colors.white, fontSize: $(13)),
            ),
          )
              .intoContainer(
                  width: $(38),
                  height: $(38),
                  alignment: Alignment.center,
                  margin: EdgeInsets.only(bottom: $(215)),
                  decoration: BoxDecoration(color: Color(0x33000000), border: Border.all(color: Colors.white, width: 1), borderRadius: BorderRadius.circular(32)))
              .intoGestureDetector(onTap: () {
            cameraController?.getMaxZoomLevel().then((value) {
              if (zoomLevel >= min(value, 2)) {
                zoomLevel = 1;
              } else {
                zoomLevel += 0.5;
              }
              if (zoomLevel > 2) {
                zoomLevel = 2;
              }
              cameraController?.setZoomLevel(zoomLevel);
              setState(() {});
            });
          }),
        ),
        Positioned(
          child: Image.asset(
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
          top: 0,
        ),
        Positioned(
          bottom: 0,
          child: Column(
            children: [
              AnimatedBuilder(
                animation: _anim,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(-_animationController.value * ScreenUtil.screenSize.width, 0),
                    child: child,
                  );
                },
                child: galleryContainer(context, widget.onTakePhoto),
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
                            delay(() async => widget.onTakePhoto.call(value.value, value.key, 'camera'), milliseconds: 300);
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
                    RotateWidget(
                      pose: pose,
                      child: Image.asset(
                        Images.ic_camera_switch,
                        width: 44,
                        height: 44,
                      ).intoContainer(width: 44, height: 44, decoration: BoxDecoration(color: Color(0x88000000), borderRadius: BorderRadius.circular(32))).intoGestureDetector(
                          onTap: () {
                        switchCamera();
                      }),
                    ),
                  ],
                ).intoContainer(padding: EdgeInsets.symmetric(horizontal: $(15))),
              ),
            ],
          ).intoContainer(
            width: ScreenUtil.screenSize.width,
            height: bottomBarHeight,
            alignment: Alignment.topCenter,
          ),
        ),
      ],
    );
  }

  Widget galleryContainer(BuildContext context, Function(XFile file, double datio, String source) callback) => Row(
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
            choosePhoto(context, callback);
          }),
          Container(
            height: galleryImageSize,
            width: 2,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(4), color: Colors.black),
          ),
          Container(
            width: ScreenUtil.screenSize.width - 2 - galleryImageSize - $(28),
            height: galleryImageSize + $(12),
            padding: EdgeInsets.symmetric(vertical: $(6), horizontal: $(6)),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return RotateWidget(
                    pose: pose,
                    child: ClipRRect(
                      child: Image(
                        image: MediumImage(
                          assetList[index],
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
                    )).intoGestureDetector(onTap: () async {
                  var medium = assetList[index];
                  var file = await medium.file;
                  if (file == null || loadFailedList.contains(medium.id)) {
                    CommonExtension().showToast(S.of(context).wrong_image);
                    return;
                  }
                  var xFile = XFile((file).path);
                  var imageInfo = await SyncFileImage(file: file).getImage();
                  var ratio = imageInfo.image.height / imageInfo.image.width;
                  widget.onTakePhoto.call(xFile, ratio, 'album');
                }).intoContainer(margin: EdgeInsets.only(left: index == 0 ? 0 : $(6)));
              },
              itemCount: assetList.length,
            ),
          ),
        ],
      ).intoContainer(
          width: ScreenUtil.screenSize.width - $(16),
          margin: EdgeInsets.symmetric(horizontal: $(8)),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: Color(0x88010101),
          ));

  choosePhoto(BuildContext context, Function(XFile file, double ratio, String source) callback) async {
    PermissionsUtil.checkPermissions().then((value) {
      if (value) {
        PickAlbumScreen.pickImage(
          context,
          count: 1,
          switchAlbum: true,
        ).then((value) async {
          if (value != null && value.isNotEmpty) {
            var medium = value.first;
            var file = await medium.file;
            if (file == null) {
              return;
            }
            var xFile = XFile((file).path);
            var imageInfo = await SyncFileImage(file: file).getImage();
            callback.call(xFile, imageInfo.image.height / imageInfo.image.width, 'album');
          }
        });
      } else {
        showPhotoLibraryPermissionDialog(context);
      }
    });
  }

  switchCamera() {
    if (cameraController == null || (cameraController?.disposed() ?? true)) {
      return;
    }
    cameraController?.stopImageStream().whenComplete(() {
      cameraController?.dispose().whenComplete(() {
        availableCameras().then((value) {
          var pick = value.pick((t) => isFront ? t.lensDirection != CameraLensDirection.front : t.lensDirection == CameraLensDirection.front) ?? value.first;
          isFront = pick.lensDirection == CameraLensDirection.front;
          zoomLevel = 1;
          initCameraController(pick);
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
    var list = await convertImagetoPng(isFront, lastScreenShot!, widgetDirection, pose);
    if (list == null) {
      takingPhoto = false;
      return null;
    }
    var operator = AppDelegate.instance.getManager<CacheManager>().storageOperator;
    String filePath = '${operator.imageDir.path}${DateTime.now().millisecondsSinceEpoch}.png';
    var uint8list = Uint8List.fromList(list);
    var imageInfo = (await SyncMemoryImage(list: uint8list).getImage()).image;
    double ratio = cameraHeight / cameraWidth;
    Rect rect;
    rect = ImageUtils.getTargetCoverRect(Size(imageInfo.width.toDouble(), imageInfo.height.toDouble()), Size(cameraWidth, cameraHeight));
    File file = await cropFileToTarget(
      imageInfo,
      rect,
      filePath,
    );
    if (pose != PoseState.stand) {
      var im = (await SyncFileImage(file: file).getImage()).image;
      var bytes = (await im.toByteData())!.buffer.asUint8List();
      var orImg = imglib.Image.fromBytes(im.width, im.height, bytes);
      var resImg = imglib.copyRotate(orImg, pose.coefficient());
      var encodePng = imglib.encodePng(resImg);
      await file.writeAsBytes(encodePng);
      ratio = 1 / ratio;
    }
    takingPhoto = false;
    return MapEntry(ratio, XFile(file.path));
  }
}

/// imgLib -> Image package from https://pub.dartlang.org/packages/image
Future<List<int>?> convertImagetoPng(bool isFront, CameraImage image, Axis widgetDirection, PoseState pose) async {
  try {
    imglib.Image img;
    if (image.format.group == ImageFormatGroup.yuv420) {
      if (Platform.isIOS) {
        img = _convertYUV420(image);
        if (widgetDirection == Axis.vertical) {
          if (img.width > img.height) {
            img = imglib.copyRotate(img, isFront ? 270 : 90);
            if (isFront) {
              img = imglib.flip(img, imglib.Flip.horizontal);
            }
          }
        } else {
          if (img.width < img.height) {
            img = imglib.copyRotate(img, isFront ? 270 : 90);
            if (isFront) {
              img = imglib.flip(img, imglib.Flip.horizontal);
            }
          }
        }
      } else {
        const platform = MethodChannel(PLATFORM_CHANNEL);
        List<int> strides = Int32List(image.planes.length * 2);
        int index = 0;
        // We need to transform the image to Uint8List so that the native code could
        // transform it to byte[]
        List<Uint8List> data = image.planes.map((plane) {
          strides[index] = (plane.bytesPerRow);
          index++;
          strides[index] = (plane.bytesPerPixel)!;
          index++;
          return plane.bytes;
        }).toList();
        Uint8List tempData;
        tempData = await platform.invokeMethod("YUVTransform", {
          'data': data,
          'height': image.height,
          'width': image.width,
          'strides': strides,
          'quality': 100,
          'isVertical': widgetDirection == Axis.vertical,
          'isFront': isFront,
        });
        return tempData.toList();
      }
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      img = _convertBGRA8888(image);
    } else {
      return null;
    }
    if (image.width > image.height) {
      //screen design to por, if is land(width>height), need to rotate
      if (pose == PoseState.leftDumped) {
        img = imglib.copyRotate(img, 90);
      } else if (pose == PoseState.rightDumped) {
        img = imglib.copyRotate(img, 270);
      }
    }
    imglib.PngEncoder pngEncoder = imglib.PngEncoder();
    List<int> png = pngEncoder.encodeImage(img);
    return png;
  } catch (e) {
    print(">>>>>>>>>>>> ERROR:" + e.toString());
  }
  return null;
}

/// CameraImage BGRA8888 -> PNG
/// Color
imglib.Image _convertBGRA8888(CameraImage image) {
  return imglib.Image.fromBytes(
    (image.planes[0].bytesPerRow / 4).round(),
    image.height,
    image.planes[0].bytes,
    format: imglib.Format.bgra,
  );
}

/// CameraImage YUV420_888 -> PNG -> Image (compresion:0, filter: none)
/// Black
imglib.Image _convertYUV420(CameraImage image) {
  final int width = image.width;
  final int height = image.height;
  final int uvRowStride = image.planes[1].bytesPerRow;
  final int uvPixelStride = image.planes[1].bytesPerPixel!;

  // imgLib -> Image package from https://pub.dartlang.org/packages/image
  var img = imglib.Image(width, height); // Create Image buffer

  // Fill image buffer with plane[0] from YUV420_888
  for (int x = 0; x < width; x++) {
    for (int y = 0; y < height; y++) {
      final int uvIndex = uvPixelStride * (x / 2).floor() + uvRowStride * (y / 2).floor();
      final int index = y * width + x;

      final yp = image.planes[0].bytes[index];
      final up = image.planes[1].bytes[uvIndex];
      final vp = image.planes[2].bytes[uvIndex];
      // Calculate pixel color
      int r = (yp + vp * 1436 / 1024 - 179).round().clamp(0, 255);
      int g = (yp - up * 46549 / 131072 + 44 - vp * 93604 / 131072 + 91).round().clamp(0, 255);
      int b = (yp + up * 1814 / 1024 - 227).round().clamp(0, 255);
      // color: 0x FF  FF  FF  FF
      //           A   B   G   R
      img.data[index] = (0xFF << 24) | (b << 16) | (g << 8) | r;
    }
  }
  return img;
}
