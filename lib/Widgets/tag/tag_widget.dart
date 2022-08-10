import 'dart:math';

import 'package:cartoonizer/Common/importFile.dart';

class Tag extends StatelessWidget {
  final Widget child;
  final Color color;
  double width;
  double height;
  TagGravity gravity;

  Tag({
    Key? key,
    required this.child,
    this.color = Colors.red,
    required this.height,
    required this.width,
    this.gravity = TagGravity.topLeft,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: width,
      width: height,
      child: CustomPaint(
        painter: _TagPainter(color: color, radius: 8, gravity: gravity),
        child: Transform.rotate(
          angle: getAngle(),
          child: child,
        ).intoContainer(
          margin: getMargin(),
        ),
      ),
    );
  }

  double getAngle() {
    switch (gravity) {
      case TagGravity.topLeft:
      case TagGravity.bottomRight:
        return -pi / 4;
      case TagGravity.bottomLeft:
      case TagGravity.topRight:
        return pi / 4;
    }
  }

  EdgeInsets getMargin() {
    switch (gravity) {
      case TagGravity.topLeft:
        return EdgeInsets.only(left: width / 3.8);
      case TagGravity.topRight:
        return EdgeInsets.only(left: width / 6, top: width / 6);
      case TagGravity.bottomLeft:
        return EdgeInsets.only(top: width / 1.6);
      case TagGravity.bottomRight:
        return EdgeInsets.only(top: width / 2.4, left: width / 3);
    }
  }
}

enum TagGravity {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class _TagPainter extends CustomPainter {
  late Paint backgroundPaint;
  late TagGravity gravity;
  double radius = 0;

  _TagPainter({
    Color color = Colors.transparent,
    TagGravity gravity = TagGravity.topLeft,
    double radius = 0,
  }) {
    backgroundPaint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.fill
      ..color = color;
    this.gravity = gravity;
    this.radius = radius;
  }

  @override
  void paint(Canvas canvas, Size size) {
    Path path = new Path();
    switch (gravity) {
      case TagGravity.topLeft:
        createPathTopLeft(size, path);
        break;
      case TagGravity.topRight:
        createPathTopRight(size, path);
        break;
      case TagGravity.bottomLeft:
        createPathBottomLeft(size, path);
        break;
      case TagGravity.bottomRight:
        createPathBottomRight(size, path);
        break;
    }
    canvas.drawPath(path, backgroundPaint);
  }

  void createPathTopLeft(Size size, Path path) {
    path.moveTo(0, size.height);
    path.lineTo(0, radius);
    for (double x = 0; x <= radius; x += 0.01) {
      path.lineTo(radius - x, -(sqrt(radius * radius - x * x) - radius));
    }
    path.lineTo(radius, 0);
    path.lineTo(size.width, 0);
    path.close();
  }

  void createPathTopRight(Size size, Path path) {
    path.moveTo(0, 0);
    path.lineTo(size.width - radius, 0);
    for (double x = 0; x <= radius; x += 0.01) {
      path.lineTo(size.width - radius + x, -sqrt(radius * radius - x * x) + radius);
    }
    path.lineTo(size.width, radius);
    path.lineTo(size.width, size.height);
    path.close();
  }

  void createPathBottomLeft(Size size, Path path) {
    path.moveTo(0, 0);
    path.lineTo(0, size.height - radius);
    for (double x = 0; x <= radius; x += 0.01) {
      path.lineTo(radius - x, sqrt(radius * radius - x * x) + size.height - radius);
    }
    path.lineTo(radius, size.height);
    path.lineTo(size.width, size.height);
    path.close();
  }

  void createPathBottomRight(Size size, Path path) {
    path.moveTo(size.width, 0);
    path.lineTo(size.width, size.height - radius);
    for (double x = 0; x <= radius; x += 0.01) {
      path.lineTo(size.width - radius + x, sqrt(radius * radius - x * x) + size.height - radius);
    }
    path.lineTo(size.width - radius, size.height);
    path.lineTo(0, size.height);
    path.close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
