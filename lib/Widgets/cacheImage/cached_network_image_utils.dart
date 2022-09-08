import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Widgets/widget_extensions.dart';
import 'package:cartoonizer/utils/screen_util.dart';
import 'package:common_utils/common_utils.dart';
import 'package:flutter/material.dart';

import 'image_cache_manager.dart';

class CachedNetworkImageUtils {
  static Widget custom({
    required BuildContext context,
    Key? key,
    required String imageUrl,
    Map<String, String>? httpHeaders,
    ImageWidgetBuilder? imageBuilder,
    PlaceholderWidgetBuilder? placeholder,
    ProgressIndicatorBuilder? progressIndicatorBuilder,
    LoadingErrorWidgetBuilder? errorWidget,
    Duration fadeOutDuration = const Duration(milliseconds: 1000),
    Curve fadeOutCurve = Curves.easeOut,
    Duration fadeInDuration = const Duration(milliseconds: 500),
    Curve fadeInCurve = Curves.easeIn,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Alignment alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    bool matchTextDirection = false,
    cacheManager,
    bool useOldImageOnUrlChange = false,
    Color? color,
    FilterQuality filterQuality = FilterQuality.low,
    BlendMode? colorBlendMode,
    Duration? placeholderFadeInDuration,
    int? memCacheWidth,
    int? memCacheHeight,
    String? cacheKey,
    int? maxWidthDiskCache = 1024,
    int? maxHeightDiskCache = 1024,
  }) {
    if (cacheManager == null) {
      cacheManager = CachedImageCacheManager();
    }
    if (placeholder == null) {
      placeholder = (context, url) {
        return CircularProgressIndicator().intoContainer(width: $(25), height: $(25)).intoCenter();
      };
    }
    if (TextUtil.isEmpty(imageUrl)) {
      if (errorWidget == null) {
        return Container(width: width, height: height);
      } else {
        return errorWidget.call(context, imageUrl, Exception('image url is empty'));
      }
    }
    return CachedNetworkImage(
      key: key,
      imageUrl: imageUrl,
      httpHeaders: httpHeaders,
      imageBuilder: imageBuilder,
      placeholder: placeholder,
      placeholderFadeInDuration: placeholderFadeInDuration,
      progressIndicatorBuilder: progressIndicatorBuilder,
      errorWidget: errorWidget,
      fadeOutDuration: fadeOutDuration,
      fadeOutCurve: fadeOutCurve,
      fadeInCurve: fadeInCurve,
      fadeInDuration: fadeInDuration,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      matchTextDirection: matchTextDirection,
      cacheManager: cacheManager,
      useOldImageOnUrlChange: useOldImageOnUrlChange,
      color: color,
      filterQuality: filterQuality,
      colorBlendMode: colorBlendMode,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      cacheKey: cacheKey,
      maxHeightDiskCache: maxHeightDiskCache,
      maxWidthDiskCache: maxWidthDiskCache,
    );
  }
}
