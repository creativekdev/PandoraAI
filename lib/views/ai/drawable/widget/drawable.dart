import 'dart:ui' as ui;

import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:cartoonizer/utils/img_utils.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:image/image.dart' as imgLib;

enum DrawMode {
  paint,
  markPaint,
  eraser,
  floodFill,
}

class DrawableController {
  _DrawableState? state;
  Color _background = Colors.white;
  Color paintColor = Colors.black;
  Color eraserColor = Colors.transparent;
  Color floodFillColor = Colors.red;

  double _eraserWidth = 30;
  double _paintWidth = 5;
  double _markPaintWidth = 10;
  List<DrawablePen> activePens = [];
  List<DrawablePen> checkmatePens = [];
  DrawMode _drawMode = DrawMode.paint;
  Function? onUpdated;
  var textEditingController = TextEditingController();

  List<Map<String, dynamic>> getPainSize() {
    switch (drawMode) {
      case DrawMode.paint:
        return [
          {'image': Images.ic_pencil1, 'size': 5.0},
          {'image': Images.ic_pencil2, 'size': 7.0},
          {'image': Images.ic_pencil3, 'size': 9.0},
          {'image': Images.ic_pencil4, 'size': 11.0},
          {'image': Images.ic_pencil5, 'size': 13.0},
        ];
      case DrawMode.markPaint:
        return [
          {'image': Images.ic_mark1, 'size': 10.0},
          {'image': Images.ic_mark2, 'size': 13.0},
          {'image': Images.ic_mark3, 'size': 16.0},
          {'image': Images.ic_mark4, 'size': 19.0},
          {'image': Images.ic_mark5, 'size': 22.0},
        ];
      case DrawMode.eraser:
        return [
          {'image': Images.ic_eraser1, 'size': 10.0},
          {'image': Images.ic_eraser2, 'size': 15.0},
          {'image': Images.ic_eraser3, 'size': 20.0},
          {'image': Images.ic_eraser4, 'size': 25.0},
          {'image': Images.ic_eraser5, 'size': 30.0},
        ];
      case DrawMode.floodFill:
        return [];
    }
  }

  Color currentColor() {
    switch (drawMode) {
      case DrawMode.paint:
        return paintColor;
      case DrawMode.eraser:
        return eraserColor;
      case DrawMode.floodFill:
        return floodFillColor;
      case DrawMode.markPaint:
        return paintColor;
    }
  }

  StrokeCap currentStrokeCap() {
    switch (drawMode) {
      case DrawMode.paint:
        return StrokeCap.round;
      case DrawMode.markPaint:
        return StrokeCap.square;
      case DrawMode.eraser:
        return StrokeCap.round;
      case DrawMode.floodFill:
        return StrokeCap.round;
    }
  }

  BlendMode currentBlendMode() {
    switch (drawMode) {
      case DrawMode.paint:
        return BlendMode.src;
      case DrawMode.eraser:
        return BlendMode.clear;
      case DrawMode.floodFill:
        return BlendMode.src;
      case DrawMode.markPaint:
        return BlendMode.src;
    }
  }

  PaintingStyle currentPaintingStyle() {
    switch (drawMode) {
      case DrawMode.paint:
        return PaintingStyle.stroke;
      case DrawMode.markPaint:
        return PaintingStyle.stroke;
      case DrawMode.eraser:
        return PaintingStyle.stroke;
      case DrawMode.floodFill:
        return PaintingStyle.fill;
    }
  }

  double currentStrokeWidth() {
    switch (drawMode) {
      case DrawMode.paint:
        return paintWidth;
      case DrawMode.markPaint:
        return markPaintWidth;
      case DrawMode.eraser:
        return eraserWidth;
      case DrawMode.floodFill:
        return 1;
    }
  }

  double get paintWidth => _paintWidth;

  set paintWidth(double value) {
    _paintWidth = value;
    state?.updateState();
    onUpdated?.call();
  }

  double get markPaintWidth => _markPaintWidth;

  set markPaintWidth(double value) {
    _markPaintWidth = value;
    state?.updateState();
    onUpdated?.call();
  }

  double get eraserWidth => _eraserWidth;

  set eraserWidth(double value) {
    _eraserWidth = value;
    state?.updateState();
    onUpdated?.call();
  }

  set drawMode(DrawMode mode) {
    _drawMode = mode;
    state?.updateState();
    state?.updateCanvas();
    onUpdated?.call();
  }

