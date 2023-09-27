import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/widgets/state/app_state.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/color_util.dart';
import 'package:cartoonizer/views/mine/filter/pin_gesture_views.dart';
import 'package:image/image.dart' as imgLib;

import '../../../widgets/app_navigation_bar.dart';
import '../../../widgets/background_card.dart';
import '../../../utils/utils.dart';

class ImPinView extends StatefulWidget {
  imgLib.Image personImage;
  imgLib.Image? backgroundImage;
  Color? backgroundColor;
  ui.Image personImageForUI;

  // late double posX, posY, ratio;
  Uint8List? backgroundByte;
  final Function(imgLib.Image) onAddImage;
  final double bottomPadding;
  final double switchButtonPadding;
  final File originFile;
  final File resultePath;

  ImPinView({
    required this.personImage,
    required this.personImageForUI,
    required this.backgroundImage,
    required this.backgroundColor,
    required this.onAddImage,
    this.bottomPadding = 0,
    required this.switchButtonPadding,
    required this.originFile,
    required this.resultePath,
  }) {
    if (backgroundImage != null) {
      backgroundByte = Uint8List.fromList(imgLib.encodePng(backgroundImage!));
    }
    // posX = posY = 0;
    // ratio = 1;
  }

  @override
  _ImageMergingWidgetState createState() => _ImageMergingWidgetState();
}

class _ImageMergingWidgetState extends AppState<ImPinView> {
  bool isSelectedBg = false;
  GlobalKey globalKey = GlobalKey();
  double scale = 1;

  // double bgScale = 1;
  double dx = 0;
  double dy = 0;

  // double bgDx = 0;
  // double bgDy = 0;
  bool isShowOrigin = false;
  late Uint8List personByte;
  RxBool isShowSquar = false.obs;
  RxBool isShowBg = false.obs;
  RxBool isShowPerson = true.obs;

  double _width = 0;
  double _height = 0;

  GlobalKey _personImageKey = GlobalKey();
  Rect borderRect = Rect.fromLTRB(0, 0, 0, 0);

  Future<Uint8List?> getPersonImage() async {
    var byteData = await widget.personImageForUI.toByteData(format: ui.ImageByteFormat.png);
    personByte = byteData!.buffer.asUint8List();
    return personByte;
  }

  Rect getMaxRealImageRect() {
    final int width = widget.personImage.width;
    final int height = widget.personImage.height;
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
    int pixelColor = widget.personImage.getPixel(x, y);
    int alpha = imgLib.getAlpha(pixelColor);
    bool isTransparent = alpha == 0;
    if (isTransparent) {
      return true;
    } else {
      return false;
    }
  }

  onShowBg() {
    Future.delayed(Duration.zero, () {
      RenderBox containerBox = _personImageKey.currentContext!.findRenderObject() as RenderBox;
      _width = containerBox.size.width;
      _height = containerBox.size.height;
      borderRect = getMaxRealImageRect();
      if (_width > 0 && _height > 0) {
        isShowBg.value = true;
      }
    });
  }

