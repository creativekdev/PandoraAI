import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:skeletons/skeletons.dart';

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
    this.loopDelay = 2000,
    this.duration = 4000,
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
  late int loopDelay;
  late int duration;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    initData();
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: duration));
    _iconAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 20),
    ]).animate(_controller!);
    if (images.length >= 2) {
      delay(() => _controller?.forward(), milliseconds: loopDelay);
    }
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
  }

  @override
  void dispose() {
    _controller?.dispose();
    _controller = null;
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
          animation: _iconAnimation,
          builder: (context, child) {
            return Opacity(
              child: child,
              opacity: 1 - _iconAnimation.value,
            );
          },
          child: buildImage(context, images[cursor]),
        ),
        AnimatedBuilder(
          animation: _controller!,
          builder: (context, child) {
            return Opacity(
              child: child,
              opacity: _iconAnimation.value,
            );
          },
          child: buildImage(context, images[cursor.next(max: images.length - 1)]),
        ),
      ],
    ).intoContainer(
      width: width,
      height: height,
    );
  }

  Widget buildImage(BuildContext context, String url) => CachedNetworkImageUtils.custom(
      context: context,
      useOld: false,
      imageUrl: url,
      width: width,
      height: height,
      placeholder: (context, url) {
        return SkeletonAvatar(
          style: SkeletonAvatarStyle(width: width, height: height),
        );
      });
}

extension _CursorEx on int {
  int next({required int max}) {
    if (this == max) {
      return 0;
    }
    return this + 1;
  }
}
