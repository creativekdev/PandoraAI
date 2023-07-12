import 'dart:ui';

import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/views/mine/filter/Crop.dart';
import 'package:cropperx/cropperx.dart';
import 'package:flutter/material.dart';

class Decoratior extends StatelessWidget {
  late double width, height;
  Decoratior({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RectanglePainter(width: width, height: height),
    );
  }
}

class RectanglePainter extends CustomPainter {
  late double width, height;
  RectanglePainter({required this.width, required this.height});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;
    final rect1 = Rect.fromLTWH(0.0, 0.0, 50.0, 50.0);

    canvas.drawRect(rect1, paint);
    final rect2 = Rect.fromLTWH(width - 50, 0.0, 50.0, 50);
    canvas.drawRect(rect2, paint);

    final rect3 = Rect.fromLTWH(0, height - 50.0, 50, 50);
    canvas.drawRect(rect3, paint);

    final rect4 = Rect.fromLTWH(width - 50, height - 50.0, 50, 50);
    canvas.drawRect(rect4, paint);

    final rect5 = Rect.fromLTWH(width / 2 - 25, 0, 50, 50);
    canvas.drawRect(rect5, paint);

    final rect6 = Rect.fromLTWH(0, height / 2 - 25, 50, 50);
    canvas.drawRect(rect6, paint);

    final rect7 = Rect.fromLTWH(width - 50, height / 2 - 25, 50, 50);
    canvas.drawRect(rect7, paint);

  }

  @override
  bool shouldRepaint(RectanglePainter oldDelegate) => false;
}

class DecorationCropper extends StatefulWidget {
  late GlobalKey cropperKey;
  late Crop crop;
  late Uint8List? byte;
  GlobalKey globalKey;
  DecorationCropper({required this.cropperKey, required this.crop, required this.byte, required this.globalKey});
  @override
  _DecorationCropperState createState() => _DecorationCropperState();
}

class _DecorationCropperState extends State<DecorationCropper> {
  double _height = 0, _width = 0;
  @override
  Widget build(BuildContext context) {

    Size size = ScreenUtil.getCurrentWidgetSize(widget.globalKey.currentContext!);
    double _ratio = widget.crop.ratios[widget.crop.isPortrait][widget.crop.selectedID];
    if(size.width / (size.height - $(6)) > _ratio) {
      _height = size.height - $(6);
      _width = (_height - $(8)) * _ratio + $(8);
    } else{
      _width = size.width;
      _height = (_width - $(8)) / _ratio + $(8);
    }
    return Stack(
      children: [
        Decoratior(width: _width, height: _height),
        Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.transparent,
                width: $(2),
              ),
            ),
            child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: $(2),
                  ),
                ),
                child: Cropper(
                  overlayColor: Colors.white,
                  cropperKey: widget.cropperKey,
                  overlayType: OverlayType.grid,
                  rotationTurns: 0,
                  aspectRatio: widget.crop.ratios[widget.crop.isPortrait][widget.crop.selectedID],
                  image: Image.memory(widget.byte!, fit: BoxFit.contain,),
                  onScaleStart: (details) {
                    // todo: define started action.
                  },
                  onScaleUpdate: (details) {
                    // todo: define updated action.
                  },
                  onScaleEnd: (details) {
                    // todo: define ended action.
                  },
                )
            )
        )
      ],
    );
  }
}