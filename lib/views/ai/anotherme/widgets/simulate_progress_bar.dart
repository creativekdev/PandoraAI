import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/progress/circle_progress_bar.dart';
import 'package:cartoonizer/Widgets/router/routers.dart';
import 'dart:math' as math;

import 'package:cartoonizer/models/enums/account_limit_type.dart';

class SimulateProgressBarConfig {
  late SimulateProgressBarConfigItem upload;
  late SimulateProgressBarConfigItem processing;
  late SimulateProgressBarConfigItem complete;

  SimulateProgressBarConfig();

  factory SimulateProgressBarConfig.anotherMe(BuildContext context) {
    return SimulateProgressBarConfig()
      ..upload = SimulateProgressBarConfigItem(duration: Duration(seconds: 3), rate: 0.2, text: S.of(context).trans_uploading)
      ..processing = SimulateProgressBarConfigItem(duration: Duration(seconds: 5), rate: 0.75, text: S.of(context).trans_painting)
      ..complete = SimulateProgressBarConfigItem(duration: Duration(seconds: 1), rate: 0.05, text: S.of(context).trans_success);
  }

  factory SimulateProgressBarConfig.anotherMeVideo(BuildContext context) {
    return SimulateProgressBarConfig()
      ..upload = SimulateProgressBarConfigItem(duration: Duration(seconds: 1), rate: 0.2, text: S.of(context).trans_uploading)
      ..processing = SimulateProgressBarConfigItem(duration: Duration(seconds: 4), rate: 0.75, text: S.of(context).trans_saving)
      ..complete = SimulateProgressBarConfigItem(duration: Duration(seconds: 1), rate: 0.05, text: S.of(context).trans_success);
  }

  factory SimulateProgressBarConfig.cartoonize(BuildContext context) {
    return SimulateProgressBarConfig()
      ..upload = SimulateProgressBarConfigItem(duration: Duration(seconds: 3), rate: 0.2, text: S.of(context).trans_uploading)
      ..processing = SimulateProgressBarConfigItem(duration: Duration(seconds: 5), rate: 0.75, text: S.of(context).trans_painting)
      ..complete = SimulateProgressBarConfigItem(duration: Duration(seconds: 1), rate: 0.05, text: S.of(context).trans_success);
  }

  factory SimulateProgressBarConfig.txt2img(BuildContext context) {
    return SimulateProgressBarConfig()
      ..upload = SimulateProgressBarConfigItem(duration: Duration(seconds: 1), rate: 0, text: S.of(context).trans_uploading)
      ..processing = SimulateProgressBarConfigItem(duration: Duration(seconds: 2), rate: 0.95, text: S.of(context).trans_painting)
      ..complete = SimulateProgressBarConfigItem(duration: Duration(milliseconds: 500), rate: 0.05, text: S.of(context).trans_success);
  }

  factory SimulateProgressBarConfig.aiDraw(BuildContext context) {
    return SimulateProgressBarConfig()
      ..upload = SimulateProgressBarConfigItem(duration: Duration(seconds: 1), rate: 0.2, text: S.of(context).trans_uploading)
      ..processing = SimulateProgressBarConfigItem(duration: Duration(seconds: 10), rate: 0.75, text: S.of(context).trans_painting)
      ..complete = SimulateProgressBarConfigItem(duration: Duration(milliseconds: 300), rate: 0.05, text: S.of(context).trans_success);
  }
}

class SimulateProgressBarConfigItem {
  Duration duration;
  double rate;
  String text;

  SimulateProgressBarConfigItem({
    required this.duration,
    required this.rate,
    required this.text,
  });
}

class SimulateProgressBar {
  static Future<SimulateProgressResult<AccountLimitType>?> startLoading(
    BuildContext context, {
    required bool needUploadProgress,
    required SimulateProgressBarController controller,
    Function(double progress)? onUpdate,
    required SimulateProgressBarConfig config,
  }) {
    return Navigator.of(context).push<SimulateProgressResult<AccountLimitType>>(
      NoAnimRouter(
        _SimulateProgressBar(
          controller: controller,
          needUploadProgress: needUploadProgress,
          onUpdate: onUpdate,
          config: config,
        ),
        settings: RouteSettings(name: '/_SimulateProgressBar'),
      ),
    );
  }
}

class _SimulateProgressBar extends StatefulWidget {
  SimulateProgressBarController controller;
  bool needUploadProgress;
  Function(double progress)? onUpdate;
  SimulateProgressBarConfig config;

  _SimulateProgressBar({
    Key? key,
    required this.needUploadProgress,
    required this.controller,
    required this.onUpdate,
    required this.config,
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
  late SimulateProgressBarConfig config;
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
    config = widget.config;
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
    controller._onErrorCall = (error) => Navigator.of(context).pop(
          SimulateProgressResult<AccountLimitType>()
            ..result = false
            ..error = error,
        );
    uploadAnimController = AnimationController(vsync: this, duration: config.upload.duration);
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
    animationController = AnimationController(vsync: this, duration: config.processing.duration);
    animationControllerCurved = CurvedAnimation(parent: animationController, curve: curves[math.Random().nextInt(curves.length)]);
    completeController = AnimationController(vsync: this, duration: config.complete.duration);
    animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed && completed) {
        completeController.forward();
      }
    });
    animationController.addListener(() => onUpdate?.call(calculateProgress()));
    completeController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          Navigator.of(context).pop(SimulateProgressResult<AccountLimitType>()..result = true);
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
      progress = uploadAnimController.value * config.upload.rate + animationControllerCurved.value * config.processing.rate + completeController.value * config.complete.rate;
    } else {
      progress = animationControllerCurved.value * (config.upload.rate + config.processing.rate) + completeController.value * config.complete.rate;
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
                                needUploadProgress && !uploadAnimController.isCompleted
                                    ? config.upload.text
                                    : !completeController.isCompleted
                                        ? config.processing.text
                                        : config.complete.text,
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
      color: Color(0x44000000),
    );
  }
}

class SimulateProgressResult<T> {
  bool result = false;
  T? error;

  SimulateProgressResult();
}

class SimulateProgressBarController {
  Function? _completeCall;
  Function? _uploadCompleteCall;
  Function(dynamic error)? _onErrorCall;

  loadComplete() {
    _completeCall?.call();
  }

  uploadComplete() {
    _uploadCompleteCall?.call();
  }

  onError({dynamic error}) {
    delay(() {
      _onErrorCall?.call(error);
    }, milliseconds: 32);
  }
}
