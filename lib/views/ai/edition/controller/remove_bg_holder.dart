import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/Widgets/background_card.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/utils/color_util.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/edition/controller/ie_base_holder.dart';
import 'package:cartoonizer/views/mine/filter/im_remove_bg_screen.dart';
import 'package:image/image.dart' as imgLib;

import '../../../../Common/event_bus_helper.dart';
import '../../../common/background/background_picker.dart';
import '../../../mine/filter/pin_gesture_views.dart';

class RemoveBgHolder extends ImageEditionBaseHolder {
  BackgroundData? selectData;

  File? _removedImage;

  File? get removedImage => _removedImage;

  set removedImage(File? file) {
    _removedImage = file;
    update();
  }

  double ratio = 1;

  ui.Image? imageUiFront;
  imgLib.Image? imageFront;

  BackgroundData preBackgroundData = BackgroundData();

  RemoveBgHolder({required super.parent});

  @override
  Future initData() async {
    await super.initData();
    preBackgroundData.color = Colors.transparent;
    preBackgroundData.filePath = null;
    final imageSize = Size(ScreenUtil.screenSize.width, ScreenUtil.screenSize.height - (kNavBarPersistentHeight + ScreenUtil.getStatusBarHeight() + $(140)));
    Navigator.push(
      Get.context!,
      NoAnimRouter(
        ImRemoveBgScreen(
          bottomPadding: parent.bottomHeight + ScreenUtil.getBottomPadding(Get.context!),
          filePath: originFilePath!,
          imageRatio: shownImage!.width / shownImage!.height,
          imageHeight: shownImage!.height.toDouble(),
          imageWidth: shownImage!.width.toDouble(),
          onGetRemoveBgImage: (String path) async {
            var imageInfo = await SyncFileImage(file: File(path)).getImage();
            ratio = imageInfo.image.width / imageInfo.image.height;
            removedImage = File(path);
            imageUiFront = await getImage(File(path));
            imageFront = await getLibImage(imageUiFront!);
            bgController.setBackgroundData(null, Colors.transparent);
          },
          size: imageSize,
        ),
        // opaque: true,
        settings: RouteSettings(name: "/ImRemoveBgScreen"),
      ),
    );
  }

  onSavedBackground(BackgroundData data, bool isPopMerge) async {
    canReset = true;
    if (isPopMerge) {
      preBackgroundData = selectData ?? preBackgroundData;
    } else {
      if (data.filePath != null) {
        File backFile = File(data.filePath!);
        bgController.setBackgroundData(backFile, null);
      } else {
        bgController.setBackgroundData(null, rgbaToAbgr(data.color!));
      }
      selectData = data;
    }
    delay(() => onProductShowImage(), milliseconds: 200);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   onProductShowImage(); // 在这里可以执行你想要的操作，因为重建已完成
    // });
  }

  ui.Color rgbaToAbgr(ui.Color rgbaColor) {
    int abgrValue = (rgbaColor.alpha << 24) | (rgbaColor.blue << 16) | (rgbaColor.green << 8) | rgbaColor.red;
    return ui.Color(abgrValue);
  }

  ui.Color abgrToRgba(int abgrValue) {
    int alpha = (abgrValue >> 24) & 0xFF;
    int blue = (abgrValue >> 16) & 0xFF;
    int green = (abgrValue >> 8) & 0xFF;
    int red = abgrValue & 0xFF;

    return Color.fromRGBO(red, green, blue, alpha / 255.0);
  }

