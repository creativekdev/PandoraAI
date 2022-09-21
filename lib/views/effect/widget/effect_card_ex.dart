import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Widgets/cacheImage/cached_network_image_utils.dart';
import 'package:cartoonizer/Widgets/cacheImage/image_cache_manager.dart';
import 'package:cartoonizer/Widgets/video/effect_video_player.dart';
import 'package:cartoonizer/common/importFile.dart';

class EffectCardEx {
  Widget urlWidget(BuildContext context, {required String url, required double width, required double height}) {
    if (url.contains('mp4')) {
      return _videoWidget(context, url: url, width: width, height: height);
    } else {
      return _imageWidget(context, url: url, width: width, height: height);
    }
  }

  Widget _videoWidget(BuildContext context, {required String url, required double width, required double height}) => Stack(
        children: [
          EffectVideoPlayer(url: url),
          Positioned(
            right: $(5),
            top: $(5),
            child: Image.asset(
              ImagesConstant.ic_video,
              height: $(24),
              width: $(24),
            ),
          ),
        ],
      ).intoContainer(width: width, height: height);

  Widget _imageWidget(
    BuildContext context, {
    required String url,
    required double width,
    required double height,
  }) =>
      CachedNetworkImageUtils.custom(
        context: context,
        imageUrl: url,
        fit: BoxFit.fill,
        width: width,
        height: height,
        placeholder: (context, url) => loadingWidget(context, width: width, height: height),
        errorWidget: (context, url, error) => loadingWidget(context, width: width, height: height),
      );

  Widget loadingWidget(
    BuildContext context, {
    required double width,
    required double height,
  }) =>
      Container(
        width: width,
        height: height,
        color: ColorConstant.CardColor,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
}
