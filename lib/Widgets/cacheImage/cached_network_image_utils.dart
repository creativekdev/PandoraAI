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
    // bool useOld = false,
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
    return !imageUrl.isGoogleAccount
        ? FutureLoadingImage(
            key: key is GlobalKey<FutureLoadingImageState> ? key : null,
            url: imageUrl,
            errorWidget: errorWidget,
            placeholder: placeholder,
            width: width,
            height: height,
            fit: fit,
            repeat: repeat,
            color: color,
            alignment: alignment,
            scale: 1.0,
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
  double scale;

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
    required this.scale,
  });

  @override
  State<StatefulWidget> createState() {
    return FutureLoadingImageState();
  }
}

class FutureLoadingImageState extends State<FutureLoadingImage> {
  late String _url;
  CacheManager cacheManager = AppDelegate.instance.getManager();
  EffectManager effectManager = AppDelegate.instance.getManager();
  late bool _downloading = true;
  DownloadListener? _downloadListener;
  String? _key;
  late String _fileName;
  late double? _width;
  late double? _height;
  late BoxFit _fit;
  late ImageRepeat _repeat;
  BlendMode? _colorBlendMode;
  Color? _color;
  late AlignmentGeometry _alignment;
  late double _scale;

  late PlaceholderWidgetBuilder placeholder;
  late LoadingErrorWidgetBuilder errorWidget;
  File? _data;
  bool _collectState = false;
  double? cacheScale;

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

  collectGarbadge() {
    setState(() {
      _data = null;
      _downloading = true;
      _collectState = true;
    });
  }

  void initData() {
    _width = widget.width;
    _height = widget.height;
    _fit = widget.fit;
    _color = widget.color;
    _repeat = widget.repeat;
    _colorBlendMode = widget.colorBlendMode;
    placeholder = widget.placeholder;
    errorWidget = widget.errorWidget;
    _scale = widget.scale;
    _width = widget.width;
    _height = widget.height;
    _alignment = widget.alignment;
  }

  void updateData() {
    _collectState = false;
    _url = widget.url;
    cacheScale = effectManager.scale(_url);
    _downloadListener = DownloadListener(
        onChanged: (count, total) {},
        onError: (error) {
          if (mounted) {
            setState(() {
              this._data = null;
              _downloading = false;
            });
          }
        },
        onFinished: (File file) {
          if (mounted) {
            setState(() {
              var imageDir = cacheManager.storageOperator.imageDir;
              var savePath = imageDir.path + _fileName;
              this._data = File(savePath);
              _downloading = false;
            });
          }
        });
    _fileName = EncryptUtil.encodeMd5(_url);
    _downloading = true;
    var imageDir = cacheManager.storageOperator.imageDir;
    var savePath = imageDir.path + _fileName;
    File data = File(savePath);
    if (data.existsSync()) {
      this._data = data;
      _downloading = false;
    } else {
      _downloading = true;
      Downloader.instance.download(_url, savePath).then((value) {
        _key = value;
        Downloader.instance.subscribe(_key!, _downloadListener!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_downloading || _collectState) {
      return placeholder.call(context, _url);
    }
    if (_data == null || !_data!.existsSync()) {
      return errorWidget.call(context, _url, Exception('load image Failed'));
    }
    var fileImage = FileImage(_data!, scale: _scale);
    if (cacheScale == null) {
      var resolve = fileImage.resolve(ImageConfiguration.empty);
      resolve.addListener(ImageStreamListener((image, synchronousCall) {
        var scale = image.image.width / image.image.height;
        effectManager.setScale(_url, scale);
        if (_width == null && _height == null) {
          _width = image.image.width.toDouble();
          _height = image.image.height.toDouble();
        } else if (_width == null) {
          _width = _height! * scale;
        } else if (_height == null) {
          _height = _width! / scale;
        }
        if (mounted) {
          setState(() {});
        }
      }));
    } else {
      if (_width == null && _height == null) {
        // do nothing
      } else if (_width == null) {
        _width = _height! * cacheScale!;
      } else if (_height == null) {
        _height = _width! / cacheScale!;
      }
    }
    if (_width != null && _height != null) {
      return Image(
        image: fileImage,
        width: _width,
        height: _height,
        fit: _fit,
        repeat: _repeat,
        colorBlendMode: _colorBlendMode,
        color: _color,
        alignment: _alignment,
        errorBuilder: (context, error, strace) {
          _data?.deleteSync();
          this._data = null;
          updateData();
          return errorWidget.call(context, _url, Exception('load image Failed'));
        },
      );
    } else {
      return placeholder.call(context, _url);
    }
  }
}
