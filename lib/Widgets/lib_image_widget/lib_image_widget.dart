import 'dart:ui' as ui;

import 'package:image/image.dart' as imgLib;

import '../../Common/importFile.dart';
import '../background_card.dart';

class LibImageWidget extends StatelessWidget {
  ui.Image image;

  double width;
  double height;

  LibImageWidget({
    super.key,
    required this.image,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    double scale = width / image.width;
    double yScale = height / image.height;
    if (yScale < scale) {
      scale = yScale;
    }
    return Container(
      alignment: Alignment.center,
      child: Transform.scale(
        scale: scale,
        child: CustomPaint(
          painter: BackgroundPainter(
            bgColor: Colors.transparent,
            w: 10,
            h: 10,
          ),
          foregroundPainter: LibImagePainter(image: image),
        ),
      ),
    );
  }
}

class LibImagePainter extends CustomPainter {
  ui.Image image;

  LibImagePainter({required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    var dx = (image.width - size.width) / 2;
    var dy = (image.height - size.height) / 2;
    canvas.drawImage(image, Offset(-dx, -dy), Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

Future<ui.Image> toImage(imgLib.Image image) async {
  final c = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    image.data.buffer.asUint8List(),
    image.width,
    image.height,
    ui.PixelFormat.rgba8888,
    (ui.Image image) {
      c.complete(image);
    },
  );
  return c.future;
}