  DrawMode get drawMode => _drawMode;

  Color get background => _background;

  set background(Color color) {
    _background = color;
    state?.updateState();
    state?.updateCanvas();
    onUpdated?.call();
  }

  Paint currentPaint() {
    return Paint()
      ..isAntiAlias = true
      ..color = currentColor()
      ..blendMode = currentBlendMode()
      ..strokeWidth = currentStrokeWidth()
      ..strokeCap = currentStrokeCap()
      ..style = currentPaintingStyle();
  }

  addPens(DrawablePen pen) {
    activePens.add(pen);
    checkmatePens.clear();
    state?.updateState();
    state?.updateCanvas();
    onUpdated?.call();
  }

  bool canForward() {
    return !checkmatePens.isEmpty;
  }

  bool canRollback() {
    return !activePens.isEmpty;
  }

  forward() {
    if (!canForward()) {
      return;
    }
    var first = checkmatePens.removeAt(0);
    activePens.add(first);
    state?.updateState();
    state?.updateCanvas();
    onUpdated?.call();
  }

  rollback() {
    if (!canRollback()) {
      return;
    }
    var last = activePens.removeLast();
    checkmatePens.insert(0, last);
    state?.updateState();
    state?.updateCanvas();
    onUpdated?.call();
  }

  reset() {
    activePens.clear();
    checkmatePens.clear();
    _background = Colors.white;
    _drawMode = DrawMode.paint;
    state?.updateState();
    state?.updateCanvas();
    onUpdated?.call();
  }

  Future<List<Uint8List>?> getImage() async {
    var local = await state?.getImage();
    var upload = await state?.getImage(toUpload: false);
    return [local!, upload!];
  }

  bool isEmpty() {
    return activePens.isEmpty && checkmatePens.isEmpty;
  }
}

class Drawable extends StatefulWidget {
  Size size;
  DrawableController controller;

  Drawable({
    Key? key,
    required this.controller,
    required this.size,
  }) : super(key: key);

  @override
  State<Drawable> createState() => _DrawableState();
}

class _DrawableState extends State<Drawable> {
  late DrawableController _controller;
  late Size _size;
  int lastPointerId = -1;
  GlobalKey<_CanvasHolderState> key = GlobalKey();
  DrawablePen? currentPen;

  int black32 = 4278190080;

  updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  updateCanvas() {
    if (mounted) {
      key.currentState?.update();
    }
  }

  Future<Uint8List?> getImage({bool toUpload = false}) async {
    var image = await key.currentState!.getScreenShot();
    if (toUpload) {
      imgLib.Image pixels = await getLibImage(image!);
      for (int i = 0; i < pixels.width; i++) {
        for (int j = 0; j < pixels.height; j++) {
          var pixel = pixels.getPixel(i, j);
          if (pixel == black32) {
            pixels.setPixel(i, j, imgLib.getColor(255, 255, 255));
          } else {
            pixels.setPixel(i, j, imgLib.getColor(0, 0, 0));
          }
        }
      }
      return Uint8List.fromList(imgLib.encodePng(pixels));
    } else {
      var byteData = await image!.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    }
  }

