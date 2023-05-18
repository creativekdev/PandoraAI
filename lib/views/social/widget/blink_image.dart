import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:common_utils/common_utils.dart';

class BlinkImage extends StatefulWidget {
  List<String> images;

  double width;
  double height;
  int loopDelay;

  int duration;

  BlinkImage({
    Key? key,
    required this.images,
    required this.width,
    required this.height,
    this.loopDelay = 3000,
    required this.duration,
  }) : super(key: key);

  @override
  State<BlinkImage> createState() => _BlinkImageState();
}

class _BlinkImageState extends State<BlinkImage> with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  late List<String> images;
  late double width;
  late double height;
  int cursor = 0;
  TimerUtil? timer;
  late int loopDelay;
  late int duration;

  @override
  void initState() {
    super.initState();
    initData();
    timer = TimerUtil()
      ..setInterval(duration)
      ..setOnTimerTickCallback(
        (millisUntilFinished) {
          if (mounted && _controller?.status == AnimationStatus.dismissed) {
            _controller?.forward();
          }
        },
      );
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    _controller?.addStatusListener((status) {
      if (images.length < 2) {
        return;
      }
      if (status == AnimationStatus.completed) {
        // setState(() {
        //   cursor = cursor.next(max: images.length - 1);
        // });
        // _controller?.reset();
      }
    });
    if (images.length >= 2) {
      loop();
    }
  }

  loop() {
    timer?.cancel();
    delay(() => timer?.startTimer(), milliseconds: loopDelay);
  }

  void initData() {
    images = widget.images;
    width = widget.width;
    height = widget.height;
    loopDelay = widget.loopDelay;
    duration = widget.duration;
  }

  @override
  void didUpdateWidget(covariant BlinkImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    initData();
    if (images.length >= 2) {
      loop();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
    timer?.cancel();
    timer = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(width: width, height: height);
    }
    if (images.length == 1) {
      return buildImage(context, images.first);
    }
    return Stack(
      children: [
        AnimatedBuilder(
          animation: _controller!,
          builder: (context, child) {
            return Opacity(
              child: child,
              opacity: _controller!.value,
            );
          },
          child: CachedNetworkImageUtils.custom(
            context: context,
            imageUrl: images[cursor],
            width: width,
            height: height,
          ),
        ),
        AnimatedBuilder(
          animation: _controller!,
          builder: (context, child) {
            return Opacity(
              child: child,
              opacity: 1 - _controller!.value,
            );
          },
          child: CachedNetworkImageUtils.custom(
            context: context,
            imageUrl: images[cursor.next(max: images.length - 1)],
            width: width,
            height: height,
          ),
        ),
      ],
    ).intoContainer(
      width: width,
      height: height,
    );
  }

  Widget buildImage(BuildContext context, String url) {
    return CachedNetworkImageUtils.custom(
      context: context,
      imageUrl: url,
      width: width,
      height: height,
    );
  }
}

extension _CursorEx on int {
  int next({required int max}) {
    if (this == max) {
      return 0;
    }
    return this + 1;
  }
}
