import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/downloader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/thirdpart/thirdpart_manager.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:video_player/video_player.dart';

class EffectVideoPlayer extends StatefulWidget {
  String url;
  bool useCached;
  bool isFile;
  bool loop;
  Function? onCompleted;

  EffectVideoPlayer({
    Key? key,
    required this.url,
    this.useCached = true,
    this.isFile = false,
    this.loop = true,
    this.onCompleted,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EffectVideoPlayerState();
  }
}

class EffectVideoPlayerState extends State<EffectVideoPlayer> {
  late String url;
  VideoPlayerController? controller;
  CacheManager cacheManager = AppDelegate.instance.getManager();
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();
  late String fileName;
  late bool downloading = true;
  DownloadListener? downloadListener;
  late StreamSubscription appStateListener;
  String? key;
  late bool useCached;
  late bool isFile;
  late bool loop;
  Function? onCompleted;

  @override
  initState() {
    super.initState();
    useCached = widget.useCached;
    url = widget.url;
    isFile = widget.isFile;
    onCompleted = widget.onCompleted;
    loop = widget.loop;
    if (isFile) {
      downloading = false;
      controller = VideoPlayerController.file(File(url))
        ..setLooping(loop)
        ..initialize().then((value) {
          controller!.addListener(() {
            judgePlaySection();
          });
          setState(() {
            play();
          });
        });
    } else if (!useCached) {
      downloading = false;
      controller = VideoPlayerController.network(url)
        ..setLooping(loop)
        ..initialize().then((value) {
          controller!.addListener(() {
            judgePlaySection();
          });
          setState(() {
            play();
          });
        });
    } else {
      downloadListener = DownloadListener(
          onChanged: (count, total) {},
          onError: (error) {},
          onFinished: (File file) {
            controller = VideoPlayerController.file(file)
              ..setLooping(loop)
              ..initialize().then((value) {
                controller!.addListener(() {
                  judgePlaySection();
                });
                setState(() {
                  play();
                });
              });
            setState(() {
              downloading = false;
            });
          });
      if (url.contains('?')) {
        fileName = getFileName(url.split('?')[0]);
      } else {
        fileName = getFileName(url);
      }
      downloading = true;
      var videoDir = cacheManager.storageOperator.videoDir;
      var savePath = videoDir.path + fileName;
      File data = File(savePath);
      if (data.existsSync()) {
        downloading = false;
        controller = VideoPlayerController.file(data)
          ..setLooping(loop)
          ..setVolume(0)
          ..initialize().then((value) {
            controller!.addListener(() {
              judgePlaySection();
            });
            setState(() {
              play();
            });
          });
      } else {
        downloading = true;
        Downloader.instance.download(url, savePath).then((value) {
          key = value;
          Downloader.instance.subscribe(key!, downloadListener!);
        });
      }
    }
    appStateListener = EventBusHelper().eventBus.on<OnAppStateChangeEvent>().listen((event) {
      setState(() {});
    });
  }

  judgePlaySection() {
    var currentPos = controller!.value.position;
    var totalPos = controller!.value.duration;
    if (currentPos == totalPos) {
      onCompleted?.call();
    }
  }

  play() {
    controller?.play();
  }

  pause() {
    controller?.pause();
  }

  @override
  void didUpdateWidget(EffectVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    play();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.pause();
    appStateListener.cancel();
    controller?.dispose();
    if (key != null) {
      Downloader.instance.unsubscribeSync(key!, downloadListener!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return downloading
        ? CircularProgressIndicator().intoCenter()
        : thirdpartManager.appBackground
            ? Container()
            : Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: controller!.value.aspectRatio,
                    child: VideoPlayer(controller!),
                  ),
                  (controller!.value.isInitialized) ? Container() : CircularProgressIndicator().intoCenter()
                ],
              );
  }
}
