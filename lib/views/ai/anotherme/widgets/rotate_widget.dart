import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/utils/sensor_helper.dart';

class RotateWidget extends StatefulWidget {
  Widget child;
  PoseState pose;

  RotateWidget({
    Key? key,
    required this.child,
    required this.pose,
  }) : super(key: key);

  @override
  State<RotateWidget> createState() => _RotateWidgetState();
}

class _RotateWidgetState extends State<RotateWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation curvedAnimation;
  PoseState lastPose = PoseState.stand;

  late Widget child;
  late StreamSubscription poseListen;

  double startAngle = 0;
  double endAngle = 0;

  @override
  void initState() {
    super.initState();
    child = widget.child;
    lastPose = widget.pose;
    endAngle = lastPose.rotate();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    curvedAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeInOutCubic);
    poseListen = EventBusHelper().eventBus.on<OnPoseStateChangeEvent>().listen((event) {
      if (event.data != lastPose) {
        if (_controller.isAnimating) {
          _controller.stop();
        }
        startAngle = lastPose.rotate() * curvedAnimation.value;
        lastPose = event.data!;
        endAngle = lastPose.rotate();
        _controller.reset();
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant RotateWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    child = widget.child;
  }

  @override
  void dispose() {
    _controller.dispose();
    poseListen.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: startAngle + (endAngle - startAngle) * curvedAnimation.value,
          child: child,
        );
      },
      child: child,
    );
  }
}
