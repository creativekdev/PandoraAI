import 'dart:io';

import 'package:cartoonizer/common/importFile.dart';
import 'package:cropperx/cropperx.dart';

import 'Crop.dart';

class ImDecoratior extends StatelessWidget {
  late double width, height;

  ImDecoratior({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: ImRectanglePainter(width: width, height: height),
    );
  }
}

class ImRectanglePainter extends CustomPainter {
  late double width, height;

  ImRectanglePainter({required this.width, required this.height});

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
  bool shouldRepaint(ImRectanglePainter oldDelegate) => false;
}

typedef UpdateSacle = void Function(ScaleUpdateDetails details, double ratio);
typedef EndSacle = void Function(ScaleEndDetails details, double ratio);

class ImCropper extends StatefulWidget {
  final GlobalKey cropperKey;
  final Crop crop;
  final String filePath;
  final UpdateSacle updateSacle;
  final EndSacle endSacle;

  ImCropper({required this.cropperKey, required this.crop, required this.filePath, required this.updateSacle, required this.endSacle});

  @override
  _ImCropperState createState() => _ImCropperState();
}

class _ImCropperState extends State<ImCropper> {
  double _height = 0,
      _width = 0;
  bool isTap = false;
  late UniqueKey _uniqueKey;


  @override
  Widget build(BuildContext context) {
    if (isTap == false) {
      _uniqueKey = UniqueKey();
    }
    Size size = Size(ScreenUtil.screenSize.width, ScreenUtil.screenSize.height - $(153) - ScreenUtil.getBottomPadding(context) - ScreenUtil.getNavigationBarHeight());
    double _ratio = widget.crop.ratios[widget.crop.isPortrait][widget.crop.selectedID];
    if (size.width / (size.height - $(6)) > _ratio) {
      _height = size.height - $(6);
      _width = (_height - $(8)) * _ratio + $(8);
    } else {
      _width = size.width;
      _height = (_width - $(8)) / _ratio + $(8);
    }
    return Stack(
      children: [
        ImDecoratior(width: _width, height: _height),
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
                key: _uniqueKey,
                overlayColor: Colors.white,
                cropperKey: widget.cropperKey,
                overlayType: OverlayType.grid,
                rotationTurns: 0,
                aspectRatio: widget.crop.ratios[widget.crop.isPortrait][widget.crop.selectedID],
                image: Image.file(File(widget.filePath), fit: BoxFit.fill),
                onScaleStart: (details) {},
                onScaleUpdate: (details) {
                  if (details.scale > 0) {
                    isTap = true;
                  }
                  widget.updateSacle(details, widget.crop.ratios[widget.crop.isPortrait][widget.crop.selectedID]);
                },
                onScaleEnd: (details) {
                  widget.endSacle(details, widget.crop.ratios[widget.crop.isPortrait][widget.crop.selectedID]);
                },
              )),
        ),
      ],
    );
  }
}
