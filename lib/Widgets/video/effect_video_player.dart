import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/api/downloader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/thirdpart_manager.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:video_player/video_player.dart';

class EffectVideoPlayer extends StatefulWidget {
  String url;
  bool useCached;

  EffectVideoPlayer({
    Key? key,
    required this.url,
    this.useCached = true,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EffectVideoPlayerState();
  }
}

class EffectVideoPlayerState extends State<EffectVideoPlayer> {
  late String url;
  late VideoPlayerController controller;
  CacheManager cacheManager = AppDelegate.instance.getManager();
  ThirdpartManager thirdpartManager = AppDelegate.instance.getManager();
  late String fileName;
  late bool downloading = true;
  DownloadListener? downloadListener;
  late StreamSubscription appStateListener;
  String? key;
  late bool useCached;

  @override
  initState() {
    super.initState();
    useCached = widget.useCached;
    url = widget.url;
    if (!useCached) {
      downloading = false;
      controller = VideoPlayerController.network(url)
        ..setLooping(true)
        ..initialize().then((value) {
          setState(() {
            controller.play();
          });
        });
    } else {
      downloadListener = DownloadListener(
          onChanged: (count, total) {},
          onError: (error) {},
          onFinished: (File file) {
            controller = VideoPlayerController.file(file)
              ..setLooping(true)
              ..initialize().then((value) {
                setState(() {
                  controller.play();
                });
              });
            setState(() {
              downloading = false;
            });
          });
      fileName = getFileName(url);
      downloading = true;
      var videoDir = cacheManager.storageOperator.videoDir;
      var savePath = videoDir.path + fileName;
      File data = File(savePath);
      if (data.existsSync()) {
        downloading = false;
        controller = VideoPlayerController.file(data)
          ..setLooping(true)
          ..initialize().then((value) {
            setState(() {
              controller.play();
            });
          });
      } else {
        downloading = true;
        key = Downloader.instance.download(url, savePath);
        Downloader.instance.subscribe(key!, downloadListener!);
      }
    }
    appStateListener = EventBusHelper().eventBus.on<OnAppStateChangeEvent>().listen((event) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    controller.pause();
    appStateListener.cancel();
    controller.dispose();
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
                    aspectRatio: controller.value.aspectRatio,
                    child: VideoPlayer(controller),
                  ),
                  (controller.value.isInitialized) ? Container() : CircularProgressIndicator().intoCenter()
                ],
              );
  }
}
