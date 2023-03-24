import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/state/app_state.dart';
import 'package:cartoonizer/api/downloader.dart';
import 'package:cartoonizer/app/app.dart';
import 'package:cartoonizer/app/cache/cache_manager.dart';
import 'package:cartoonizer/app/effect_manager.dart';
import 'package:cartoonizer/utils/string_ex.dart';
import 'package:common_utils/common_utils.dart';

import 'image_cache_manager.dart';

class CachedNetworkImageUtils {
  static Widget custom({
    bool useOld = true,
    bool useCachedScale = false,
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
        return CircularProgressIndicator().intoContainer(width: $(25), height: $(25)).intoCenter().intoContainer(width: width, height: height ?? $(25));
      };
    }
    if (errorWidget == null) {
      errorWidget = (context, url, error) {
        return CircularProgressIndicator().intoContainer(width: $(25), height: $(25)).intoCenter().intoContainer(width: width, height: height ?? $(25));
      };
    }
    if (TextUtil.isEmpty(imageUrl.trim())) {
      return errorWidget.call(context, imageUrl, Exception('image url is empty'));
    }
    if (useOld || imageUrl.contains('.webp')) {
      return CachedNetworkImage(
        key: key is GlobalKey<FutureLoadingImageState> ? null : key,
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
    return !imageUrl.isGoogleAccount
        ? FutureLoadingImage(
            key: key is GlobalKey<FutureLoadingImageState> ? key : null,
            url: imageUrl,
            useCachedScale: useCachedScale,
            errorWidget: errorWidget,
            placeholder: placeholder,
            width: width,
            height: height,
            fit: fit,
            repeat: repeat,
            color: color,
            alignment: alignment,
          )
        : CachedNetworkImage(
            key: key is GlobalKey<FutureLoadingImageState> ? null : key,
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

class FutureLoadingImage extends StatefulWidget {
  String url;
  PlaceholderWidgetBuilder placeholder;
  LoadingErrorWidgetBuilder errorWidget;
  double? width;
  double? height;
  BoxFit fit;
  ImageRepeat repeat;
  BlendMode? colorBlendMode;
  Color? color;
  AlignmentGeometry alignment;
  bool useCachedScale;

  FutureLoadingImage({
    Key? key,
    required this.url,
    required this.placeholder,
    required this.errorWidget,
    this.width,
    this.height,
    required this.fit,
    required this.repeat,
    this.colorBlendMode,
    this.color,
    required this.alignment,
    this.useCachedScale = false,
  });

  @override
  State<StatefulWidget> createState() {
    return FutureLoadingImageState();
  }
}

class FutureLoadingImageState extends State<FutureLoadingImage> {
  late bool useCachedScale;
  late String url;
  CacheManager cacheManager = AppDelegate.instance.getManager();
  late bool downloading = true;
  DownloadListener? downloadListener;
  String? key;
  late String fileName;
  late double? width;
  late double? height;
  late BoxFit fit;
  late ImageRepeat repeat;
  BlendMode? colorBlendMode;
  Color? color;
  late AlignmentGeometry alignment;

  PlaceholderWidgetBuilder? placeholder;
  LoadingErrorWidgetBuilder? errorWidget;
  File? data;

  @override
  initState() {
    super.initState();
    initData();
    updateData();
  }

  @override
  didUpdateWidget(FutureLoadingImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    initData();
    if (widget.url != oldWidget.url) {
      updateData();
    }
  }

  @override
  dispose() {
    super.dispose();
    data = null;
    placeholder = null;
    errorWidget = null;
  }

  void initData() {
    width = widget.width;
    height = widget.height;
    fit = widget.fit;
    color = widget.color;
    repeat = widget.repeat;
    colorBlendMode = widget.colorBlendMode;
    placeholder = widget.placeholder;
    errorWidget = widget.errorWidget;
    alignment = widget.alignment;
    useCachedScale = widget.useCachedScale;
  }

  void updateData() {
    url = widget.url;
    downloadListener = DownloadListener(
        onChanged: (count, total) {},
        onError: (error) {
          if (mounted) {
            setState(() {
              this.data = null;
              downloading = false;
            });
          }
        },
        onFinished: (File file) {
          if (mounted) {
            setState(() {
              var imageDir = cacheManager.storageOperator.imageDir;
              var savePath = imageDir.path + fileName;
              this.data = File(savePath);
              downloading = false;
            });
          }
        });
    fileName = EncryptUtil.encodeMd5(url);
    downloading = true;
    var imageDir = cacheManager.storageOperator.imageDir;
    var savePath = imageDir.path + fileName;
    File data = File(savePath);
    if (data.existsSync()) {
      this.data = data;
      downloading = false;
    } else {
      downloading = true;
      Downloader.instance.download(url, savePath).then((value) {
        key = value;
        Downloader.instance.subscribe(key!, downloadListener!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (downloading) {
      return placeholder!.call(context, url);
    }
    if (data == null || !data!.existsSync()) {
      return errorWidget!.call(context, url, Exception('load image Failed'));
    }
    var fileImage = FileImage(data!);
    var resolve = fileImage.resolve(ImageConfiguration.empty);
    resolve.addListener(ImageStreamListener((image, synchronousCall) {
      var scale = image.image.width / image.image.height;
      var cacheScale = cacheManager.imageScaleOperator.getScale(url);
      if (cacheScale == null) {
        if (scale > 1.05) {
          cacheScale = 1.5;
        } else if (scale < 0.95) {
          cacheScale = 0.75;
        } else {
          cacheScale = 1;
        }
        cacheManager.imageScaleOperator.setScale(url, cacheScale);
      }
      if (width == null && height == null) {
        width = image.image.width.toDouble();
        if (useCachedScale) {
          height = width! / cacheScale;
        } else {
          height = image.image.height.toDouble();
        }
      } else if (width == null) {
        width = height! * (useCachedScale ? cacheScale : scale);
      } else if (height == null) {
        height = width! / (useCachedScale ? cacheScale : scale);
      }
      if (mounted) {
        setState(() {});
      }
    }));
    return Image(
      image: fileImage,
      width: width,
      height: height,
      fit: fit,
      repeat: repeat,
      colorBlendMode: colorBlendMode,
      color: color,
      alignment: alignment,
      errorBuilder: (context, error, strace) {
        data?.deleteSync();
        this.data = null;
        updateData();
        return errorWidget!.call(context, url, Exception('load image Failed'));
      },
    ).intoContainer(width: width, height: height ?? width);
  }
}
