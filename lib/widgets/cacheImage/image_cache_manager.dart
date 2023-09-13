import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cartoonizer/utils/gif_util.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'dart:ui' as ui;
import 'dart:math';

import 'package:image/image.dart' as libImage;
import 'package:worker_manager/worker_manager.dart';

const supportedFileNames = ['jpg', 'jpeg', 'png', 'tga', 'cur', 'ico', 'gif', 'webp'];
const supportedGifFileNames = ['gif', 'webp'];

///
/// @Author: wangyu
/// @Date: 2022/6/6
///
class CachedImageCacheManager extends CacheManager with ImageCacheManager {
  static const key = 'CachedImageCacheData';

  static final CachedImageCacheManager _instance = CachedImageCacheManager._();

  factory CachedImageCacheManager() {
    return _instance;
  }

  CachedImageCacheManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 180),
          maxNrOfCacheObjects: 20,
        ));
}

class TransAICachedManager extends CacheManager with ImageCacheManager {
  static const key = 'TransAICachedManager';

  static final TransAICachedManager _instance = TransAICachedManager._();

  factory TransAICachedManager() {
    return _instance;
  }

  TransAICachedManager._()
      : super(Config(
          key,
          stalePeriod: const Duration(days: 1),
          maxNrOfCacheObjects: 10,
        ));
}

