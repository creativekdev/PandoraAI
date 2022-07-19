import 'package:cartoonizer/Common/importFile.dart';

class AppProgressBar extends StatefulWidget {
  Color backgroundColor;
  late List<Color> loadingColors;
  int progress;
  double dashSize;
  Duration duration;

  AppProgressBar({
    Key? key,
    this.backgroundColor = Colors.grey,
    List<Color>? loadingColors,
    this.progress = 10,
    this.dashSize = 6,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key) {
    this.loadingColors = loadingColors ?? [Colors.blue, Colors.yellow];
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
  double offset = 0;

  bool animating = false;
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    backgroundColor = widget.backgroundColor;
    loadingColors = widget.loadingColors;
    progress = widget.progress;
    dashSize = widget.dashSize;
    offset = -dashSize;
    animationController = AnimationController(vsync: this, duration: widget.duration);
    animationController.addListener(() {
      if (mounted) {
        setState(() {
          offset = (animationController.value - 0.5) * 2 * dashSize;
        });
      }
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
    super.dispose();
    animationController.dispose();
  }

  @override
  void didUpdateWidget(AppProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    backgroundColor = widget.backgroundColor;
    loadingColors = widget.loadingColors;
    progress = widget.progress;
    dashSize = widget.dashSize;
    offset = -dashSize;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomPaint(
            painter: ProgressPainter(dashSize: dashSize, loadingColors: loadingColors, offset: offset),
          ),
          flex: progress,
        ),
        Expanded(
          child: Container(
            width: double.maxFinite,
            height: dashSize,
            color: backgroundColor,
          ),
          flex: 100 - progress,
        )
      ],
    ).intoContainer(width: double.maxFinite, height: dashSize);
  }
}

class ProgressPainter extends CustomPainter {
  double dashSize;
  List<Color> loadingColors;
  double offset;
  List<Paint> paintList = [];

  ProgressPainter({
    required this.dashSize,
    required this.loadingColors,
    required this.offset,
  }) : super() {
    for (var value in loadingColors) {
      paintList.add(Paint()
        ..strokeWidth = 1
        ..style = PaintingStyle.fill
        ..color = value);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
