import 'package:cartoonizer/common/importFile.dart';
import 'package:flutter/material.dart';

typedef FloatCallback = void Function(double);

class GridSlider extends StatefulWidget {
  int minVal = 0;
  int maxVal = 100;
  double currentPos = 50;
  final FloatCallback onChanged;
  final VoidCallback onEnd;

  GridSlider({required this.minVal, required this.maxVal, required this.currentPos, required this.onChanged, required this.onEnd});

  @override
  _GridSliderState createState() => _GridSliderState();
}

class _GridSliderState extends State<GridSlider> {
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onPanUpdate: (details) {
        widget.currentPos -= details.delta.dx / 10;
        if (widget.currentPos > widget.maxVal) widget.currentPos = widget.maxVal.toDouble();
        if (widget.currentPos < widget.minVal) widget.currentPos = widget.minVal.toDouble();
        widget.onChanged(widget.currentPos);
        setState(() {
          widget.currentPos;
        });
      },
      onPanEnd: (details) {
        widget.onEnd();
      },
      child: Container(
        width: width,
        height: 26,
        child: CustomPaint(
          painter: MyPainter(minVal: widget.minVal, maxVal: widget.maxVal, currentPos: widget.currentPos, screenWidth: width),
        ),
      ),
    );
  }
}

class MyPainter extends CustomPainter {
  int minVal = 0;
  int maxVal = 100;
  double currentPos;
  double screenWidth = 100;

  MyPainter({required this.minVal, required this.maxVal, required this.currentPos, required this.screenWidth});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color(0xff999999)
      ..strokeWidth = 1
      ..strokeCap = StrokeCap.round;

    Paint paintBold = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    Paint paintMiddleBold = Paint()
      ..color = Color(0xFFFD4EF4)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    int range = maxVal - minVal;
    // int midrange = (range / 2).floor() + currentPos;
    for (int i = 0; i < range; i++) {
      double xpos = screenWidth / 2 + (i - currentPos + minVal) * 10;
      if (i % 10 == 0) {
        canvas.drawLine(
          Offset(xpos, 6),
          Offset(xpos, 20),
          paintBold,
        );
      } else {
        canvas.drawLine(
          Offset(xpos, 8),
          Offset(xpos, 18),
          paint,
        );
      }
    }
    canvas.drawLine(
      Offset(screenWidth / 2, 1),
      Offset(screenWidth / 2, 25),
      paintMiddleBold,
    );
  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) {
    return oldDelegate.currentPos != currentPos;
  }
}
