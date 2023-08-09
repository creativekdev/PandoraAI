import 'package:cached_network_image/cached_network_image.dart';
import 'package:skeletons/skeletons.dart';

import '../../Common/importFile.dart';

class CachedNetworkImageFixLoadError extends StatefulWidget {
  final String imageUrl;
  final double height;
  final double width;
  final BoxFit fit;

  const CachedNetworkImageFixLoadError({
    Key? key,
    required this.imageUrl,
    required this.height,
    required this.width,
    required this.fit,
  }) : super(key: key);

  @override
  _CachedNetworkImageFixLoadErrorState createState() => _CachedNetworkImageFixLoadErrorState();
}

class _CachedNetworkImageFixLoadErrorState extends State<CachedNetworkImageFixLoadError> {
  late ValueNotifier<String> _notifier;
  int countLoadImg = 0;

  @override
  void initState() {
    super.initState();
    _notifier = ValueNotifier(widget.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: _notifier,
        builder: (context, value, child) {
          return CachedNetworkImage(
            cacheKey: _notifier.value.toString(),
            imageUrl: widget.imageUrl,
            placeholder: (context, url) => SkeletonAvatar(
              style: SkeletonAvatarStyle(
                height: widget.height,
                width: widget.width,
              ),
            ),
            errorWidget: (context, url, error) {
              if (countLoadImg < 10) {
                Future.delayed(Duration(milliseconds: 100), () async {
                  countLoadImg++;
                  _notifier.value = _notifier.value + DateTime.now().millisecondsSinceEpoch.toString();
                });
                return SkeletonAvatar(
                  style: SkeletonAvatarStyle(
                    height: widget.height,
                    width: widget.width,
                  ),
                );
              } else {
                return Container();
              }
            },
            fit: widget.fit ?? BoxFit.cover,
            height: widget.height,
            width: widget.width,
          );
        });
  }
}
