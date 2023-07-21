import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';

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
  State<StatefulWidget> createState() {
    return HomeImageDetailCardState();
  }
}

class HomeImageDetailCardState extends State<HomeImageDetailCard> {
  String url = '';
  double width = 0;
  double height = 0;
  bool needBlur = false;
  CacheManager cacheManager = AppDelegate.instance.getManager();

  @override
  void initState() {
    super.initState();
    init();
  }

  @override
  void didUpdateWidget(covariant HomeImageDetailCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    init();
  }

  init() {
    if (url != widget.url) {
      url = widget.url;
      syncScale();
    }
    width = widget.width;
    height = widget.height;
  }

  syncScale() {
    SyncCachedNetworkImage(url: url).getImage().then((value) {
      cacheManager.imageScaleOperator.setScale(url, value.image.width / value.image.height);
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var scale = cacheManager.imageScaleOperator.getScale(url);
    if (scale == null || (scale < 0.95 || scale > 1.05)) {
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
        CachedNetworkImageUtils.custom(
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
