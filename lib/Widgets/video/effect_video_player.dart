import 'package:cartoonizer/Common/importFile.dart';
import 'package:flutter/cupertino.dart';
import 'package:video_player/video_player.dart';

class EffectVideoPlayer extends StatefulWidget {
  String url;

  EffectVideoPlayer({
    Key? key,
    required this.url,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return EffectVideoPlayerState();
  }
}

class EffectVideoPlayerState extends State<EffectVideoPlayer> {
  late String url;
  late VideoPlayerController controller;

  @override
  initState() {
    super.initState();
    url = widget.url;
    controller = VideoPlayerController.network(url)
      ..setLooping(true)
      ..initialize().then((value) {
        setState(() {
          controller.play();
        });
      });
  }

  @override
  void dispose() {
    super.dispose();
    controller.pause();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
        !controller.value.isPlaying
            ? CircularProgressIndicator().intoCenter()
            : Container(),
      ],
    );
  }
}
