import 'dart:math';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/importFile.dart';

class LinearMaskClipper extends CustomClipper<Path> {
  double progress;

  LinearMaskClipper({required this.progress});

  @override
  ui.Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * progress, 0)
      ..lineTo(size.width * progress, size.height)
      ..lineTo(0, size.height)
      ..lineTo(0, 0);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class BezierMaskClipper extends CustomClipper<Path> {
  double x;
  double y;
  double progress;
  double ptX;
  double ptY;

  BezierMaskClipper({
    required this.x,
    required this.y,
    required this.progress,
    this.ptX = 80,
    this.ptY = 50,
  });

  @override
  ui.Path getClip(Size size) {
    var path = Path();
    Offset center = Offset(size.width * x, size.height * y);
    // Offset topLeft = Offset(center.dx - progress * size.width, center.dy - progress * size.height);
    // Offset topRight = Offset(center.dx + progress * size.width, center.dy - progress * size.height);
    // Offset bottomLeft = Offset(center.dx - progress * size.width, center.dy + progress * size.height);
    // Offset bottomRight = Offset(center.dx + progress * size.width, center.dy + progress * size.height);
    Offset start = Offset(
      center.dx - progress * size.width,
      center.dy - progress * size.height,
    );
    Offset end = Offset(
      center.dx + progress * size.width,
      center.dy + progress * size.height,
    );
    Offset topLeft = Offset(
      start.dx + progress * ptX,
      start.dy - progress * ptY,
    );
    Offset bottomLeft = Offset(
      start.dx - progress * ptX,
      start.dy + progress * ptY,
    );
    Offset topRight = Offset(
      end.dx + progress * ptX,
      end.dy - progress * ptY,
    );
    Offset bottomRight = Offset(
      end.dx - progress * ptX,
      end.dy + progress * ptY,
    );
    path.moveTo(topLeft.dx, topLeft.dy);
    // path.lineTo(topRight.dx, topRight.dy);
    // path.lineTo(bottomRight.dx, bottomRight.dy);
    // path.lineTo(bottomLeft.dx, bottomLeft.dy);

    /// 绘制贝塞尔曲线
    path.quadraticBezierTo(
      (topRight.dx + topLeft.dx) / 2 + progress * ptX * 5,
      (topRight.dy + topLeft.dy) / 2 - progress * ptY * 5,
      topRight.dx,
      topRight.dy,
    );
    path.quadraticBezierTo(
      bottomRight.dx + progress * ptX * 1.5,
      (bottomRight.dy + topRight.dy) / 2 + progress * ptY * 1.5,
      bottomRight.dx,
      bottomRight.dy,
    );
    path.quadraticBezierTo(
      (bottomLeft.dx + bottomRight.dx) / 2 - progress * ptX * 8,
      bottomLeft.dy + progress * ptY * 8,
      bottomLeft.dx,
      bottomLeft.dy,
    );
    path.quadraticBezierTo(
      topLeft.dx - progress * ptX,
      (topLeft.dy + bottomLeft.dy) / 2 - progress * ptY,
      topLeft.dx,
      topLeft.dy,
    );
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
class CircleMaskClipper extends CustomClipper<Path> {
  double x;
  double y;
  double progress;

  double m;

  CircleMaskClipper({
    this.x = 0.5,
    this.y = 0.5,
    this.progress = 0,
    this.m = 1,
  });

  @override
  ui.Path getClip(Size size) {
    return Path()
      ..addOval(Rect.fromCenter(
        center: Offset(size.width * x, size.height * y),
        width: max(size.width, size.height) * 1.2 * progress * m,
        height: max(size.width, size.height) * 1.2 * progress * m,
      ));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}

class OvalMaskClipper extends CustomClipper<Path> {
  double progress;
  double startPerX;
  double startPerY;

  double endPerX;
  double endPerY;

  OvalMaskClipper({
    required this.progress,
    required this.startPerX,
    required this.startPerY,
    required this.endPerX,
    required this.endPerY,
  });

  @override
  ui.Path getClip(Size size) {
    double startX = size.width * startPerX;
    double startY = size.height * startPerY;
    Path path = new Path();
    double endX = size.width * endPerX;
    double endY = size.height * endPerY;
    double x = startX - (startX - endX) * progress;
    double y = startY - (startY - endY) * progress;
    double w = (size.width * 2.1) * progress;
    double h = (size.height * 2.1) * progress;
    path.addOval(Rect.fromCenter(center: Offset(x, y), width: w, height: h));
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }
}
