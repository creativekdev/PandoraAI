import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';

import '../../Common/importFile.dart';

class HomeImageDetailCard extends StatefulWidget {
  String url;
  double width;
  double height;

  HomeImageDetailCard({
    super.key,
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  State<HomeImageDetailCard> createState() => _HomeImageDetailCardState();
}

class _HomeImageDetailCardState extends State<HomeImageDetailCard> {
  late String url;
  bool loading = true;
  bool needBlur = false;
  double width = 0;
  double height = 0;
  Uint8List? firstFrame;

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didUpdateWidget(covariant HomeImageDetailCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.url != url) {
      init();
    }
  }

  init() {
    url = widget.url;
    if (width != widget.width) {
      width = widget.width;
    }
    if (height != widget.height) {
      height = widget.height;
    }
    SyncCachedNetworkImage(url: url).getImage().then((value) {
      if (!mounted) {
        return;
      }
      var d = value.image.width / value.image.height;
      setState(() {
        loading = false;
        needBlur = d > 0.95 && d < 1.05;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Stack(
        children: [
          CachedNetworkImageUtils.custom(
            context: context,
            imageUrl: url,
            width: width,
            height: height,
            filterQuality: FilterQuality.low,
            fit: BoxFit.cover,
          ),
          Container(width: width, height: height).blur(),
        ],
      ).intoContainer(width: width, height: height);
    }
    if (!needBlur) {
      return CachedNetworkImageUtils.custom(
        context: context,
        imageUrl: url,
        width: width,
        height: height,
        fit: BoxFit.cover,
      );
    }
    return Stack(
      children: [
        firstFrame != null
            ? Image.memory(
                firstFrame!,
                width: width,
                height: height,
                fit: BoxFit.cover,
              )
            : CachedNetworkImageUtils.custom(
                context: context,
                imageUrl: url,
                width: width,
                height: height,
                fit: BoxFit.cover,
              ),
        CachedNetworkImageUtils.custom(
          context: context,
          imageUrl: url,
          width: width,
          height: ScreenUtil.screenSize.height * 0.65,
          fit: BoxFit.cover,
        )
            .intoCenter()
            .intoContainer(
              width: width,
              height: height,
            )
            .blur(),
      ],
    ).intoContainer(width: width, height: height);
  }
}
