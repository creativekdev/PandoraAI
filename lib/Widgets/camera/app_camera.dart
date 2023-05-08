import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/config.dart';
import 'package:cartoonizer/utils/sensor_helper.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:image/image.dart' as imglib;

class AppCamera extends StatefulWidget {
  double width;
  double height;
  Function(AppCameraController controller) onCreate;

  AppCamera({
    Key? key,
    required this.width,
    required this.height,
    required this.onCreate,
  }) : super(key: key);

  @override
  State<AppCamera> createState() => _AppCameraState();
}

class _AppCameraState extends State<AppCamera> with AppCameraController, WidgetsBindingObserver {
  late double width;
  late double height;
  CameraController? controller;
  Future<void>? _initializeControllerFuture;
  Completer<XFile?>? _completer;
  GlobalKey screenShotKey = GlobalKey();
  bool isFront = true;

  late Axis widgetDirection;

  CameraImage? lastScreenShot;
  int lastScreenShotStamp = 0;
  bool takingPhoto = false;

  @override
  void initState() {
    super.initState();
    width = widget.width;
    height = widget.height;
    widgetDirection = width / height > 1 ? Axis.horizontal : Axis.vertical;
    availableCameras().then((value) {
      if (!mounted) {
        return;
      }
      var pick = value.pick((t) => t.lensDirection == CameraLensDirection.front) ?? value.first;
      setState(() {
        isFront = pick.lensDirection == CameraLensDirection.front;
        controller = CameraController(
          pick,
          ResolutionPreset.medium,
          imageFormatGroup: ImageFormatGroup.yuv420,
        );
        widget.onCreate.call(this);
        _initializeControllerFuture = controller!.initialize();
      });
    });
  }

  @override
  onDispose() {
    controller?.stopImageStream().onError((error, stackTrace) {}).whenComplete(() {
      controller?.dispose();
    });
  }

  @override
  void dispose() {
    super.dispose();
    // controller?.stopImageStream().onError((error, stackTrace) {}).whenComplete(() {
    //   controller?.dispose();
    // });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      controller = CameraController(
        cameraController.description,
        ResolutionPreset.medium,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      _initializeControllerFuture = controller!.initialize();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          lastScreenShotStamp = DateTime.now().millisecondsSinceEpoch;
          startStream();
          // If the Future is complete, display the preview.
          var ratio = controller!.value.aspectRatio;
          var surfaceWidth = height / ratio;
          var offsetX = (surfaceWidth - width) / 2;
          var surface = controller!.buildPreview().intoContainer(
                width: surfaceWidth,
                height: height,
              );
          var scrollController = ScrollController();
          var view = SingleChildScrollView(
            child: RepaintBoundary(key: screenShotKey, child: surface),
            controller: scrollController,
            physics: NeverScrollableScrollPhysics(),
            scrollDirection: Axis.horizontal,
          );
          delay(() {
            if (scrollController.positions.isNotEmpty) {
              scrollController.jumpTo(offsetX);
            }
          }, milliseconds: 64);
          return view;
        } else {
          // Otherwise, display a loading indicator.
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<void> startStream() async {
    if (controller != null) {
      await controller!.startImageStream((image) {
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
  }

  @override
  switchCamera() {
    controller?.stopImageStream().onError((error, stackTrace) {});
    controller?.dispose();
    delay(() {
      availableCameras().then((value) {
        var pick = value.pick((t) => isFront ? t.lensDirection != CameraLensDirection.front : t.lensDirection == CameraLensDirection.front) ?? value.first;
        setState(() {
          isFront = pick.lensDirection == CameraLensDirection.front;
          controller = CameraController(
            pick,
            ResolutionPreset.medium,
            imageFormatGroup: ImageFormatGroup.yuv420,
          );
          _initializeControllerFuture = controller!.initialize();
        });
      });
    }, milliseconds: 500);
  }

  @override
  CameraController? getController() {
    return controller;
  }

  @override
  Future<XFile?> takePhoto() async {
    if (lastScreenShot == null) {
      return null;
    }
    if (takingPhoto) {
      return null;
    }
    takingPhoto = true;
    var list = await convertImagetoPng(isFront, lastScreenShot!, widgetDirection, PoseState.stand);
    if (list == null) {
      takingPhoto = false;
      return null;
    }
    var operator = AppDelegate.instance.getManager<CacheManager>().storageOperator;
    String filePath = '${operator.imageDir.path}${DateTime.now().millisecondsSinceEpoch}.png';
    var uint8list = Uint8List.fromList(list);
    var imageInfo = (await SyncMemoryImage(list: uint8list).getImage()).image;
    double ratio = height / width;
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
    return XFile(file.path);
  }

  @override
  Future<XFile?> takeVideo({required int maxDuration}) async {
    if (_completer != null) {
      return null;
    }
    _completer = Completer();
    controller?.startVideoRecording();
    return _completer!.future;
  }

  @override
  Future<bool> stopTakeVideo() async {
    if (controller?.value.isRecordingVideo ?? false) {
      var xFile = await controller?.stopVideoRecording();
      _completer?.complete(xFile);
      _completer = null;
      return xFile != null;
    } else {
      return false;
    }
  }
}

abstract class AppCameraController {
  CameraController? getController();

  Future<XFile?> takePhoto();

  Future<XFile?> takeVideo({required int maxDuration});

  Future<bool> stopTakeVideo();

  switchCamera();

  onDispose();
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
            img = imglib.copyRotate(img, angle: isFront ? 270 : 90);
            if (isFront) {
              img = imglib.flip(img, direction: imglib.FlipDirection.horizontal);
            }
          }
        } else {
          if (img.width < img.height) {
            img = imglib.copyRotate(img, angle: isFront ? 270 : 90);
            if (isFront) {
              img = imglib.flip(img, direction: imglib.FlipDirection.horizontal);
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
        img = imglib.copyRotate(img, angle: 90);
      } else if (pose == PoseState.rightDumped) {
        img = imglib.copyRotate(img, angle: 270);
      }
    }
    imglib.PngEncoder pngEncoder = imglib.PngEncoder();
    List<int> png = pngEncoder.encode(img);
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
    width: (image.planes[0].bytesPerRow / 4).round(),
    height: image.height,
    bytes: image.planes[0].bytes.buffer,
    // format: imglib.Format.bgra,
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
  var img = imglib.Image(width: width, height: height); // Create Image buffer

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
      var imageData = img.data!;
      imageData.setPixel(x, y, imglib.ColorInt16.rgb(r, g, b));
    }
  }
  return img;
}
