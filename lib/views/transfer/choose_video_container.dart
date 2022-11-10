import 'package:cartoonizer/Common/importFile.dart';
import 'package:video_player/video_player.dart';

class ChooseVideoContainer extends StatefulWidget {
  VideoPlayerController videoPlayerController;
  double width;
  double height;

  ChooseVideoContainer({
    Key? key,
    required this.videoPlayerController,
    required this.width,
    required this.height,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ChooseVideoContainerState();
  }
}

class ChooseVideoContainerState extends State<ChooseVideoContainer> {
  late VideoPlayerController _videoPlayerController;
  late double width;
  late double height;

  bool optVisible = true;
  bool extendTime = false;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = widget.videoPlayerController;
    width = widget.width;
    height = widget.height;
    autoHide();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: _videoPlayerController.value.aspectRatio,
          child: VideoPlayer(_videoPlayerController),
        ),
        Icon(
          _videoPlayerController.value.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: $(24),
          color: Colors.white,
        )
            .intoContainer(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(64), color: Color(0x66000000)),
              padding: EdgeInsets.all(16),
            )
            .intoGestureDetector(onTap: () {
              extendTime = true;
              if (_videoPlayerController.value.isPlaying) {
                _videoPlayerController.pause();
              } else {
                _videoPlayerController.play();
              }
              setState(() {});
            })
            .intoCenter()
            .visibility(visible: optVisible),
      ],
    ).intoContainer(height: width, width: height).intoGestureDetector(onTap: () {
      setState(() {
        optVisible = !optVisible;
      });
      autoHide();
    });
  }

  void autoHide() {
    if (optVisible) {
      delay(() {
        if (optVisible && !extendTime) {
          setState(() {
            extendTime = false;
            optVisible = false;
          });
        }
      }, milliseconds: 3000);
    }
  }
}
