import 'dart:io';
import 'dart:ui' as ui;

import 'package:cartoonizer/Common/Extension.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/utils/ffmpeg_util.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:cartoonizer/views/ai/anotherme/trans_result_anim_screen.dart';
import 'package:cartoonizer/views/ai/anotherme/widgets/simulate_progress_bar.dart';
import 'package:common_utils/common_utils.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';

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

  int firstFrameCount = 30;

  int imageNameCount = 30;
  late String fileName;
  var startTime = DateTime.now().millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    origin = widget.origin;
    result = widget.result;
    ratio = widget.ratio;
    designWidth = 420;
    designHeight = designWidth * ratio;
    String dirName = EncryptUtil.encodeMd5(result.path);
    var savePath = cacheManager.storageOperator.recordMetaverseDir.path + dirName;
    fileName = '$savePath/${EncryptUtil.encodeMd5(savePath).substring(0, 8)}.mp4';
    if (File(fileName).existsSync()) {
      delay(() {
        Navigator.of(context).pop(fileName);
      });
      return;
    } else {
      delay(() {
        SimulateProgressBarController controller = SimulateProgressBarController();
        SimulateProgressBar.startLoading(
          context,
          needUploadProgress: false,
          controller: controller,
          config: SimulateProgressBarConfig.anotherMeVideo(context),
        ).then((value) {
          if (value != null && value.result) {
            buildVideo();
          } else {
            Navigator.of(context).pop();
          }
        });
        startRecord(onSuccess: () {
          setState(() {
            progress = 100;
          });
          controller.loadComplete();
          // buildVideo();
        }, onError: () {
          controller.onError();
          CommonExtension().showToast('build failed');
          // Navigator.of(context).pop();
        });
      }, milliseconds: 100);
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
        // AppCircleProgressBar(
        //   size: $(60),
        //   ringWidth: $(6),
        //   backgroundColor: Color.fromRGBO(255, 255, 255, 0.3),
        //   progress: progress / 100,
        //   loadingColors: ColorConstant.progressBarColors,
        // ).intoCenter(),
        // Text(
        //   '${progress}%',
        //   style: TextStyle(
        //     color: Colors.white,
        //     fontSize: $(13),
        //     fontFamily: 'Poppins',
        //   ),
        // ).intoCenter(),
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
    String dirName = EncryptUtil.encodeMd5(result.path);
    var savePath = cacheManager.storageOperator.recordMetaverseDir.path + dirName;
    var directory = Directory(savePath);
    var exist = await directory.exists();
    if (!exist) {
      await mkdir(directory);
    }
    if (progress == 0) {
      var image = await getBitmapFromContext(cropKey.currentContext!, pixelRatio: 1);
      if (image == null) {
        onError.call();
        return;
      }
      var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      var asUint8List = byteData!.buffer.asUint8List();
      for (int i = 0; i < firstFrameCount; i++) {
        var file = File(savePath + '/${i}.png');
        if (!file.existsSync()) {
          await file.writeAsBytes(asUint8List.toList());
        }
      }
    } else {
      if (progress % 3 == 0 || progress == 100) {
        String fileName = savePath + '/${imageNameCount}.png';
        var file = File(fileName);
        if (!file.existsSync()) {
          var image = await getBitmapFromContext(cropKey.currentContext!, pixelRatio: 0.8);
          if (image == null) {
            onError.call();
            return;
          }
          var data = (await image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
          await file.writeAsBytes(data);
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
    var endTime = DateTime.now().millisecondsSinceEpoch;
    debugPrint('build video spend time: ${endTime - startTime}');
    String dirName = EncryptUtil.encodeMd5(result.path);
    var savePath = cacheManager.storageOperator.recordMetaverseDir.path + dirName;
    if (File(fileName).existsSync()) {
      Navigator.of(context).pop(fileName);
    } else {
      var command = FFmpegUtil.commandImage2Video(
        mainDir: savePath,
        outputPath: fileName,
        framePerSecond: 30,
      );
      FFmpegKit.execute(command).then((session) {
        session.getState().then((value) {
          FFmpegKit.cancel(session.getSessionId());
          Navigator.of(context).pop(fileName);
          deleteFiles(savePath, filter: 'png');
        });
      });
    }
  }

  Future deleteFiles(String path, {required String filter}) async {
    Directory directory = Directory(path);
    if (!directory.existsSync()) {
      return;
    }
    var stream = await directory.list();
    await stream.forEach((element) async {
      if (element.path.endsWith(filter)) {
        element.delete(recursive: true);
      }
    });
  }
}

class DealData {
  String? name;
  ui.Image? image;
  Uint8List? data;

  DealData();
}

Future<List<DealData>> convertImagesToPngBytes(List<DealData> images) async {
  List<DealData> result = [];
  // List<Future<DealData>> futures = images.map((e) => _getImage(e)).toList();
  // return await Future.wait<DealData>(futures);
  for (var value in images) {
    result.add(await _getImage(value));
  }
  return result;
}

Future<DealData> _getImage(DealData image) async {
  var img = image.image!;
  image.data = (await img.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
  return image;
}
