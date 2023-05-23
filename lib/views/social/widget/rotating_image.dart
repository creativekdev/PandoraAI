import 'dart:math';

import 'package:cartoonizer/common/importFile.dart';

class RotatingImage extends StatefulWidget {
  Widget child;

  RotatingImage({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<RotatingImage> createState() => _RotatingImageState();
}

class _RotatingImageState extends State<RotatingImage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Widget child;

  @override
  void initState() {
    super.initState();
    child = widget.child;
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 1500));
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reset();
        _controller.forward();
      }
    });
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant RotatingImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    child = widget.child;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: 2 * pi * _controller.value,
          child: child,
        );
      },
      child: child,
    );
  }
}
