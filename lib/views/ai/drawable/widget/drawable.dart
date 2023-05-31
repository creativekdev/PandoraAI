import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
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
  camera,
}

extension DrawModeEx on DrawMode {
  static DrawMode build(String value) {
    switch (value) {
      case 'paint':
        return DrawMode.paint;
      case 'markPaint':
        return DrawMode.markPaint;
      case 'eraser':
        return DrawMode.eraser;
      case 'floodFill':
        return DrawMode.floodFill;
      case 'camera':
        return DrawMode.camera;
      default:
        return DrawMode.paint;
    }
  }

  value() {
    switch (this) {
      case DrawMode.paint:
        return 'paint';
      case DrawMode.markPaint:
        return 'markPaint';
      case DrawMode.eraser:
        return 'eraser';
      case DrawMode.floodFill:
        return 'floodFill';
      case DrawMode.camera:
        return 'camera';
    }
  }
}

class DrawableController {
  _DrawableState? state;
  Color _background = Colors.white;
  Color paintColor = Colors.black;
  Color eraserColor = Colors.transparent;
  Color floodFillColor = Colors.red;

  double _eraserWidth = 30;
  double _paintWidth = 9;
  double _markPaintWidth = 10;
  List<DrawablePen> activePens = [];
  List<DrawablePen> checkmatePens = [];
  DrawMode _drawMode = DrawMode.paint;
  Function? onStartDraw;
  Rx<String> text = ''.obs;
  List<String> resultFilePaths = [];

