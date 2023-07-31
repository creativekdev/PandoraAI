import 'dart:io';

import 'package:cartoonizer/Common/event_bus_helper.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/image/sync_download_video.dart';
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
  double? ratio;

  EffectVideoPlayer({
    Key? key,
    required this.url,
    this.useCached = true,
    this.isFile = false,
    this.loop = true,
    this.ratio,
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
  late bool downloading = true;
  late StreamSubscription appStateListener;
  late bool useCached;
  late bool isFile;
  late bool loop;
  Function? onCompleted;
  double? ratio;

  @override
  initState() {
    super.initState();
    useCached = widget.useCached;
    url = widget.url;
    isFile = widget.isFile;
    ratio = widget.ratio;
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
      setState(() {
        downloading = true;
      });
      SyncDownloadVideo(url: url, type: getFileType(url)).getVideo().then((value) {
        if (value != null) {
          controller = VideoPlayerController.file(value)
            ..setLooping(loop)
            ..initialize();
          controller!.addListener(() {
            judgePlaySection();
          });
          setState(() {
            play();
          });
        }
        setState(() {
          downloading = false;
        });
      });
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
    useCached = widget.useCached;
    url = widget.url;
    isFile = widget.isFile;
    ratio = widget.ratio;
    onCompleted = widget.onCompleted;
    loop = widget.loop;
    play();
  }

  @override
  void dispose() {
    super.dispose();
    controller?.pause();
    appStateListener.cancel();
    controller?.dispose();
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
                    aspectRatio: ratio == null ? controller!.value.aspectRatio : ratio!,
                    child: VideoPlayer(controller!),
                  ),
                  (controller!.value.isPlaying) ? Container() : CircularProgressIndicator().intoCenter()
                ],
              );
  }
}
