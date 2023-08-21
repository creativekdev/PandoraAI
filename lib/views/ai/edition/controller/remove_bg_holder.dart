import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Widgets/background_card.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/utils/color_util.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/edition/controller/ie_base_holder.dart';
import 'package:image/image.dart' as imgLib;

import '../../../../app/app.dart';
import '../../../../app/cache/cache_manager.dart';
import '../../../common/background/background_picker.dart';
import '../../../mine/filter/pin_gesture_views.dart';

class RemoveBgHolder extends ImageEditionBaseHolder {
  ui.Color? backgroundColor;
  File? _backgroundImage;
  BackgroundData? selectData;

  File? get backgroundImage => _backgroundImage;

  setBackgroundImage(File? file, bool isSave) async {
    _backgroundImage = file;
    await buildBackLibImg(isSave);
  }

  File? _removedImage;

  File? get removedImage => _removedImage;

  set removedImage(File? file) {
    _removedImage = file;
    shownImageWidget = Image.file(file!);
    buildFrontLibImg();
  }

  double ratio = 1;

  ui.Image? imageUiFront;
  imgLib.Image? imageFront;
  imgLib.Image? imageBack;
  BackgroundData preBackgroundData = BackgroundData();

  RemoveBgHolder({required super.parent});

  @override
  initData() {
    if (removedImage == null) {}
    preBackgroundData.color = Colors.transparent;
    preBackgroundData.filePath = null;
  }

  onSavedBackground(BackgroundData data, bool isPopMerge) async {
    if (isPopMerge) {
      preBackgroundData = selectData ?? preBackgroundData;
    } else {
      if (data.filePath != null) {
        File backFile = File(data.filePath!);
        backgroundColor = null;
        await setBackgroundImage(backFile, isPopMerge);
      } else {
        backgroundColor = rgbaToAbgr(data.color!);
        await setBackgroundImage(null, false);
      }
      selectData = data;
    }
  }

  buildBackLibImg(bool isSave) async {
    if (_backgroundImage != null) {
      imageBack = await getLibImage(await getImage(_backgroundImage!));
    }
    update();
  }

  saveImageWithColor(Color bgColor, bool isSave) async {
    imgLib.Image newImage = imgLib.Image(imageFront!.width, imageFront!.height);
    int fillColor = bgColor.value; // 获取颜色的ARGB值
    if (isSave) {
      preBackgroundData.color = abgrToRgba(fillColor);
      preBackgroundData.filePath = null;
    }
    newImage.fillBackground(fillColor);
    imgLib.drawImage(newImage, imageFront!);
    shownImage = newImage;
    CacheManager cacheManager = AppDelegate.instance.getManager();
    var path = cacheManager.storageOperator.removeBgDir.path + '${DateTime.now().millisecondsSinceEpoch}.png';
    List<int> outputBytes = imgLib.encodePng(newImage);
    await File(path).writeAsBytes(outputBytes);
    update();
  }

  buildFrontLibImg() async {
    if (_removedImage == null) {
      imageFront = null;
    } else {
      imageUiFront = await getImage(_removedImage!);
      imageFront = await getLibImage(imageUiFront!);
    }
    update();
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
    canReset = false;
    scale = 1;
    dy = 0;
    dx = 0;
    await onSavedBackground(BackgroundData()..color = Colors.transparent, false);
  }

  onProductShowImage() async {
    ui.Image? image = await getBitmapFromContext(globalKey.currentContext!, pixelRatio: ScreenUtil.mediaQuery?.devicePixelRatio ?? 3.0);
    if (image != null) {
      shownImage = await getLibImage(image);
      Uint8List byte = Uint8List.fromList(imgLib.encodeJpg(shownImage!));
      CacheManager cacheManager = AppDelegate.instance.getManager();
      var path = cacheManager.storageOperator.removeBgDir.path + '${DateTime.now().millisecondsSinceEpoch}.jpg';
      File(path).writeAsBytes(byte).then((value) {
      });
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
                                      _backgroundImage != null
                                          ? Container(
                                              alignment: Alignment.center,
                                              child: Image.file(
                                                _backgroundImage!,
                                                fit: BoxFit.cover,
                                                width: _width,
                                                height: _height,
                                              ),
                                            )
                                          : Container(
                                              alignment: Alignment.center,
                                              color: backgroundColor!.toArgb(),
                                              width: _width,
                                              height: _height,
                                            ),
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
                      child: Container(width: _width, height: _height, child: Image.file(removedImage!, fit: BoxFit.contain)));
                }),
            // SizedBox(height:bottomPadding - ScreenUtil.getBottomPadding(context)),
          ],
        ),
      ],
    );
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
