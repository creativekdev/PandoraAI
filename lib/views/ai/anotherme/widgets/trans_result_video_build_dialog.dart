import 'dart:io';
import 'dart:ui';

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/progress/circle_progress_bar.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/utils/ffmpeg_util.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/trans_result_anim_screen.dart';
import 'package:common_utils/common_utils.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/session_state.dart';

class TransResultVideoBuildDialog extends StatefulWidget {
  File origin;
  File result;
  double ratio;

  TransResultVideoBuildDialog({
    Key? key,
    required this.result,
    required this.origin,
    required this.ratio,
  }) : super(key: key);

  @override
  State<TransResultVideoBuildDialog> createState() => _TransResultVideoBuildDialogState();
}

class _TransResultVideoBuildDialogState extends State<TransResultVideoBuildDialog> {
  late File origin;
  late File result;
  late double ratio;
  late double designWidth;
  late double designHeight;
  GlobalKey cropKey = GlobalKey();
  int progress = 0;
  CacheManager cacheManager = AppDelegate.instance.getManager();

  int firstFrameCount = 24;

  int imageNameCount = 24;

  @override
  void initState() {
    super.initState();
    origin = widget.origin;
    result = widget.result;
    ratio = widget.ratio;
    designWidth = 480;
    designHeight = designWidth * ratio;
    String dirName = EncryptUtil.encodeMd5(result.path);
    var savePath = cacheManager.storageOperator.recordMetaverseDir.path + dirName;
    if (File('$savePath/output.mp4').existsSync()) {
      delay(() {
        Navigator.of(context).pop('$savePath/output.mp4');
      });
      return;
    } else {
      delay(() {
        startRecord(onSuccess: () {
          buildVideo();
        }, onError: () {
          CommonExtension().showToast('build failed');
        });
      }, milliseconds: 1000);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    RepaintBoundary(
                      key: cropKey,
                      child: TransProgressScreenShotWidget(origin: origin, result: result, width: designWidth, height: designWidth * ratio, progress: progress / 100),
                    ).intoContainer(width: designWidth, height: designWidth * ratio)
                  ],
                ),
              ).intoContainer(width: 1),
            ],
          ),
        ).intoContainer(height: 1),
        AppCircleProgressBar(
          size: $(60),
          ringWidth: $(6),
          backgroundColor: Color.fromRGBO(255, 255, 255, 0.3),
          progress: progress / 100,
          loadingColors: ColorConstant.progressBarColors,
        ).intoCenter(),
        Text(
          '${progress}%',
          style: TextStyle(
            color: Colors.white,
            fontSize: $(13),
            fontFamily: 'Poppins',
          ),
        ).intoCenter(),
      ],
    ).intoCenter().intoMaterial(color: Colors.transparent);
  }

  Future<void> startRecord({
    required Function onSuccess,
    required Function onError,
  }) async {
    if (cropKey.currentContext == null) {
      onError.call();
      return;
    }
    var image = await getBitmapFromContext(cropKey.currentContext!);
    if (image == null) {
      onError.call();
      return;
    }
    String dirName = EncryptUtil.encodeMd5(result.path);
    var savePath = cacheManager.storageOperator.recordMetaverseDir.path + dirName;
    var directory = Directory(savePath);
    var exist = await directory.exists();
    if (!exist) {
      await mkdir(directory);
    }
    if (progress == 0) {
      var byteData = await image.toByteData(format: ImageByteFormat.png);
      var asUint8List = byteData!.buffer.asUint8List();
      for (int i = 0; i < firstFrameCount; i++) {
        var file = File(savePath + '/${i}.png');
        if (!file.existsSync()) {
          await file.writeAsBytes(asUint8List.toList());
        }
      }
    } else {
      if (progress % 3 == 0 || progress == 100) {
        var file = File(savePath + '/${imageNameCount}.png');
        if (!file.existsSync()) {
          var byteData = await image.toByteData(format: ImageByteFormat.png);
          var asUint8List = byteData!.buffer.asUint8List();
          await file.writeAsBytes(asUint8List.toList());
          imageNameCount++;
        }
      }
    }
    progress++;
    setState(() {});
    if (progress == 100) {
      onSuccess.call();
    } else {
      startRecord(onSuccess: onSuccess, onError: onError);
    }
  }

  Future<void> buildVideo() async {
    String dirName = EncryptUtil.encodeMd5(result.path);
    var savePath = cacheManager.storageOperator.recordMetaverseDir.path + dirName;
    if (File('$savePath/output.mp4').existsSync()) {
      Navigator.of(context).pop('$savePath/output.mp4');
    } else {
      var command = FFmpegUtil.commandImage2Video(
        mainDir: savePath,
        framePerSecond: 24,
      );
      FFmpegKit.execute(command).then((session) {
        session.getState().then((value) {
          value == SessionState.completed;
          FFmpegKit.cancel(session.getSessionId());
          Navigator.of(context).pop('$savePath/output.mp4');
        });
      });
    }
  }
}
