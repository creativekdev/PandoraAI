import 'dart:io';

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/mask/app_mask.dart';

import 'anotherme.dart';

class TransResultAnimScreen extends StatefulWidget {
  File origin;
  File result;
  double ratio;

  TransResultAnimScreen({
    Key? key,
    required this.origin,
    required this.result,
    required this.ratio,
  }) : super(key: key);

  @override
  State<TransResultAnimScreen> createState() => _TransResultAnimScreenState();
}

class _TransResultAnimScreenState extends State<TransResultAnimScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation animation;
  late File origin;
  late File result;
  late double ratio;
  late double width;
  late double height;

  @override
  void initState() {
    super.initState();
    origin = widget.origin;
    result = widget.result;
    ratio = widget.ratio;
    width = ScreenUtil.screenSize.width;
    height = width * ratio;
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 2000));
    animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutQuint);
    _controller.addStatusListener(
      (status) {
        switch (status) {
          case AnimationStatus.dismissed:
          case AnimationStatus.forward:
          case AnimationStatus.reverse:
            break;
          case AnimationStatus.completed:
            Navigator.of(context).pop();
            break;
        }
      },
    );
    delay(() => _controller.forward(), milliseconds: 1000);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: animation,
        builder: (context, child) => TransProgressScreenShotWidget(
          progress: animation.value,
          height: height,
          width: width,
          result: result,
          origin: origin,
        ),
      ).intoCenter(),
      backgroundColor: Colors.black,
    );
  }
}

class TransProgressScreenShotWidget extends StatelessWidget {
  double progress;
  double width;
  double height;
  File origin;
  File result;

  TransProgressScreenShotWidget({
    Key? key,
    required this.progress,
    required this.width,
    required this.height,
    required this.origin,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.file(
          origin,
          fit: BoxFit.cover,
          width: width,
          height: height,
        ).hero(tag: AnotherMe.takeItemTag),
        TransProgressImage(
                child: Image.file(
                  result,
                  fit: BoxFit.cover,
                  width: width,
                  height: height,
                ),
                progress: progress)
            .hero(tag: result.path),
      ],
    ).intoContainer(
      width: width,
      height: height,
    );
  }
}

class TransProgressImage extends StatelessWidget {
  final double progress;
  final Widget child;

  const TransProgressImage({
    Key? key,
    required this.progress,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: CircleMaskClipper(
            progress: progress,
            x: 0.4,
            y: 0.4,
            m: 1.3,
          ),
          child: child,
        ),
        ClipPath(
          clipper: CircleMaskClipper(
            progress: progress,
            x: 0.7,
            y: 0.9,
            m: 0.7,
          ),
          child: child,
        ),
        ClipPath(
          clipper: CircleMaskClipper(
            progress: progress,
            x: 0.9,
            y: 0.2,
            m: 0.4,
          ),
          child: child,
        ),
        ClipPath(
          clipper: CircleMaskClipper(
            progress: progress,
            x: 0.2,
            y: 0.9,
            m: 0.4,
          ),
          child: child,
        ),
      ],
    );
  }
}
