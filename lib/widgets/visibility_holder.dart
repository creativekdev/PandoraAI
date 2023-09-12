import 'dart:ui';

import 'package:cartoonizer/widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:visibility_detector/visibility_detector.dart';

class VisibilityImageHolder extends StatefulWidget {
  final String url;
  final BoxFit fit;
  final double width;
  final double height;

  const VisibilityImageHolder({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    required this.width,
    required this.height,
  });

  @override
  State<VisibilityImageHolder> createState() => _VisibilityHolderState();
}

class _VisibilityHolderState extends State<VisibilityImageHolder> {
  bool visible = true;
  GlobalKey cropKey = GlobalKey();
  Image? cache;

  Widget get cacheImage => cache ?? SizedBox(width: widget.width, height: widget.height);

  bool cropping = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
        key: Key(widget.url),
        child: visible || cropping
            ? RepaintBoundary(
                key: cropKey,
                child: CachedNetworkImageUtils.custom(
                  fit: widget.fit,
                  width: widget.width,
                  height: widget.height,
                  context: context,
                  imageUrl: widget.url,
                  placeholder: (cache != null) ? (context, url) => cacheImage : null,
                ))
            : cacheImage,
        onVisibilityChanged: (info) {
          var _visible = info.visibleFraction != 0;
          if (visible != _visible) {
            if (!_visible) {
              if (cropKey.currentContext != null) {
                cropping = true;
                getBitmapFromContext(cropKey.currentContext!).then((value) async {
                  if (value != null) {
                    var byteData = await value.toByteData(format: ImageByteFormat.png);
                    if (byteData != null) {
                      cache = Image.memory(
                        byteData.buffer.asUint8List(),
                        width: widget.width,
                        height: widget.height,
                      );
                    } else {
                      cache = null;
                    }
                  }
                  cropping = false;
                  if (mounted) {
                    setState(() {});
                  }
                });
              }
            }
            visible = _visible;
            if (mounted) {
              setState(() {});
            }
          }
        });
  }
}
