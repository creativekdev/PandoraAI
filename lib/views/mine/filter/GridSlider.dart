import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/images-res.dart';
import 'package:flutter/material.dart';
class GridSlider extends StatefulWidget {
  int minVal = 0;
  int maxVal = 100;
  double currentPos = 50;
  GridSlider({required this.minVal, required this.maxVal, required this.currentPos});

  @override
  _GridSliderState createState() => _GridSliderState();
}
class _GridSliderState extends State<GridSlider> {

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return GestureDetector(
      onPanStart: (details) {
        // print('Drag started');
      },
      onPanUpdate: (details) {
        // print('Drag updated');
        // print('Delta: ${details.delta}');
        widget.currentPos -= details.delta.dx / 10;
        if(widget.currentPos > widget.maxVal) widget.currentPos = widget.maxVal.toDouble();
        if(widget.currentPos < widget.minVal) widget.currentPos = widget.minVal.toDouble();

        setState((){
          widget.currentPos;
        });
      },
      onPanEnd: (details) {
        // print('Drag ended');
      },
      child: Container(
        width: width,
        height: 50,
        child: CustomPaint(
          painter: MyPainter(minVal :widget.minVal, maxVal: widget.maxVal, currentPos : widget.currentPos, screenWidth: width),
        )
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
      ..color = Colors.grey
      ..strokeWidth = 2;

    Paint paintBold = Paint()
      ..color = Colors.white
      ..strokeWidth = 4;

    canvas.drawLine(
      Offset(screenWidth / 2, 0),
      Offset(screenWidth / 2, 40),
      paintBold,
    );

    int range = maxVal - minVal;
    // int midrange = (range / 2).floor() + currentPos;
    for(int i  = 0; i < range; i++) {
      double xpos = screenWidth / 2 + (i - currentPos) * 10;
      if(i % 5 == 0) {
        canvas.drawLine(
          Offset(xpos, 30),
          Offset(xpos, 40),
          paintBold,
        );
      }
      else {
        canvas.drawLine(
          Offset(xpos, 30),
          Offset(xpos, 40),
          paint,
        );
      }
    }
  }
  @override
  bool shouldRepaint(MyPainter oldDelegate) {
    return oldDelegate.currentPos != currentPos;
  }
}