import 'package:cartoonizer/Common/importFile.dart';
import 'dart:math' as math;

class AppCircleProgressBar extends StatelessWidget {
  Color backgroundColor;
  late List<Color> loadingColors;
  late double progress;
  late BorderRadius borderRadius;
  double size;
  double ringWidth;

  AppCircleProgressBar({
    Key? key,
    required this.size,
    this.ringWidth = 4,
    this.backgroundColor = Colors.grey,
    List<Color>? loadingColors,
    double progress = 0,
  }) : super(key: key) {
    this.progress = progress > 1 ? 1 : progress;
    this.loadingColors = loadingColors ?? [Colors.blue, Colors.yellow];
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GradientCircularProgressPainter(
        radius: size / 2,
        strokeWidth: ringWidth,
        colors: loadingColors,
        value: progress,
        strokeCapRound: true,
        backgroundColor: backgroundColor,
      ),
      child: SizedBox(
        width: size,
        height: size,
      ),
    );
  }
}

//实现画笔
class _GradientCircularProgressPainter extends CustomPainter {
  final double strokeWidth;
  final bool strokeCapRound;
  final double value;
  final Color backgroundColor;
  final List<Color> colors;
  final double total;
  final double radius;
  final List<double>? stops;

  _GradientCircularProgressPainter({
    this.strokeWidth = 10.0,
    this.strokeCapRound = false,
    this.backgroundColor = const Color(0xFFEEEEEE),
    required this.radius,
    this.total = 2 * math.pi,
    required this.colors,
    this.stops,
    required this.value,
  });

  @override
  void paint(Canvas canvas, Size size) {
    canvas.rotate(-math.pi / 2);
    canvas.translate(-size.width, 0);

    size = Size.fromRadius(radius);
    double _offset = strokeWidth / 2.0;
    double _value = value;
    _value = _value.clamp(.0, 1.0) * total;
    double _start = .0;

    if (strokeCapRound) {
      _start = math.asin(strokeWidth / (size.width - strokeWidth));
    }

    Rect rect = Offset(_offset, _offset) & Size(size.width - strokeWidth, size.height - strokeWidth);

    var bgPaint = Paint()
      ..strokeCap = strokeCapRound ? StrokeCap.round : StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth;
    if (backgroundColor != Colors.transparent) {
      bgPaint.color = backgroundColor;
      canvas.drawArc(rect, _start, total, false, bgPaint);
    }

    var paint = Paint()
      ..strokeCap = strokeCapRound ? StrokeCap.round : StrokeCap.butt
      ..style = PaintingStyle.stroke
      ..isAntiAlias = true
      ..strokeWidth = strokeWidth;

    if (_value > 0) {
      paint.shader = SweepGradient(
        startAngle: 0.0,
        endAngle: _value,
        colors: colors,
        stops: stops,
      ).createShader(rect);

      canvas.drawArc(rect, _start, _value, false, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
