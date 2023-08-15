import 'dart:ui' as ui;

import 'package:cartoonizer/Widgets/lib_image_widget/lib_image_widget_controller.dart';
import 'package:image/image.dart' as imgLib;

import '../../Common/importFile.dart';
import '../background_card.dart';

class LibImageWidget extends StatefulWidget {
  const LibImageWidget({Key? key, required this.controller, required this.shownImage}) : super(key: key);
  final LibImageWidgetController controller;
  final imgLib.Image shownImage;

  @override
  State<LibImageWidget> createState() => _LibImageWidgetState(controller: controller, shownImage: shownImage);
}

class _LibImageWidgetState extends State<LibImageWidget> {
  _LibImageWidgetState({Key? key, required this.controller, required this.shownImage}) : super();
  final LibImageWidgetController controller;

  final imgLib.Image shownImage;

  @override
  void initState() {
    super.initState();
    controller.shownImage = shownImage;
  }

  @override
  Widget build(BuildContext context) {
    double scale = ScreenUtil.screenSize.width / shownImage!.width;
    double yScale = (ScreenUtil.screenSize.height - ScreenUtil.getNavigationBarHeight() - $(140) - ScreenUtil.getStatusBarHeight() - ScreenUtil.getBottomPadding(Get.context!)) /
        shownImage!.height;
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
          foregroundPainter: LibImagePainter(image: controller.shownUIImage!),
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
