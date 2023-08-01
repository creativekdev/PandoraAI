import '../../../Common/importFile.dart';

typedef OnPinEndCallBack = void Function(bool isSelectedBg, double scale, double dx, double dy);

class PinGestureViews extends StatefulWidget {
  PinGestureViews(
      {Key? key,
      required this.child,
      required this.bgChild,
      this.scale = 1.0,
      this.baseScale = 1.0,
      this.minScale = 0.5,
      this.maxScale = 3.0,
      required this.isSelectedBg,
      required this.onPinEndCallBack,
      required this.dx,
      required this.dy,
      required this.bgDx,
      required this.bgDy,
      this.bgScale = 1.0})
      : super(key: key);
  double scale;
  double baseScale;
  double minScale;
  double maxScale;
  double bgScale;
  double dx;
  double dy;
  double bgDx;
  double bgDy;
  bool isSelectedBg;
  Widget child;
  Widget bgChild;
  OnPinEndCallBack onPinEndCallBack;

  @override
  State<PinGestureViews> createState() => _PinGestureViewsState(
        scale: scale,
        baseScale: baseScale,
        minScale: minScale,
        maxScale: maxScale,
        bgScale: bgScale,
        dx: dx,
        dy: dy,
        bgDx: bgDx,
        bgDy: bgDy,
      );
}

class _PinGestureViewsState extends State<PinGestureViews> {
  _PinGestureViewsState({
    required this.scale,
    required this.baseScale,
    required this.minScale,
    required this.maxScale,
    required this.bgScale,
    required this.dx,
    required this.dy,
    required this.bgDx,
    required this.bgDy,
  });

  double scale;
  double baseScale;
  double minScale;
  double maxScale;
  double bgScale;
  double dx;
  double dy;
  double bgDx;
  double bgDy;
  Offset lastOffset = Offset.zero;
  Offset bgLastOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (ScaleStartDetails details) {
        if (widget.isSelectedBg) {
          baseScale = bgScale;
          bgLastOffset = details.localFocalPoint;
        } else {
          baseScale = scale;
          lastOffset = details.localFocalPoint;
        }
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        double newScale = baseScale * details.scale;
        if (newScale < minScale) {
          newScale = minScale;
        } else if (newScale > maxScale) {
          newScale = maxScale;
        }

        setState(() {
          if (widget.isSelectedBg) {
            bgScale = newScale;
            bgDx = details.localFocalPoint.dx - bgLastOffset.dx;
            bgDy = details.localFocalPoint.dy - bgLastOffset.dy;
          } else {
            scale = newScale;
            dx = details.localFocalPoint.dx - lastOffset.dx;
            dy = details.localFocalPoint.dy - lastOffset.dy;
          }
        });
      },
      onScaleEnd: (details) {
        if (widget.isSelectedBg) {
          widget.onPinEndCallBack(true, bgScale, bgDx, bgDy);
        } else {
          widget.onPinEndCallBack(false, scale, dx, dy);
        }
      },
      child: Stack(
        children: [
          Transform.translate(
            offset: Offset(bgDx, bgDy),
            child: Transform.scale(child: widget.bgChild, scale: bgScale),
          ),
          Transform.translate(
            offset: Offset(dx, dy),
            child: Transform.scale(child: widget.child, scale: scale),
          ),
        ],
      ),
    );
  }
}