  Future<void> getFloodFillPath(Offset offset) async {
    var image = await key.currentState!.getScreenShot();
    var image2 = await getLibImage(image!);
    List<Path> paths = ImageUtils.getBoundaries(image2, offset);
    if (paths.isEmpty) {
      return;
    }
    if (paths.length == 1) {
      _controller.addPens(DrawablePen(paint: _controller.currentPaint(), path: paths.first, drawMode: _controller.drawMode, lastPosition: offset));
    } else {
      for (int i = 0; i < paths.length; i++) {
        var currentPaint = _controller.currentPaint();
        if (i == 0) {
          _controller.addPens(DrawablePen(paint: currentPaint, path: paths.first, drawMode: _controller.drawMode, lastPosition: offset));
        } else {
          _controller.addPens(DrawablePen(paint: currentPaint..color = _controller.background, path: paths[i], drawMode: _controller.drawMode, lastPosition: offset));
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    initData();
  }

  @override
  void didUpdateWidget(covariant Drawable oldWidget) {
    super.didUpdateWidget(oldWidget);
    initData();
  }

  initData() {
    _size = widget.size;
    _controller.state = this;
  }

  onPointDown(PointerDownEvent details) {
    if (currentPen != null) {
      return;
    }
    lastPointerId = details.pointer;
    if (_controller.drawMode == DrawMode.floodFill) {
      getFloodFillPath(details.localPosition);
    } else {
      currentPen = DrawablePen(
        paint: _controller.currentPaint(),
        path: Path()
          ..moveTo(
            details.localPosition.dx,
            details.localPosition.dy,
          ),
        drawMode: _controller.drawMode,
        lastPosition: details.localPosition,
      );
      _controller.addPens(currentPen!);
    }
  }

  onPointMove(PointerMoveEvent details) {
    if (details.pointer != lastPointerId) {
      return;
    }
    if (_controller.drawMode == DrawMode.floodFill) {
    } else {
      currentPen!.path.lineTo(details.localPosition.dx, details.localPosition.dy);
      currentPen!.lastPosition = details.localPosition;
      updateCanvas();
    }
  }

  onPointUp(PointerUpEvent details) {
    if (details.pointer != lastPointerId) {
      return;
    }
    if (_controller.drawMode == DrawMode.floodFill) {
    } else {
      if (currentPen != null) {
        currentPen!.path.lineTo(details.localPosition.dx, details.localPosition.dy);
        updateCanvas();
        currentPen!.lastPosition = null;
        currentPen = null;
        updateState();
      }
    }
  }

  onPointCancel(PointerCancelEvent details) {
    if (details.pointer != lastPointerId) {
      return;
    }
    if (_controller.drawMode == DrawMode.floodFill) {
    } else {
      if (currentPen != null) {
        currentPen!.path.lineTo(details.localPosition.dx, details.localPosition.dy);
        updateCanvas();
        currentPen!.lastPosition = null;
        currentPen = null;
        updateState();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: _size.height,
      width: _size.width,
      child: Listener(
        onPointerPanZoomStart: (details) {
          //todo
        },
        onPointerPanZoomEnd: (details) {
          //todo
        },
        onPointerPanZoomUpdate: (details) {
          //todo
        },
        onPointerDown: (details) {
          var s = details.toStringFull();
          onPointDown(details);
        },
        onPointerMove: onPointMove,
        onPointerUp: onPointUp,
        onPointerCancel: onPointCancel,
        child: _CanvasHolder(
          key: key,
          controller: _controller,
          size: _size,
        ),
      ),
    );
  }
}

class _CanvasHolder extends StatefulWidget {
  DrawableController controller;
  Size size;

  _CanvasHolder({
    Key? key,
    required this.controller,
    required this.size,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CanvasHolderState();
  }
}

class _CanvasHolderState extends State<_CanvasHolder> {
  late DrawableController _controller;
  late Size _size;
  GlobalKey screenShotKey = GlobalKey();

  update() {
    setState(() {});
  }

  Future<ui.Image?> getScreenShot() async {
    var image = await getBitmapFromContext(screenShotKey.currentContext!);
    return image;
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller;
    _size = widget.size;
  }

  @override
  void didUpdateWidget(covariant _CanvasHolder oldWidget) {
    super.didUpdateWidget(oldWidget);
    _controller = widget.controller;
    _size = widget.size;
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: screenShotKey,
      child: CustomPaint(
        painter: DrawablePainter(
          pens: _controller.activePens,
          backgroundColor: _controller.background,
          eraserRadius: _controller.eraserWidth / 2,
        ),
        child: Container(
          width: _size.width,
          height: _size.height,
        ),
      ),
    );
  }
}

class DrawablePainter extends CustomPainter {
  List<DrawablePen> pens;
  Color backgroundColor;

  double eraserRadius;

  DrawablePainter({
    required this.pens,
    required this.backgroundColor,
    required this.eraserRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(backgroundColor, BlendMode.src);
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    Offset? eraserPosition;
    for (var value in pens) {
      canvas.drawPath(value.path, value.paint);
      if (value.drawMode == DrawMode.eraser) {
        if (value.lastPosition != null) {
          eraserPosition = value.lastPosition;
        }
      }
    }
    canvas.restore();
    if (eraserPosition != null) {
      canvas.drawCircle(
          eraserPosition,
          eraserRadius,
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class DrawablePen {
  Paint paint;
  Path path;
  DrawMode drawMode;
  Offset? lastPosition;

  DrawablePen({
    required this.paint,
    required this.path,
    required this.drawMode,
    required this.lastPosition,
  });
}
