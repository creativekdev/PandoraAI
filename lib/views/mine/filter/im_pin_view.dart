import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/views/mine/filter/pin_gesture_views.dart';
import 'package:image/image.dart' as imgLib;

import '../../../Widgets/app_navigation_bar.dart';
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

  ImPinView({
    required this.personImage,
    required this.personImageForUI,
    required this.backgroundImage,
    required this.backgroundColor,
    required this.onAddImage,
    this.bottomPadding = 0,
    required this.switchButtonPadding,
    required this.originFile,
  }) {
    if (backgroundImage != null) {
      backgroundByte = Uint8List.fromList(imgLib.encodeJpg(backgroundImage!));
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
  Uint8List? personByte = Uint8List.fromList([]);
  RxBool isShowSquar = false.obs;
  RxBool isShowBg = false.obs;

  double _width = 0;
  double _height = 0;

  GlobalKey _personImageKey = GlobalKey();
  Rect borderRect = Rect.fromLTRB(0, 0, 0, 0);

  Future<Uint8List?> getPersonImage() async {
    var byteData = await widget.personImageForUI.toByteData(format: ui.ImageByteFormat.png);
    personByte = byteData?.buffer.asUint8List();

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

  // bool getActionView(Offset tapPosition) {
  //   RenderBox containerBox = _personImageKey.currentContext!.findRenderObject() as RenderBox;
  //   Offset containerPosition = containerBox.localToGlobal(Offset.zero);
  //   double containerWidth = containerBox.size.width;
  //   double containerHeight = containerBox.size.height;
  //   bool result = false;
  //   if (tapPosition.dx >= containerPosition.dx &&
  //       tapPosition.dx <= containerWidth + dx &&
  //       tapPosition.dy >= containerPosition.dy &&
  //       tapPosition.dy <= containerHeight + containerPosition.dy) {
  //     int pixelColor = widget.personImage.getPixel(tapPosition.dx.toInt(), tapPosition.dy.toInt());
  //     bool isTransparent = ui.Color(pixelColor).alpha == 0;
  //     if (!isTransparent) {
  //       result = false;
  //     } else {
  //       result = true;
  //     }
  //   } else {
  //     result = true;
  //   }
  //   return result;
  // }

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
      // backgroundColor: Color(0xaa000000),
      appBar: AppNavigationBar(
        backgroundColor: Colors.transparent,
        trailing: Image.asset(Images.ic_edit_submit, width: $(22), height: $(22)).intoGestureDetector(onTap: () async {
          showLoading().whenComplete(() async {
            ui.Image? image = await getBitmapFromContext(globalKey.currentContext!, pixelRatio: ScreenUtil.mediaQuery?.devicePixelRatio ?? 3.0);
            if (image != null) {
              imgLib.Image img = await getLibImage(image);
              widget.onAddImage(img);
            }
            hideLoading().whenComplete(() {
              Navigator.of(context).pop();
            });
          });
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
                            ClipRect(
                              child: RepaintBoundary(
                                key: globalKey,
                                child: isShowOrigin
                                    ? Image.file(
                                        widget.originFile,
                                        fit: BoxFit.fill,
                                        // width: ScreenUtil.screenSize.width,
                                        // height: ScreenUtil.screenSize.width / widget.ratio,
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
                                              ? Container(
                                                  alignment: Alignment.center,
                                                  child: Image.memory(
                                                    widget.backgroundByte!,
                                                    fit: BoxFit.cover,
                                                    width: _width,
                                                    height: _height,
                                                  ),
                                                )
                                              : SizedBox()),
                                          PinGestureView(
                                            child: Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                Container(
                                                  alignment: Alignment.center,
                                                  child: Image.memory(
                                                    key: _personImageKey,
                                                    personByte!,
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
                                                              painter: SquarePainter(borderRect.width, borderRect.height),
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
                          ],
                        ),
                      );
                    }
                    return SizedBox();
                  }),
              SizedBox(height: widget.bottomPadding - ScreenUtil.getBottomPadding(context)),
            ],
          ),
          Column(
            children: [
              Expanded(
                child: Container(
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(top: widget.switchButtonPadding - ScreenUtil.getBottomPadding(context) + $(5), right: $(12)),
                  child: Image.asset(Images.ic_switch_images, width: $(24), height: $(24))
                      .intoContainer(
                    padding: EdgeInsets.all($(8)),
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
              SizedBox(height: widget.bottomPadding - ScreenUtil.getBottomPadding(context)),
            ],
          ),
        ],
      ),
    );
  }
}

class SquarePainter extends CustomPainter {
  SquarePainter(this.width, this.height);

  double width;
  double height;

  @override
  void paint(Canvas canvas, Size size) {
    size = Size(width, height);
    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = $(2)
      ..style = PaintingStyle.stroke;

    RRect roundedRectangle = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular($(5)),
    );

    canvas.drawRRect(roundedRectangle, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

// @override
// void paint(Canvas canvas, Size size) {
//   print("Painter size == ${size}");
//   final Paint borderPaint = Paint()
//     ..color = Colors.white
//     ..strokeWidth = $(2)
//     ..style = PaintingStyle.stroke;
//
//   // final double sideLength = size.width > size.height ? size.height : size.width;
//   // final double xOffset = (size.width - sideLength) / 2;
//   // final double yOffset = (size.height - sideLength) / 2;
//
//   final Rect squareRect = Rect.fromLTWH(0, 0, size.width, size.height);
//   // canvas.drawRect(squareRect, fillPaint);
//   canvas.drawRect(squareRect, borderPaint);
// }
//
// @override
// bool shouldRepaint(covariant CustomPainter oldDelegate) {
//   return false;
// }
}
