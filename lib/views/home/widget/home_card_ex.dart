import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/common/importFile.dart';
import 'package:cartoonizer/utils/cacheImage/image_cache_manager.dart';

class HomeCardEx {

  Widget imageWidget(BuildContext context, {required String url, required double width, required double height}) =>
      CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.fill,
        width: width,
        height: height,
        placeholder: (context, url) => loadingWidget(context),
        errorWidget: (context, url, error) => loadingWidget(context),
        cacheManager: CachedImageCacheManager(),
      );

  Widget loadingWidget(BuildContext context) => Container(
    width: double.maxFinite,
    height: double.maxFinite,
    color: ColorConstant.CardColor,
    child: Center(
      child: CircularProgressIndicator(),
    ),
  );
}