mixin AppImageCacheManager implements ImageCacheManager {
  /// Returns a resized image file to fit within maxHeight and maxWidth. It
  /// tries to keep the aspect ratio. It stores the resized image by adding
  /// the size to the key or url. For example when resizing
  /// https://via.placeholder.com/150 to max width 100 and height 75 it will
  /// store it with cacheKey resized_w100_h75_https://via.placeholder.com/150.
  ///
  /// When the resized file is not found in the cache the original is fetched
  /// from the cache or online and stored in the cache. Then it is resized
  /// and returned to the caller.
  @override
  Stream<FileResponse> getImageFile(
    String url, {
    String? key,
    Map<String, String>? headers,
    bool withProgress = false,
    int? maxHeight,
    int? maxWidth,
  }) async* {
    if (maxHeight == null && maxWidth == null) {
      yield* getFileStream(url, key: key, headers: headers, withProgress: withProgress);
      return;
    }
    key ??= url;
    var resizedKey = 'x-resized';
    if (maxWidth != null) resizedKey += '_w$maxWidth';
    if (maxHeight != null) resizedKey += '_h$maxHeight';
    resizedKey += '_$key';

    var fromCache = await getFileFromCache(resizedKey);
    if (fromCache != null) {
      yield fromCache;
      if (fromCache.validTill.isAfter(DateTime.now())) {
        return;
      }
      withProgress = false;
    }
    var runningResize = _runningResizes[resizedKey];
    if (runningResize == null) {
      runningResize = _fetchedResizedFile(
        url,
        key,
        resizedKey,
        headers,
        withProgress,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
      ).asBroadcastStream();
      _runningResizes[resizedKey] = runningResize;
    }
    yield* runningResize;
    _runningResizes.remove(resizedKey);
  }

  final Map<String, Stream<FileResponse>> _runningResizes = {};

  Future<FileInfo> _resizeImageFile(
    FileInfo originalFile,
    String key,
    int? maxWidth,
    int? maxHeight,
  ) async {
    var originalFileName = originalFile.file.path;
    var fileExtension = originalFileName.split('.').last;
    if (!supportedFileNames.contains(fileExtension)) {
      return originalFile;
    }
    var image = await _decodeImage(originalFile.file);
    var shouldResize = maxWidth != null
        ? image.width > maxWidth
        : false || maxHeight != null
            ? image.height > maxHeight
            : false;
    if (!shouldResize) return originalFile;

    if (maxWidth != null && maxHeight != null) {
      var resizeFactorWidth = image.width / maxWidth;
      var resizeFactorHeight = image.height / maxHeight;
      var resizeFactor = max(resizeFactorHeight, resizeFactorWidth);

      maxWidth = (image.width / resizeFactor).round();
      maxHeight = (image.height / resizeFactor).round();
    }

    Uint8List resizedFile;
    if (supportedGifFileNames.contains(fileExtension)) {
      resizedFile = await _decodeGifImage(originalFile.file, width: maxWidth!, height: maxHeight!);
    } else {
      var resized = await _decodeImage(originalFile.file, width: maxWidth, height: maxHeight, allowUpscaling: false);
      resizedFile = (await resized.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
    }
    var maxAge = originalFile.validTill.difference(DateTime.now());

    var file = await putFile(
      originalFile.originalUrl,
      resizedFile,
      key: key,
      maxAge: maxAge,
      fileExtension: fileExtension,
    );

    return FileInfo(
      file,
      originalFile.source,
      originalFile.validTill,
      originalFile.originalUrl,
    );
  }

  Stream<FileResponse> _fetchedResizedFile(
    String url,
    String originalKey,
    String resizedKey,
    Map<String, String>? headers,
    bool withProgress, {
    int? maxWidth,
    int? maxHeight,
  }) async* {
    await for (var response in getFileStream(
      url,
      key: originalKey,
      headers: headers,
      withProgress: withProgress,
    )) {
      if (response is DownloadProgress) {
        yield response;
      }
      if (response is FileInfo) {
        yield await _resizeImageFile(
          response,
          resizedKey,
          maxWidth,
          maxHeight,
        );
      }
    }
  }
}

Future<Uint8List> _decodeGifImage(File file, {required int width, required int height}) async {
  final completer = Completer<Uint8List>();
  if (file.path.contains('.webp')) {
    var uint8list = await FlutterImageCompress.compressWithList(
      await file.readAsBytes(),
      minWidth: width,
      minHeight: height,
      format: CompressFormat.webp,
      quality: 80,
    );
    return uint8list;
    var decodeAnim = await new Executor().execute(arg1: await file.readAsBytes(), fun1: _decodeWebPAnimation);
    var frames = decodeAnim!.frames;
    List<libImage.Image> newFrames = [];
    for (var value in frames) {
      var resImage = libImage.copyResize(value, width: width, height: height);
      newFrames.add(resImage);
    }
    var list = await GifUtil.generateGif(frames, duration: 0);
    if (!completer.isCompleted) {
      completer.complete(Uint8List.fromList(list!));
    }
  } else if (file.path.contains('.gif')) {
    var decodeAnim = await new Executor().execute(arg1: await file.readAsBytes(), fun1: _decodeGifAnimation);
    var frames = decodeAnim!.frames;
    List<libImage.Image> newFrames = [];
    for (var value in frames) {
      var resImage = libImage.copyResize(value, width: width, height: height);
      newFrames.add(resImage);
    }
    var list = await GifUtil.generateGif(frames, duration: 0);
    if (!completer.isCompleted) {
      completer.complete(Uint8List.fromList(list!));
    }
  }
  return completer.future;
}

Future<ui.Image> _decodeImage(File file, {int? width, int? height, bool allowUpscaling = false}) {
  var shouldResize = width != null || height != null;
  var fileImage = FileImage(file);
  final image = shouldResize ? ResizeImage(fileImage, width: width, height: height, allowUpscaling: allowUpscaling) : fileImage as ImageProvider;
  final completer = Completer<ui.Image>();
  image.resolve(const ImageConfiguration()).addListener(ImageStreamListener((info, _) {
    if (!completer.isCompleted) {
      completer.complete(info.image);
      image.evict();
    }
  }));
  return completer.future;
}

libImage.Animation? _decodeWebPAnimation(List<int> bytes, TypeSendPort port) {
  return libImage.decodeWebPAnimation(bytes);
}

libImage.Animation? _decodeGifAnimation(List<int> bytes, TypeSendPort port) {
  return libImage.decodeGifAnimation(bytes);
}
