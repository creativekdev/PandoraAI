import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/progress/circle_progress_bar.dart';
import 'dart:math' as math;

class SimulateProgressBar {
  static Future startLoading(
    BuildContext context, {
    required SimulateProgressBarController controller,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return _SimulateProgressBar(
          controller: controller,
        );
      },
      barrierDismissible: false,
    );
  }
}

class _SimulateProgressBar extends StatefulWidget {
  SimulateProgressBarController controller;

  _SimulateProgressBar({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  State<_SimulateProgressBar> createState() => _SimulateProgressBarState();
}

class _SimulateProgressBarState extends State<_SimulateProgressBar> with TickerProviderStateMixin {
  late SimulateProgressBarController controller;
  late AnimationController animationController;
  late CurvedAnimation animationControllerCurved;
  late AnimationController completeController;
  bool completed = false;
  List<Curve> curves = [
    Curves.linear,
    Curves.decelerate,
    Curves.ease,
    Curves.easeOut,
    Curves.easeIn,
    Curves.easeInQuart,
    Curves.easeInOut,
    Curves.easeInOutQuint,
    Curves.easeOutCubic,
  ];

  @override
  void initState() {
    super.initState();
    controller = widget.controller;
    controller._completeCall = () {
      if (!animationController.isCompleted) {
        completed = true;
      } else {
        completeController.forward();
      }
    };
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 5));
    animationControllerCurved = CurvedAnimation(parent: animationController, curve: curves[math.Random().nextInt(curves.length)]);
    completeController = AnimationController(vsync: this, duration: Duration(seconds: 2));
    animationController.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
          if (completed) {
            completeController.forward();
          }
          break;
      }
    });
    completeController.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.dismissed:
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
        case AnimationStatus.completed:
          Navigator.of(context).pop();
          break;
      }
    });
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: AnimatedBuilder(
            animation: animationControllerCurved,
            builder: (context, child) {
              return AnimatedBuilder(
                  animation: completeController,
                  builder: (context, child) {
                    return AppCircleProgressBar(
                      size: $(60),
                      backgroundColor: Colors.transparent,
                      progress: animationControllerCurved.value * 0.8 + completeController.value * 0.2,
                      loadingColors: [
                        ColorConstant.colorBlue3,
                        ColorConstant.colorBlue2,
                        ColorConstant.colorBlue,
                        ColorConstant.colorBlue2,
                        ColorConstant.colorBlue3,
                        ColorConstant.colorBlue2,
                        ColorConstant.colorBlue,
                        ColorConstant.colorBlue2,
                        ColorConstant.colorBlue3,
                      ],
                    );
                  });
            }).intoCenter(),
        onWillPop: () async {
          return false;
        });
  }
}

class SimulateProgressBarController {
  Function? _completeCall;

  loadComplete() {
    _completeCall?.call();
  }
}