  onResetClick() async {
    preBackgroundData.color = Colors.transparent;
    preBackgroundData.filePath = null;
    if (selectData?.color != null && selectData?.color != Colors.transparent) {
      await onSavedBackground(BackgroundData()..color = Colors.transparent, false);
    }
    if (scale != 1 || dy != 0 || dx != 0) {
      scale = 1;
      dy = 0;
      dx = 0;
    }
    EventBusHelper().eventBus.fire(OnResetScaleEvent());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      onProductShowImage(); // 在这里可以执行你想要的操作，因为重建已完成
    });
    canReset = false;
  }

  onProductShowImage() async {
    ui.Image? image = await getBitmapFromContext(globalKey.currentContext!, pixelRatio: ScreenUtil.mediaQuery?.devicePixelRatio ?? 3.0);
    if (image != null) {
      shownImage = await getLibImage(image);
    }
  }

  late Uint8List personByte;
  GlobalKey globalKey = GlobalKey(); // 保存图片的key
  RxBool isShowSquar = false.obs; // 显示人像的边框
  bool isRequestWidth = true;
  double scale = 1;

  // double bgScale = 1;
  double dx = 0;
  double dy = 0;

  double _width = 0;
  double _height = 0;

  GlobalKey _personImageKey = GlobalKey();
  Rect borderRect = Rect.fromLTRB(0, 0, 0, 0);

  LoadBgController bgController = Get.put(LoadBgController());

  Future<Uint8List?> getPersonImage(Size size) async {
    if (isRequestWidth == false) {
      return null;
    }
    var byteData = await imageUiFront!.toByteData(format: ui.ImageByteFormat.png);
    personByte = byteData!.buffer.asUint8List();
    final int width = imageFront!.width;
    final int height = imageFront!.height;
    if ((width / size.width) > (height / size.height)) {
      _height = size.width * height / width;
      _width = size.width;
    } else {
      _width = size.height * width / height;
      _height = size.height;
    }
    borderRect = getMaxRealImageRect(width, height);
    return personByte;
  }

  Rect getMaxRealImageRect(int width, int height) {
    int minX = width;
    int maxX = 0;
    int minY = height;
    int maxY = 0;
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        if (!isAphaInLocation(x, y)) {
          if (x < minX) minX = x;
          if (x > maxX) maxX = x;
          if (y < minY) minY = y;
          if (y > maxY) maxY = y;
        }
      }
    }
    double scale = _width / width;

    return Rect.fromLTWH(
      minX * scale.toDouble(),
      minY * scale.toDouble(),
      maxX * scale.toDouble() - minX * scale.toDouble(),
      maxY * scale.toDouble() - minY * scale.toDouble(),
    );
  }

  bool isAphaInLocation(int x, int y) {
    int pixelColor = imageFront!.getPixel(x, y);
    int alpha = imgLib.getAlpha(pixelColor);
    bool isTransparent = alpha == 0;
    if (isTransparent) {
      return true;
    } else {
      return false;
    }
  }

  Widget buildShownImage(Size size) {
    return Stack(
      children: [
        Column(
          children: [
            if (isRequestWidth == false)
              Expanded(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    RepaintBoundary(
                      key: globalKey,
                      child: Listener(
                        onPointerDown: (PointerDownEvent event) {
                          isShowSquar.value = true;
                        },
                        onPointerUp: (PointerUpEvent event) {
                          isShowSquar.value = false;
                        },
                        child: ClipRect(
                          child: CustomPaint(
                            painter: BackgroundPainter(
                              bgColor: Colors.transparent,
                              w: 10,
                              h: 10,
                            ),
                            child: Container(
                              width: _width,
                              height: _height,
                              child: Stack(alignment: Alignment.center, children: [
                                LoadBgView(width: _width, height: _height),
                                PinGestureView(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        child: Image.file(
                                          key: _personImageKey,
                                          removedImage!,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      Obx(
                                        () => isShowSquar.value
                                            ? UnconstrainedBox(
                                                child: Container(
                                                  width: _width,
                                                  height: _height,
                                                  padding: EdgeInsets.only(top: borderRect.top, left: borderRect.left),
                                                  child: CustomPaint(
                                                    painter: GradientBorderPainter(
                                                      width: borderRect.width,
                                                      height: borderRect.height,
                                                      strokeWidth: $(2),
                                                      borderRadius: $(8),
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          Color(0xFFE31ECD),
                                                          Color(0xFF243CFF),
                                                          Color(0xFFE31ECD),
                                                        ],
                                                        begin: Alignment.topLeft,
                                                        end: Alignment.bottomRight,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : SizedBox(),
                                      )
                                    ],
                                  ),
                                  scale: scale,
                                  dx: dx,
                                  dy: dy,
                                  onPinEndCallBack: (bool isSelected, double newScale, double newDx, double newDy) {
                                    scale = newScale;
                                    dx = newDx;
                                    dy = newDy;
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      onProductShowImage(); // 在这里可以执行你想要的操作，因为重建已完成
                                    });
                                  },
                                ),
                              ]),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (isRequestWidth == true)
              FutureBuilder(
                  future: getPersonImage(size),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      isRequestWidth = false;
                      return Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            RepaintBoundary(
                              key: globalKey,
                              child: Listener(
                                onPointerDown: (PointerDownEvent event) {
                                  isShowSquar.value = true;
                                },
                                onPointerUp: (PointerUpEvent event) {
                                  isShowSquar.value = false;
                                },
                                child: ClipRect(
                                  child: CustomPaint(
                                    painter: BackgroundPainter(
                                      bgColor: Colors.transparent,
                                      w: 10,
                                      h: 10,
                                    ),
                                    child: Container(
                                      width: _width,
                                      height: _height,
                                      child: Stack(alignment: Alignment.center, children: [
                                        LoadBgView(width: _width, height: _height),
                                        PinGestureView(
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                alignment: Alignment.center,
                                                child: Image.file(
                                                  key: _personImageKey,
                                                  removedImage!,
                                                  fit: BoxFit.contain,
                                                  frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                                    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                                                      onProductShowImage();
                                                    });
                                                    return child;
                                                  },
                                                ),
                                              ),
                                              Obx(
                                                () => isShowSquar.value
                                                    ? UnconstrainedBox(
                                                        child: Container(
                                                          width: _width,
                                                          height: _height,
                                                          padding: EdgeInsets.only(top: borderRect.top, left: borderRect.left),
                                                          child: CustomPaint(
                                                            painter: GradientBorderPainter(
                                                              width: borderRect.width,
                                                              height: borderRect.height,
                                                              strokeWidth: $(2),
                                                              borderRadius: $(8),
                                                              gradient: LinearGradient(
                                                                colors: [
                                                                  Color(0xFFE31ECD),
                                                                  Color(0xFF243CFF),
                                                                  Color(0xFFE31ECD),
                                                                ],
                                                                begin: Alignment.topLeft,
                                                                end: Alignment.bottomRight,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : SizedBox(),
                                              )
                                            ],
                                          ),
                                          scale: scale,
                                          dx: dx,
                                          dy: dy,
                                          onPinEndCallBack: (bool isSelected, double newScale, double newDx, double newDy) {
                                            scale = newScale;
                                            dx = newDx;
                                            dy = newDy;
                                            WidgetsBinding.instance.addPostFrameCallback((_) {
                                              onProductShowImage(); // 在这里可以执行你想要的操作，因为重建已完成
                                            });
                                          },
                                        ),
                                      ]),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return CustomPaint(
                      painter: BackgroundPainter(
                        bgColor: Colors.transparent,
                        w: 10,
                        h: 10,
                      ),
                      child: Container(
                        width: _width,
                        height: _height,
                        padding: EdgeInsets.only(top: ScreenUtil.getNavigationBarHeight() + ScreenUtil.getStatusBarHeight()),
                        child: Image.file(removedImage!, fit: BoxFit.contain),
                      ),
                    );
                  }),
          ],
        ),
      ],
    ).intoContainer(width: size.width, height: size.height);
  }

  @override
  dispose() {
    Get.delete<LoadBgController>();
    return super.dispose();
  }
}

class GradientBorderPainter extends CustomPainter {
  final double strokeWidth;
  final double borderRadius;
  final Gradient gradient;
  final double width;
  final double height;

  GradientBorderPainter({
    required this.strokeWidth,
    required this.borderRadius,
    required this.gradient,
    required this.width,
    required this.height,
  });

  @override
  void paint(Canvas canvas, Size size) {
    size = Size(width, height);
    final path = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(borderRadius)));

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..shader = gradient.createShader(Offset.zero & size);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class LoadBgController extends GetxController {
  File? _backgroundImage;
  ui.Color? _backgroundColor;

  setBackgroundData(File? bgImage, ui.Color? bgColor) {
    _backgroundImage = bgImage;
    _backgroundColor = bgColor;
    update();
  }

  File? get backgroundImage => _backgroundImage;

  ui.Color? get backgroundColor => _backgroundColor;
}

class LoadBgView extends StatefulWidget {
  const LoadBgView({Key? key, required this.width, required this.height}) : super(key: key);
  final double width;
  final double height;

  @override
  State<LoadBgView> createState() => _LoadBgViewState();
}

class _LoadBgViewState extends State<LoadBgView> {
  LoadBgController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoadBgController>(
        init: controller,
        builder: (controller) {
          return Container(
            alignment: Alignment.center,
            color: (controller.backgroundColor ?? Colors.transparent).toArgb(),
            child: controller.backgroundImage != null
                ? Image.file(
                    controller.backgroundImage!,
                    fit: BoxFit.cover,
                    width: widget.width,
                    height: widget.height,
                  )
                : SizedBox(),
            width: widget.width,
            height: widget.height,
          );
        });
    ;
  }
}
