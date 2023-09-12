import 'dart:ui' as ui;

import 'package:cartoonizer/utils/img_utils.dart';
import 'package:image/image.dart' as imgLib;

import '../../common/importFile.dart';

class LibImageWidget extends StatelessWidget {
  ui.Image image;

  double width;
  double height;

  Function(Rect imageRect) onResized;

  LibImageWidget({
    super.key,
    required this.image,
    required this.width,
    required this.height,
    required this.onResized,
  });

  @override
  Widget build(BuildContext context) {
    double scale = width / image.width;
    double yScale = height / image.height;
    if (yScale < scale) {
      scale = yScale;
    }
    onResized.call(ImageUtils.getTargetCoverRect(Size(width, height), Size(image.width.toDouble(), image.height.toDouble())));
    return Container(
      alignment: Alignment.center,
      child: Transform.scale(
        scale: scale,
        child: CustomPaint(
          size: Size(width, height),
          painter: LibImagePainter(image: image),
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
  return await toImageByList(image.data.buffer.asUint8List(), image.width, image.height);
}

Future<ui.Image> toImageByList(Uint8List image, width, height) async {
  final c = Completer<ui.Image>();
  ui.decodeImageFromPixels(
    image,
    width,
    height,
    ui.PixelFormat.rgba8888,
    (ui.Image image) {
      c.complete(image);
    },
  );
  return c.future;
}
