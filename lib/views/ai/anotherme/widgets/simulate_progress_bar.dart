import 'package:cartoonizer/Widgets/app_navigation_bar.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/models/enums/account_limit_type.dart';
import 'package:cartoonizer/widgets/router/routers.dart';

import '../../../../images-res.dart';

class SimulateProgressBarConfig {
  late SimulateProgressBarConfigItem upload;
  late SimulateProgressBarConfigItem processing;
  late SimulateProgressBarConfigItem complete;

  SimulateProgressBarConfig();

  factory SimulateProgressBarConfig.anotherMe(BuildContext context) {
    return SimulateProgressBarConfig()
      ..upload = SimulateProgressBarConfigItem(text: S.of(context).trans_uploading)
      ..processing = SimulateProgressBarConfigItem(text: S.of(context).trans_painting)
      ..complete = SimulateProgressBarConfigItem(text: S.of(context).trans_success);
  }

  factory SimulateProgressBarConfig.anotherMeVideo(BuildContext context) {
    return SimulateProgressBarConfig()
      ..upload = SimulateProgressBarConfigItem(text: S.of(context).trans_uploading)
      ..processing = SimulateProgressBarConfigItem(text: S.of(context).trans_saving)
      ..complete = SimulateProgressBarConfigItem(text: S.of(context).trans_success);
  }

  factory SimulateProgressBarConfig.cartoonize(BuildContext context) {
    return SimulateProgressBarConfig()
      ..upload = SimulateProgressBarConfigItem(text: S.of(context).trans_uploading)
      ..processing = SimulateProgressBarConfigItem(text: S.of(context).trans_painting)
      ..complete = SimulateProgressBarConfigItem(text: S.of(context).trans_success);
  }

  factory SimulateProgressBarConfig.txt2img(BuildContext context) {
    return SimulateProgressBarConfig()
      ..upload = SimulateProgressBarConfigItem(text: S.of(context).trans_uploading)
      ..processing = SimulateProgressBarConfigItem(text: S.of(context).trans_painting)
      ..complete = SimulateProgressBarConfigItem(text: S.of(context).trans_success);
  }

  factory SimulateProgressBarConfig.aiDraw(BuildContext context) {
    return SimulateProgressBarConfig()
      ..upload = SimulateProgressBarConfigItem(text: S.of(context).trans_uploading)
      ..processing = SimulateProgressBarConfigItem(text: S.of(context).trans_painting)
      ..complete = SimulateProgressBarConfigItem(text: S.of(context).trans_success);
  }
}

class SimulateProgressBarConfigItem {
  String text;

  SimulateProgressBarConfigItem({
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
          canCloseApp: false,
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
  bool canCloseApp;

  _SimulateProgressBar({
    Key? key,
    required this.needUploadProgress,
    required this.controller,
    required this.onUpdate,
    required this.config,
    this.canCloseApp = false,
  }) : super(key: key);

  @override
  State<_SimulateProgressBar> createState() => _SimulateProgressBarState();
}

class _SimulateProgressBarState extends State<_SimulateProgressBar> with TickerProviderStateMixin {
  late SimulateProgressBarController controller;
  late SimulateProgressBarConfig config;
  bool completed = false;
  bool uploaded = false;

  @override
  void initState() {
    super.initState();
    config = widget.config;
    controller = widget.controller;
    controller._completeCall = () {
      if (mounted) {
        Navigator.of(context).pop(SimulateProgressResult<AccountLimitType>()..result = true);
      }
    };
    controller._uploadCompleteCall = () {
      uploaded = true;
      setState(() {});
    };
    controller._onErrorCall = (error) {
      if (mounted) {
        Navigator.of(context).pop(
          SimulateProgressResult<AccountLimitType>()
            ..result = false
            ..error = error,
        );
      }
    };
    delay(() {
      if (mounted) {
        Navigator.of(context).pop(
          SimulateProgressResult<AccountLimitType>()
            ..result = false
            ..error = null,
        );
      }
    }, milliseconds: 60000);
  }

  @override
  void dispose() {
    super.dispose();
  }

  double calculateProgress() {
    var progress;
    return progress;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        child: Scaffold(
            backgroundColor: Color(0xFF010101),
            appBar: AppNavigationBar(
              showBackItem: widget.canCloseApp,
            ),
            body: Column(
              children: [
                Visibility(
                  visible: false,
                  child: Text(uploaded ? config.processing.text : config.upload.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.sp,
                        fontFamily: 'Poppins',
                      )).intoPadding(padding: EdgeInsets.only(top: 80.dp)),
                ),
                Expanded(child: Container()),
                Visibility(
                  visible: false,
                  child: Text(
                    S.of(context).do_not_close_app,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
                Image.asset(
                  Images.ic_loading,
                  width: 200.dp,
                  height: 200.dp,
                ),
                Text(uploaded ? config.processing.text : config.upload.text,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.sp,
                      fontFamily: 'Poppins',
                    )),
                Expanded(child: Container()),
                Text(
                  S.of(context).do_not_close_app,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontFamily: 'Poppins',
                  ),
                ).intoPadding(padding: EdgeInsets.only(bottom: 80.dp)),
              ],
            )),
        onWillPop: () async {
          return false;
        }).intoMaterial(
      color: Color(0xFF010101),
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
