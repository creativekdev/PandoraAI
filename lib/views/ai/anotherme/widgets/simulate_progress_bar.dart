import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/progress/circle_progress_bar.dart';
import 'dart:math' as math;

class SimulateProgressBar {
  static Future startLoading(
    BuildContext context, {
    required bool needUploadProgress,
    required SimulateProgressBarController controller,
  }) {
    return showDialog(
      context: context,
      builder: (context) {
        return _SimulateProgressBar(
          controller: controller,
          needUploadProgress: needUploadProgress,
        );
      },
      barrierDismissible: false,
    );
  }
}

class _SimulateProgressBar extends StatefulWidget {
  SimulateProgressBarController controller;
  bool needUploadProgress;

  _SimulateProgressBar({
    Key? key,
    required this.needUploadProgress,
    required this.controller,
  }) : super(key: key);

  @override
  State<_SimulateProgressBar> createState() => _SimulateProgressBarState();
}

class _SimulateProgressBarState extends State<_SimulateProgressBar> with TickerProviderStateMixin {
  late SimulateProgressBarController controller;
  late AnimationController uploadAnimController;
  late AnimationController animationController;
  late CurvedAnimation animationControllerCurved;
  late AnimationController completeController;
  late bool needUploadProgress;
  bool completed = false;
  bool uploaded = false;
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
    needUploadProgress = widget.needUploadProgress;
    controller = widget.controller;
    controller._completeCall = () {
      if (!animationController.isCompleted) {
        completed = true;
      } else {
        completeController.forward();
      }
    };
    controller._uploadCompleteCall = () {
      if (!uploadAnimController.isCompleted) {
        uploaded = true;
      } else {
        animationController.forward();
      }
    };
    uploadAnimController = AnimationController(vsync: this, duration: Duration(seconds: 3));
    uploadAnimController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (uploaded) {
          animationController.forward();
        }
        setState(() {});
      }
    });
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
    if (!needUploadProgress) {
      animationController.forward();
    } else {
      uploadAnimController.forward();
    }
  }

  @override
  void dispose() {
    super.dispose();
    animationController.dispose();
    uploadAnimController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: AnimatedBuilder(
            animation: animationControllerCurved,
            builder: (context, child) {
              return AnimatedBuilder(
                  animation: uploadAnimController,
                  builder: (context, child) {
                    return AnimatedBuilder(
                        animation: completeController,
                        builder: (context, child) {
                          var progress;
                          if (needUploadProgress) {
                            progress = uploadAnimController.value * 0.2 + animationControllerCurved.value * 0.6 + completeController.value * 0.2;
                          } else {
                            progress = animationControllerCurved.value * 0.8 + completeController.value * 0.2;
                          }
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Stack(
                                children: [
                                  AppCircleProgressBar(
                                    size: $(60),
                                    ringWidth: $(6),
                                    backgroundColor: Color.fromRGBO(255, 255, 255, 0.3),
                                    progress: progress,
                                    loadingColors: ColorConstant.progressBarColors,
                                  ),
                                  Text('${(progress * 100).toStringAsFixed(0)}%',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: $(13),
                                            fontFamily: 'Poppins',
                                          )).intoCenter().intoContainer(
                                        width: $(60),
                                        height: $(60),
                                      ),
                                ],
                              ).intoContainer(
                                height: $(60),
                                width: $(60),
                              ),
                              SizedBox(height: 4),
                              Text(
                                needUploadProgress && !uploadAnimController.isCompleted ? S.of(context).trans_uploading : S.of(context).trans_painting,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: $(13),
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ],
                          );
                        });
                  });
            }).intoCenter(),
        onWillPop: () async {
          return false;
        }).intoMaterial(
      color: Colors.transparent,
    );
  }
}

class SimulateProgressBarController {
  Function? _completeCall;
  Function? _uploadCompleteCall;

  loadComplete() {
    _completeCall?.call();
  }

  uploadComplete() {
    _uploadCompleteCall?.call();
  }
}
