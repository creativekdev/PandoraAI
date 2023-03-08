import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/progress/circle_progress_bar.dart';
import 'dart:math' as math;

class SimulateProgressBar {
  static Future<List<dynamic>?> startLoading(
    BuildContext context, {
    required bool needUploadProgress,
    required SimulateProgressBarController controller,
    Function(double progress)? onUpdate,
  }) {
    return showDialog<List<dynamic>>(
      context: context,
      builder: (context) {
        return _SimulateProgressBar(
          controller: controller,
          needUploadProgress: needUploadProgress,
          onUpdate: onUpdate,
        );
      },
      barrierDismissible: false,
    );
  }
}

class _SimulateProgressBar extends StatefulWidget {
  SimulateProgressBarController controller;
  bool needUploadProgress;
  Function(double progress)? onUpdate;

  _SimulateProgressBar({
    Key? key,
    required this.needUploadProgress,
    required this.controller,
    required this.onUpdate,
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
  Function(double progress)? onUpdate;
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
    onUpdate = widget.onUpdate;
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
    controller._onErrorCall = (title, content) => Navigator.of(context).pop([false, title, content]);
    uploadAnimController = AnimationController(vsync: this, duration: Duration(seconds: 3));
    uploadAnimController.addStatusListener((status) {
      if (!needUploadProgress) {
        return;
      }
      if (status == AnimationStatus.completed) {
        if (uploaded) {
          animationController.forward();
        }
        setState(() {});
      }
    });
    uploadAnimController.addListener(() => onUpdate?.call(calculateProgress()));
    animationController = AnimationController(vsync: this, duration: Duration(seconds: 5));
    animationControllerCurved = CurvedAnimation(parent: animationController, curve: curves[math.Random().nextInt(curves.length)]);
    completeController = AnimationController(vsync: this, duration: Duration(seconds: 1));
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && completed) {
        completeController.forward();
      }
    });
    animationController.addListener(() => onUpdate?.call(calculateProgress()));
    completeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          Navigator.of(context).pop([true]);
        }
      }
    });
    completeController.addListener(() => onUpdate?.call(calculateProgress()));
    if (!needUploadProgress) {
      animationController.forward();
    } else {
      uploadAnimController.forward();
    }
  }

  @override
  void dispose() {
    completeController.dispose();
    animationController.dispose();
    uploadAnimController.dispose();
    super.dispose();
  }

  double calculateProgress() {
    var progress;
    if (needUploadProgress) {
      progress = uploadAnimController.value * 0.2 + animationControllerCurved.value * 0.75 + completeController.value * 0.05;
    } else {
      progress = animationControllerCurved.value * 0.95 + completeController.value * 0.05;
    }
    return progress;
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
                          var progress = calculateProgress();
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
  Function(String? errorTitle, String? errotContent)? _onErrorCall;

  loadComplete() {
    _completeCall?.call();
  }

  uploadComplete() {
    _uploadCompleteCall?.call();
  }

  onError({String? errorTitle, String? errorContent}) {
    delay(() {
      _onErrorCall?.call(errorTitle, errorContent);
    }, milliseconds: 32);
  }
}
