import 'dart:math';

import 'package:cartoonizer/common/importFile.dart';

enum SliderDirection { vertical, horizontal }

class SliderBar extends StatelessWidget {
  final Size size;
  final Widget? child;

  SliderBar({this.child, this.size = const Size(24, 24)});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: child ?? thumb(),
    );
  }

  Widget thumb() {
    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(min(size.width, size.height))),
    );
  }
}

// ignore: must_be_immutable
class CustomSlider extends StatelessWidget {
  //UI
  //不论竖着还是横着，width是短边，height是长边，短边默认值20，长边撑满
  final double width;
  final double height;

  final Color? activeTrackColor;

  final SliderBar? sliderBar;

  final double value;
  final Function(double, bool) valueChanged;

  final SliderDirection direction;
  final Decoration? background;

  CustomSlider(
      {required this.value,
      required this.valueChanged,
      this.width = 24,
      this.height = double.infinity,
      this.direction = SliderDirection.horizontal,
      this.background,
      this.activeTrackColor,
      this.sliderBar});

  double dx = 0;
  double maxX = 0;

  bool get isVertical => direction == SliderDirection.vertical;

  @override
  Widget build(BuildContext context) {
    Decoration decoration = this.background ?? BoxDecoration(color: Colors.grey[300]);

    return GestureDetector(
      child: Stack(
        alignment: AlignmentDirectional.center,
        children: [
          Container(
              height: isVertical ? height : width,
              width: isVertical ? width : height,
              child: CustomPaint(
                painter: SliderPainter(
                  (double maxDx) {
                    maxX = maxDx;
                    return value * maxDx;
                  },
                  vertical: isVertical,
                  activeTrackColor: activeTrackColor,
                ),
              ),
              decoration: decoration),
          Align(child: sliderBar, alignment: FractionalOffset(isVertical ? 0.5 : value, isVertical ? 1 - value : 0.5)),
        ],
        // ).intoContainer(width: isVertical ? max(sliderBar?.size.width ?? 0, width) : height, height: isVertical ? height : null),
      ).intoContainer(width: width,height: height),
      onTapDown: (details) {
        updateDx(getPoint(context, details.globalPosition));
      },
      onTapUp: (details) {
        setValue(true);
      },
      onPanUpdate: (details) {
        updateDx(getPoint(context, details.globalPosition));
      },
      onPanEnd: (details) {
        setValue(true);
      },
    );
  }

  Offset getPoint(BuildContext context, Offset globalPosition) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    return renderBox.globalToLocal(globalPosition);
  }

  void updateDx(Offset value) {
    dx = isVertical ? value.dy : value.dx;

    dx = dx < 0 ? 0 : dx;
    dx = dx > maxX ? maxX : dx;

    setValue(false);
  }

  void setValue(bool isEnd) {
    valueChanged(isVertical ? ((maxX - dx) / maxX) : dx / maxX, isEnd);
  }
}

class SliderPainter extends CustomPainter {
  final Color? activeTrackColor;

  final double Function(double maxDx) getDx;
  final bool vertical;

  SliderPainter(
    this.getDx, {
    this.activeTrackColor,
    this.vertical = false,
  });

  /// 初始化画笔
  var lineP = Paint()..strokeCap = StrokeCap.butt;

  var thumbP = Paint()..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    double width = vertical ? size.width : size.height;
    double height = vertical ? size.height : size.width;

    lineP.strokeWidth = width;
    lineP.color = this.activeTrackColor ?? Colors.blue;

    double dx = getDx(height);
    Offset endPoint = Offset.zero;

    double centerW = width / 2;

    /// 通过canvas画线
    if (vertical == true) {
      endPoint = Offset(centerW, height - dx);
      // canvas.drawLine(Offset(centerW, height), endPoint, lineP);
    } else {
      endPoint = Offset(dx, centerW);
      // canvas.drawLine(Offset(0, centerW), endPoint, lineP);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
