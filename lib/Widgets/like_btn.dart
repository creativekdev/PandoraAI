import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/images-res.dart';

class LikeButto2n extends StatefulWidget {
  bool like = false;

  Function? onTap;

  LikeButto2n({
    Key? key,
    this.like = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<LikeButto2n> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButto2n> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _iconAnimation;
  late Animation<double> _circleAnimation;
  Function? onTap;
  Rx<bool> like = false.obs;

  @override
  void didUpdateWidget(covariant LikeButto2n oldWidget) {
    super.didUpdateWidget(oldWidget);
    like.value = widget.like;
    onTap = widget.onTap;
  }

  @override
  void initState() {
    super.initState();
    like.value = widget.like;
    onTap = widget.onTap;
    _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    _iconAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3).chain(CurveTween(curve: Curves.easeIn)), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(_controller);
    _circleAnimation = Tween(begin: 0.0, end: 1.0).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _clickIcon() {
    if (_iconAnimation.status == AnimationStatus.forward || _iconAnimation.status == AnimationStatus.reverse) {
      return;
    }
    like.value = !like.value;
    onTap?.call();
    if (_iconAnimation.status == AnimationStatus.dismissed) {
      _controller.forward();
    } else if (_iconAnimation.status == AnimationStatus.completed) {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Obx(() => _buildCircle()),
        Obx(() => _buildLikeIcon()),
      ],
    ).intoContainer(width: $(36), height: $(36));
  }

  _buildLikeIcon() {
    return ScaleTransition(
      scale: _iconAnimation,
      child: like.value
          ? Image.asset(
              Images.ic_discovery_liked,
              width: $(24),
            ).intoGestureDetector(onTap: () {
              _clickIcon();
            })
          : Image.asset(
              Images.ic_discovery_like,
              width: $(24),
            ).intoGestureDetector(onTap: () {
              _clickIcon();
            }),
    );
  }

  _buildCircle() {
    return !like.value
        ? Container()
        : AnimatedBuilder(
            animation: _circleAnimation,
            builder: (BuildContext context, Widget? child) {
              return Container(
                width: $(36),
                height: $(36),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Color(0xfffe3e3e).withOpacity(_circleAnimation.value),
                    width: _circleAnimation.value * 6,
                  ),
                ),
              );
            },
          );
  }
}
