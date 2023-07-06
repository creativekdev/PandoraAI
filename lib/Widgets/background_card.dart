import 'package:cartoonizer/common/importFile.dart';
import 'dart:math' as math;

class BackgroundCard extends StatelessWidget {
  final Color bgColor;
  final Widget child;

  const BackgroundCard({Key? key, required this.bgColor, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BackgroundPainter(
        bgColor: bgColor,
        w: 10,
        h: 10,
      ),
      child: child,
    );
  }
}

class BackgroundPainter extends CustomPainter {
  double w;
  double h;
  late List<Color> colors;
  late List<Paint> paints;
  Color bgColor;
  late Paint bgPaint;

  BackgroundPainter({
    this.w = 10,
    this.h = 6,
    List<Color>? colors,
    required this.bgColor,
  }) {
    this.colors = colors ?? [Colors.grey.shade300, Colors.grey.shade400];
    paints = this.colors.map((e) {
      return Paint()
        ..color = e
        ..style = PaintingStyle.fill;
    }).toList();
    bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas canvas, Size size) {
    int verticalCount = size.width ~/ w + 1;
    int horizontal = size.height ~/ h + 1;
    for (int x = 0; x < verticalCount; x++) {
      for (int y = 0; y < horizontal; y++) {
        var nx = x * w;
        var ny = y * h;
        canvas.drawRect(Rect.fromLTRB(nx, ny, math.min(nx + w, size.width), math.min(ny + h, size.height)), paints[(x + y) % paints.length]);
      }
    }
    canvas.drawRect(Rect.fromLTWH(-2, -2, size.width + 4, size.height + 4), bgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
