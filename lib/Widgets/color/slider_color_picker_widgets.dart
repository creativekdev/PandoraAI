import 'dart:math';

import 'package:cartoonizer/Common/importFile.dart';

class SliderColorPicker extends StatefulWidget {
  double progress;
  Color selectorColor;
  bool visible;
  Function(Color selectorColor, double opacity) onChange;

  SliderColorPicker({
    super.key,
    required this.progress,
    required this.selectorColor,
    required this.onChange,
    required this.visible,
  });

  @override
  State<SliderColorPicker> createState() => _SliderColorPickerState();
}

class _SliderColorPickerState extends State<SliderColorPicker> {
  late double progress;
  late Color selectorColor;
  double widgetWidth = 0;
  bool visible = true;

  @override
  void initState() {
    super.initState();
    progress = widget.progress;
    selectorColor = widget.selectorColor;
    visible = widget.visible;
    delay(() {
      setState(() {
        widgetWidth = ScreenUtil.getCurrentWidgetSize(context).width;
      });
    });
  }

  @override
  void didUpdateWidget(covariant SliderColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    visible = widget.visible;
    progress = widget.progress;
    selectorColor = widget.selectorColor;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (DragStartDetails details) {
          setState(() {
            progress = details.localPosition.dx / widgetWidth;
          });
          // widget.onChange.call(selectorColor, progress);
        },
        onHorizontalDragUpdate: (DragUpdateDetails details) {
          setState(() {
            progress = details.localPosition.dx / widgetWidth;
          });
          // widget.onChange.call(selectorColor, progress);
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          // setState(() {
          //   progress = details.localPosition.dx / widgetWidth;
          // });
          widget.onChange.call(selectorColor, progress);
        },
        onTapDown: (TapDownDetails details) {
          setState(() {
            progress = details.localPosition.dx / widgetWidth;
          });
          // widget.onChange.call(selectorColor, progress);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(38),
            color: Colors.white,
          ),
          child: Container(
            width: double.maxFinite,
            height: $(38),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(38),
              gradient: LinearGradient(
                colors: [selectorColor.withOpacity(1), selectorColor.withOpacity(0)],
              ),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: $(18)),
              child: CustomPaint(
                painter: SliderIndicatorPainter(max(0, min(progress, 1)), selectorColor),
              ).visibility(visible: visible),
            ),
          ),
        ),
      ),
    );
  }
}

class SliderIndicatorPainter extends CustomPainter {
  final double position;
  Color selectorColor;

  SliderIndicatorPainter(this.position, this.selectorColor);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    paint.strokeWidth = 2.4;
    canvas.drawCircle(Offset(size.width * position, size.height / 2), $(18), paint);
  }

  @override
  bool shouldRepaint(SliderIndicatorPainter old) {
    return true;
  }
}