  @override
  Widget buildWidget(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xaa000000),
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
        trailing: Image.asset(Images.ic_edit_submit, width: $(22), height: $(22)).intoGestureDetector(onTap: () async {
          ui.Image? image = await getBitmapFromContext(globalKey.currentContext!, pixelRatio: ScreenUtil.mediaQuery?.devicePixelRatio ?? 3.0);
          if (image != null) {
            imgLib.Image img = await getLibImage(image);
            widget.onAddImage(img);
          }
          Navigator.of(context).pop();

          // showLoading().whenComplete(() async {
          //   ui.Image? image = await getBitmapFromContext(globalKey.currentContext!, pixelRatio: ScreenUtil.mediaQuery?.devicePixelRatio ?? 3.0);
          //   if (image != null) {
          //     imgLib.Image img = await getLibImage(image);
          //     widget.onAddImage(img);
          //   }
          //   Future.delayed(Duration(milliseconds: 1000), () {
          //     hideLoading().whenComplete(() {
          //       Navigator.of(context).pop();
          //     });
          //   });
          // });
        }),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              FutureBuilder(
                  future: getPersonImage(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Expanded(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            RepaintBoundary(
                              key: globalKey,
                              child: isShowOrigin
                                  ? Container(
                                      alignment: Alignment.center,
                                      child: Image.file(
                                        widget.originFile,
                                        fit: BoxFit.fill,
                                        // width: ScreenUtil.screenSize.width,
                                        // height: ScreenUtil.screenSize.width / widget.ratio,
                                      ),
                                    )
                                  : Listener(
                                      onPointerDown: (PointerDownEvent event) {
                                        isShowSquar.value = true;
                                      },
                                      onPointerUp: (PointerUpEvent event) {
                                        isShowSquar.value = false;
                                      },
                                      child: Stack(alignment: Alignment.center, children: [
                                        Obx(() => isShowBg.value
                                            ? CustomPaint(
                                                size: Size(_width, _height),
                                                painter: BackgroundPainter(
                                                  bgColor: Colors.transparent,
                                                  w: 10,
                                                  h: 10,
                                                ))
                                            : Container()),
                                        Obx(() => isShowBg.value
                                            ? (widget.backgroundImage != null
                                                ? Container(
                                                    alignment: Alignment.center,
                                                    child: Image.memory(
                                                      widget.backgroundByte!,
                                                      fit: BoxFit.cover,
                                                      width: _width,
                                                      height: _height,
                                                    ),
                                                  )
                                                : Container(
                                                    alignment: Alignment.center,
                                                    color: widget.backgroundColor!.toArgb(),
                                                    width: _width,
                                                    height: _height,
                                                  ))
                                            : SizedBox()),
                                        Obx(() => isShowBg.value
                                            ? Align(
                                                alignment: Alignment.center,
                                                child: ClipRect(
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    width: _width,
                                                    height: _height,
                                                    child: PinGestureView(
                                                      child: ClipRect(
                                                        child: Container(
                                                          alignment: Alignment.center,
                                                          width: _width,
                                                          height: _height,
                                                          child: Stack(
                                                            alignment: Alignment.center,
                                                            children: [
                                                              Image.file(
                                                                key: _personImageKey,
                                                                widget.resultePath,
                                                                fit: BoxFit.contain,
                                                                frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                                                  onShowBg();
                                                                  return child;
                                                                },
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
                                                        ),
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
                                                  ),
                                                ),
                                              )
                                            : PinGestureView(
                                                child: Stack(
                                                  alignment: Alignment.center,
                                                  children: [
                                                    Container(
                                                      alignment: Alignment.center,
                                                      child: Image.file(
                                                        key: _personImageKey,
                                                        widget.resultePath,
                                                        fit: BoxFit.contain,
                                                        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                                                          onShowBg();
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
                                                },
                                              )),
                                      ]),
                                    ),
                            ),
                          ],
                        ),
                      );
                    }
                    return SizedBox();
                  }),
              SizedBox(height: widget.bottomPadding - ScreenUtil.getBottomPadding()),
            ],
          ),
          Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(top: widget.switchButtonPadding + ScreenUtil.getStatusBarHeight(), right: $(8)),
                  child: Image.asset(Images.ic_switch_images, width: $(24), height: $(24))
                      .intoContainer(
                    padding: EdgeInsets.all($(12)),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular($(32)), color: Color(0x88000000)),
                  )
                      .intoGestureDetector(
                    onTapDown: (details) {
                      isShowOrigin = true;
                      setState(() {});
                    },
                    onTapUp: (details) {
                      isShowOrigin = false;
                      setState(() {});
                    },
                    onTapCancel: () {
                      isShowOrigin = false;
                      setState(() {});
                    },
                  ),
                ),
              ),
              SizedBox(height: widget.bottomPadding - ScreenUtil.getBottomPadding()),
            ],
          ),
        ],
      ),
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
