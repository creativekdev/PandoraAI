import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/images-res.dart';

class CompareableImage extends StatefulWidget {
  final Widget beforeImage;
  final Widget afterImage;
  final double imageHeight;
  final double imageWidth;
  final Function onStartDrag;
  final Function onCancelDrag;

  const CompareableImage({
    Key? key,
    required this.beforeImage,
    required this.afterImage,
    required this.imageHeight,
    required this.imageWidth,
    required this.onCancelDrag,
    required this.onStartDrag,
  }) : super(key: key);

  @override
  CompareableImageState createState() => CompareableImageState();
}

class CompareableImageState extends State<CompareableImage> {
  double _clipFactor = 0.5;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        SizedBox(
          height: widget.imageHeight,
          width: widget.imageWidth,
          child: widget.afterImage,
        ),
        ClipPath(
          clipper: RectClipper(_clipFactor),
          child: SizedBox(
            child: widget.beforeImage,
            width: widget.imageWidth,
            height: widget.imageHeight,
          ),
        ),
        Positioned(
          child: Container(
            width: $(2),
            height: widget.imageHeight,
            color: Colors.white,
          ),
          top: 0,
          bottom: 0,
          left: _clipFactor * widget.imageWidth - $(1),
        ),
        Positioned(
          child: Listener(
            onPointerDown: (details) {
              widget.onStartDrag.call();
            },
            onPointerMove: (details) {
              setState(() {
                _clipFactor = details.position.dx / widget.imageWidth;
              });
            },
            onPointerUp: (details) {
              widget.onCancelDrag.call();
            },
            onPointerCancel: (details) {
              widget.onCancelDrag.call();
            },
            child: Image.asset(Images.ic_metagram_split_icon)
                .intoContainer(
                  width: $(44),
                  height: $(44),
                )
                .intoMaterial(color: Colors.white, borderRadius: BorderRadius.circular($(32))),
          ),
          bottom: 10,
          left: _clipFactor * widget.imageWidth - $(22),
        ),
      ],
    );
  }
}

class RectClipper extends CustomClipper<Path> {
  final double clipFactor;

  RectClipper(this.clipFactor);

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(size.width * clipFactor, 0.0);
    path.lineTo(size.width * clipFactor, size.height);
    path.lineTo(0.0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

class RectClipperVertical extends CustomClipper<Path> {
  final double clipFactor;

  RectClipperVertical(this.clipFactor);

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0.0, size.height * clipFactor);
    path.lineTo(size.width, size.height * clipFactor);
    path.lineTo(size.width, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
