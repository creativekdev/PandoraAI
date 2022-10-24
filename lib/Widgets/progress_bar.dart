import 'dart:math';

import 'package:cartoonizer/Common/importFile.dart';

class AppProgressBar extends StatefulWidget {
  Color backgroundColor;
  late List<Color> loadingColors;
  late int progress;
  double dashSize;
  Duration duration;
  late BorderRadius borderRadius;

  AppProgressBar({
    Key? key,
    this.backgroundColor = Colors.grey,
    List<Color>? loadingColors,
    int progress = 0,
    this.dashSize = 6,
    this.duration = const Duration(milliseconds: 500),
    BorderRadius? borderRadius,
  }) : super(key: key) {
    this.progress = progress > 999 ? 999 : progress;
    this.loadingColors = loadingColors ?? [Colors.blue, Colors.yellow];
    this.borderRadius = borderRadius ?? BorderRadius.circular(0);
  }

  @override
  State<StatefulWidget> createState() {
    return AppProgressBarState();
  }
}

class AppProgressBarState extends State<AppProgressBar> with SingleTickerProviderStateMixin {
  late Color backgroundColor;
  late List<Color> loadingColors;
  late int progress;
  late double dashSize;
  late BorderRadius borderRadius;
  double offset = 0;
  Size? size;

  bool animating = false;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    backgroundColor = widget.backgroundColor;
    loadingColors = widget.loadingColors;
    progress = widget.progress;
    dashSize = widget.dashSize;
    borderRadius = widget.borderRadius;
    offset = -dashSize;
    animationController = AnimationController(vsync: this, duration: widget.duration);
    animationController.addListener(() {
      setState(() {
        offset = (animationController.value - 0.5) * 2 * dashSize;
      });
    });
    animationController.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
          animationController.reset();
          animationController.forward();
          break;
      }
    });
    animationController.forward();
  }

  @override
  dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(AppProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    backgroundColor = widget.backgroundColor;
    loadingColors = widget.loadingColors;
    progress = widget.progress;
    dashSize = widget.dashSize;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Row(
        children: [
          Expanded(
            child: CustomPaint(
              painter: ProgressPainter(dashSize: dashSize, loadingColors: loadingColors, offset: offset, backgroundColor: backgroundColor),
            ),
            flex: progress,
          ),
          // Expanded(
          //   child: Container(
          //     decoration: BoxDecoration(
          //       gradient: LinearGradient(
          //         colors: [Color(0xffE31ECD), Color(0xff243CFF)],
          //         begin: Alignment.centerLeft,
          //         end: Alignment.centerRight,
          //       ),
          //       borderRadius: BorderRadius.circular($(32)),
          //     ),
          //   ),
          //   flex: progress,
          // ),
          Expanded(
            child: Container(
              width: double.maxFinite,
              height: dashSize,
            ),
            flex: 1000 - progress,
          )
        ],
      ).intoContainer(width: double.maxFinite, height: dashSize, color: backgroundColor),
    );
  }
}

class ProgressPainter extends CustomPainter {
  double dashSize;
  List<Color> loadingColors;
  double offset;
  List<Paint> paintList = [];
  late Paint backgroundPaint;

  late double radius;
  late double squareRadius;

  ProgressPainter({
    required this.dashSize,
    required this.loadingColors,
    required this.offset,
    required Color backgroundColor,
  }) : super() {
    for (var value in loadingColors) {
      paintList.add(Paint()
        ..strokeWidth = 1
        ..style = PaintingStyle.fill
        ..color = value);
    }
    backgroundPaint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.fill
      ..color = backgroundColor;
    radius = dashSize / 2;
    squareRadius = radius * radius;
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawProgress(canvas, size);
    drawStartMask(canvas, size, backgroundPaint);
    drawEndMask(canvas, size, backgroundPaint);
  }

  void drawProgress(Canvas canvas, Size size) {
    var width = size.width;
    var total = width ~/ dashSize + 2;
    for (var i = -1; i <= total; i++) {
      var paint = paintList[i % paintList.length];
      canvas.drawPath(
          Path()
            ..moveTo(i * dashSize + offset, -dashSize / 2)
            ..lineTo((i + 1) * dashSize + offset, -dashSize / 2)
            ..lineTo(i * dashSize + offset, dashSize / 2)
            ..lineTo((i - 1) * dashSize + offset, dashSize / 2)
            ..close(),
          paint);
    }
  }

  drawStartMask(Canvas canvas, Size size, Paint paint) {
    Path start = new Path();
    start.moveTo(0, -dashSize);
    for (double i = 0; i > -radius; i -= 0.01) {
      var x = i;
      var y = -sqrt(squareRadius - i * i);
      start.lineTo(x, y);
    }
    for (double i = -radius; i < 0; i += 0.01) {
      var x = i;
      var y = sqrt(squareRadius - i * i);
      start.lineTo(x, y);
    }
    start.lineTo(0, dashSize);
    start.lineTo(-dashSize * 4, dashSize);
    start.lineTo(-dashSize * 4, -dashSize);
    start.close();
    canvas.drawPath(start, paint);
  }

  drawEndMask(Canvas canvas, Size size, Paint paint) {
    Path end = new Path();
    end.moveTo(size.width, -dashSize);
    for (double i = 0; i < radius; i += 0.01) {
      var x = i;
      var y = -sqrt(squareRadius - i * i);
      end.lineTo(size.width + x, y);
    }
    for (double i = radius; i > 0; i -= 0.01) {
      var x = i;
      var y = sqrt(squareRadius - i * i);
      end.lineTo(size.width + x, y);
    }
    end.lineTo(size.width, dashSize);
    end.lineTo(size.width + dashSize * 4, dashSize);
    end.lineTo(size.width + dashSize * 4, -dashSize);
    end.close();
    canvas.drawPath(end, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