  DrawableController({DrawableRecord? data}) {
    if (data != null) {
      text.value = data.text;
      activePens = data.activePens;
      checkmatePens = data.checkMatePens;
      resultFilePaths = data.resultPaths;
    }
  }

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
      case DrawMode.camera:
        return [];
    }
  }

  Color currentColor(DrawMode drawMode) {
    switch (drawMode) {
      case DrawMode.paint:
        return paintColor;
      case DrawMode.eraser:
        return eraserColor;
      case DrawMode.floodFill:
        return floodFillColor;
      case DrawMode.markPaint:
        return paintColor;
      case DrawMode.camera:
        return paintColor;
    }
  }

  StrokeCap currentStrokeCap(DrawMode drawMode) {
    switch (drawMode) {
      case DrawMode.paint:
        return StrokeCap.round;
      case DrawMode.markPaint:
        return StrokeCap.square;
      case DrawMode.eraser:
        return StrokeCap.round;
      case DrawMode.floodFill:
        return StrokeCap.round;
      case DrawMode.camera:
        return StrokeCap.round;
    }
  }

  BlendMode currentBlendMode(DrawMode drawMode) {
    switch (drawMode) {
      case DrawMode.paint:
        return BlendMode.src;
      case DrawMode.eraser:
        return BlendMode.clear;
      case DrawMode.floodFill:
        return BlendMode.src;
      case DrawMode.markPaint:
        return BlendMode.src;
      case DrawMode.camera:
        return BlendMode.src;
    }
  }

  PaintingStyle currentPaintingStyle(DrawMode drawMode) {
    switch (drawMode) {
      case DrawMode.paint:
        return PaintingStyle.stroke;
      case DrawMode.markPaint:
        return PaintingStyle.stroke;
      case DrawMode.eraser:
        return PaintingStyle.stroke;
      case DrawMode.floodFill:
        return PaintingStyle.fill;
      case DrawMode.camera:
        return PaintingStyle.stroke;
    }
  }

  double currentStrokeWidth(DrawMode drawMode) {
    switch (drawMode) {
      case DrawMode.paint:
        return paintWidth;
      case DrawMode.markPaint:
        return markPaintWidth;
      case DrawMode.eraser:
        return eraserWidth;
      case DrawMode.floodFill:
        return 1;
      case DrawMode.camera:
        return 1;
    }
  }

  double get paintWidth => _paintWidth;

  set paintWidth(double value) {
    _paintWidth = value;
    state?.updateState();
  }

  double get markPaintWidth => _markPaintWidth;

  set markPaintWidth(double value) {
    _markPaintWidth = value;
    state?.updateState();
  }

  double get eraserWidth => _eraserWidth;

  set eraserWidth(double value) {
    _eraserWidth = value;
    state?.updateState();
  }

  set drawMode(DrawMode mode) {
    _drawMode = mode;
    state?.updateState();
    state?.updateCanvas();
  }

  DrawMode get drawMode => _drawMode;

  Color get background => _background;

  set background(Color color) {
    _background = color;
    state?.updateState();
    state?.updateCanvas();
  }

  addPens(DrawablePen pen) {
    activePens.add(pen);
    checkmatePens.clear();
    state?.updateState();
    state?.updateCanvas();
    isEmpty.value = false;
    canForward.value = !checkmatePens.isEmpty;
    canRollback.value = !activePens.isEmpty;
  }

  Rx<bool> canForward = false.obs;
  Rx<bool> canRollback = false.obs;

  forward() {
    if (!canForward()) {
      return;
    }
    var first = checkmatePens.removeAt(0);
    activePens.add(first);
    state?.updateState();
    state?.updateCanvas();
    canForward.value = !checkmatePens.isEmpty;
    canRollback.value = !activePens.isEmpty;
  }

  rollback() {
    if (!canRollback()) {
      return;
    }
    var last = activePens.removeLast();
    checkmatePens.insert(0, last);
    state?.updateState();
    state?.updateCanvas();
    canForward.value = !checkmatePens.isEmpty;
    canRollback.value = !activePens.isEmpty;
  }

  reset() {
    activePens.clear();
    checkmatePens.clear();
    text.value = '';
    state?.updateState();
    state?.updateCanvas();
    isEmpty.value = true;
    canForward.value = !checkmatePens.isEmpty;
    canRollback.value = !activePens.isEmpty;
  }

  Future<Uint8List?> getImage({double screenShotScale = 1}) async {
    var local = await state?.getImage(ratio: screenShotScale);
    return local;
  }

  Rx<bool> isEmpty = true.obs;

  startDraw() {
    onStartDraw?.call();
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

  Future<Uint8List?> getImage({double ratio = 1, bool toUpload = false}) async {
    var image = await key.currentState!.getScreenShot(ratio);
    imgLib.Image pixels = await getLibImage(image!);
    if (toUpload) {
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
      return Uint8List.fromList(imgLib.encodeJpg(pixels));
    } else {
      return Uint8List.fromList(imgLib.encodeJpg(pixels));
    }
  }

  Future<void> getFloodFillPath(Offset offset) async {
    var image = await key.currentState!.getScreenShot(1);
    var image2 = await getLibImage(image!);
    List<Path> paths = ImageUtils.getBoundaries(image2, offset);
    if (paths.isEmpty) {
      return;
    }
    return;
    if (paths.length == 1) {
      // _controller.addPens(DrawablePen(paint: _controller.currentPaint(), path: paths.first, drawMode: _controller.drawMode, lastPosition: offset));
    } else {
      for (int i = 0; i < paths.length; i++) {
        // var currentPaint = _controller.currentPaint();
        if (i == 0) {
          // _controller.addPens(DrawablePen(paint: currentPaint, path: paths.first, drawMode: _controller.drawMode, lastPosition: offset));
        } else {
          // _controller.addPens(DrawablePen(paint: currentPaint..color = _controller.background, path: paths[i], drawMode: _controller.drawMode, lastPosition: offset));
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
    _controller.startDraw();
    if (currentPen != null) {
      return;
    }
    lastPointerId = details.pointer;
    if (_controller.drawMode == DrawMode.floodFill) {
      getFloodFillPath(details.localPosition);
    } else {
      currentPen = DrawablePen(
        paintWidth: _controller.currentStrokeWidth(_controller.drawMode),
        paths: [DrawPosition(x: details.localPosition.dx, y: details.localPosition.dy)],
        drawMode: _controller.drawMode,
        lastPosition: DrawPosition(x: details.localPosition.dx, y: details.localPosition.dy),
      )
        ..buildPaint(_controller)
        ..buildPath();
      _controller.addPens(currentPen!);
    }
  }

  onPointMove(PointerMoveEvent details) {
    if (details.pointer != lastPointerId) {
      return;
    }
    if (_controller.drawMode == DrawMode.floodFill) {
    } else {
      currentPen!.path!.lineTo(details.localPosition.dx, details.localPosition.dy);
      currentPen!.paths.add(DrawPosition(x: details.localPosition.dx, y: details.localPosition.dy));
      currentPen!.lastPosition = DrawPosition(x: details.localPosition.dx, y: details.localPosition.dy);
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
        currentPen!.path!.lineTo(details.localPosition.dx, details.localPosition.dy);
        currentPen!.paths.add(DrawPosition(x: details.localPosition.dx, y: details.localPosition.dy));
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
        currentPen!.path!.lineTo(details.localPosition.dx, details.localPosition.dy);
        currentPen!.paths.add(DrawPosition(x: details.localPosition.dx, y: details.localPosition.dy));
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
          if (_controller.activePens.isNotEmpty && _controller.activePens.last.drawMode == DrawMode.camera) {
            return;
          }
          onPointDown(details);
        },
        onPointerMove: (details) {
          if (_controller.activePens.isNotEmpty && _controller.activePens.last.drawMode == DrawMode.camera) {
            return;
          }
          onPointMove(details);
        },
        onPointerUp: (details) {
          if (_controller.activePens.isNotEmpty && _controller.activePens.last.drawMode == DrawMode.camera) {
            return;
          }
          onPointUp(details);
        },
        onPointerCancel: (details) {
          if (_controller.activePens.isNotEmpty && _controller.activePens.last.drawMode == DrawMode.camera) {
            return;
          }
          onPointCancel(details);
        },
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

  Future<ui.Image?> getScreenShot(double ratio) async {
    var image = await getBitmapFromContext(screenShotKey.currentContext!, pixelRatio: ratio);
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
    List<DrawablePen> pens = _controller.activePens;
    var pick = pens.pick((t) => t.drawMode == DrawMode.camera);
    if (pick != null) {
      pens = [pick];
    }
    return RepaintBoundary(
      key: screenShotKey,
      child: CustomPaint(
        painter: DrawablePainter(
          pens: pens,
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
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height),
        Paint()
          ..style = PaintingStyle.fill
          ..color = backgroundColor);
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    DrawPosition? eraserPosition;
    for (var value in pens) {
      if (value.drawMode == DrawMode.camera) {
        if (value.cameraImage != null) {
          var targetCoverRect = ImageUtils.getTargetCoverRect(size, Size(value.cameraImage!.image.width.toDouble(), value.cameraImage!.image.height.toDouble()));
          canvas.drawImageRect(
              value.cameraImage!.image, Rect.fromLTWH(0, 0, value.cameraImage!.image.width.toDouble(), value.cameraImage!.image.height.toDouble()), targetCoverRect, Paint());
        }
      } else {
        canvas.drawPath(value.path!, value.paint!);
        if (value.drawMode == DrawMode.eraser) {
          if (value.lastPosition != null) {
            eraserPosition = value.lastPosition;
          }
        }
      }
    }
    canvas.restore();
    if (eraserPosition != null) {
      canvas.drawCircle(
          ui.Offset(eraserPosition.x, eraserPosition.y),
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

class DrawableRecord {
  String text;
  String? cameraFilePath;
  late List<DrawablePen> activePens;
  late List<DrawablePen> checkMatePens;
  late List<String> resultPaths;
  int updateDt;

  DrawableRecord({
    this.text = '',
    this.cameraFilePath,
    List<DrawablePen>? activePens,
    List<DrawablePen>? checkMatePens,
    List<String>? resultPaths,
    this.updateDt = 0,
  }) {
    this.activePens = activePens ?? [];
    this.checkMatePens = checkMatePens ?? [];
    this.resultPaths = resultPaths ?? [];
  }

  factory DrawableRecord.fromJson(Map<String, dynamic> json) {
    DrawableRecord result = DrawableRecord();
    if (json['text'] != null) {
      result.text = json['text'];
    }
    if (json['cameraFilePath'] != null) {
      result.cameraFilePath = json['cameraFilePath'];
    }
    if (json['activePens'] != null) {
      result.activePens = (json['activePens'] as List).map((e) => DrawablePen.fromJson(e)).toList();
    }
    if (json['checkMatePens'] != null) {
      result.checkMatePens = (json['checkMatePens'] as List).map((e) => DrawablePen.fromJson(e)).toList();
    }
    if (json['resultPaths'] != null) {
      result.resultPaths = json['resultPaths'];
    }
    if (json['updateDt'] != null) {
      result.updateDt = json['updateDt'];
    }
    return result;
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'activePens': activePens.map((e) => e.toJson()).toList(),
        'checkMatePens': checkMatePens.map((e) => e.toJson()).toList(),
        'resultPaths': resultPaths,
        'updateDt': updateDt,
        'cameraFilePath': cameraFilePath,
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class DrawablePen {
  double paintWidth;
  late List<DrawPosition> paths;
  DrawPosition? lastPosition;
  late DrawMode drawMode;
  Path? path;
  Paint? paint;
  String? filePath;
  ImageInfo? cameraImage;

  DrawablePen({
    this.paintWidth = 0,
    List<DrawPosition>? paths,
    DrawMode? drawMode,
    this.lastPosition,
    this.paint,
    this.filePath,
  }) {
    this.paths = paths ?? [];
    this.drawMode = drawMode ?? DrawMode.paint;
  }

  factory DrawablePen.fromJson(Map<String, dynamic> json) {
    DrawablePen pen = DrawablePen();
    if (json['paintWidth'] != null) {
      pen.paintWidth = json['paintWidth'];
    }
    if (json['paths'] != null) {
      pen.paths = (json['paths'] as List).map((e) => DrawPosition.fromJson(e)).toList();
    }
    if (json['lastPosition'] != null) {
      pen.lastPosition = DrawPosition.fromJson(json['lastPosition']);
    }
    if (json['drawMode'] != null) {
      pen.drawMode = DrawModeEx.build(json['drawMode']);
    }
    if (json['filePath'] != null) {
      pen.filePath = json['filePath'];
    }
    return pen;
  }

  Map<String, dynamic> toJson() {
    var result = {
      'paintWidth': paintWidth,
      'paths': paths.map((e) => e.toJson()).toList(),
      'drawMode': drawMode.value(),
      'filePath': filePath,
    };
    if (lastPosition != null) {
      result['lastPosition'] = lastPosition!.toJson();
    }
    return result;
  }

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  buildPaint(DrawableController controller) {
    paint = Paint()
      ..isAntiAlias = true
      ..color = controller.currentColor(drawMode)
      ..blendMode = controller.currentBlendMode(drawMode)
      ..strokeWidth = paintWidth
      ..strokeCap = controller.currentStrokeCap(drawMode)
      ..style = controller.currentPaintingStyle(drawMode);
  }

  buildPath() {
    path = Path();
    if (paths.isNotEmpty) {
      path!.moveTo(paths.first.x, paths.first.y);
      for (int i = 0; i < paths.length; i++) {
        if (i != 0) {
          var value = paths[i];
          path!.lineTo(value.x, value.y);
        }
      }
    }
  }

  buildImage() async {
    if (filePath != null) {
      if (File(filePath!).existsSync()) {
        cameraImage = await SyncFileImage(file: File(filePath!)).getImage();
      } else {
        filePath == null;
      }
    }
  }
}

class DrawPosition {
  double x;
  double y;

  DrawPosition({this.x = 0, this.y = 0});

  factory DrawPosition.fromJson(Map<String, dynamic> json) {
    DrawPosition result = DrawPosition();
    if (json['x'] != null) {
      result.x = json['x'];
    }
    if (json['y'] != null) {
      result.y = json['y'];
    }
    return result;
  }

  Map<String, dynamic> toJson() => {'x': x, 'y': y};

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
