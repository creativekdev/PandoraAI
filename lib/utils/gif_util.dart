import 'dart:ui' as ui;

import 'package:cartoonizer/widgets/image/sync_image_provider.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as libImage;
import 'package:worker_manager/worker_manager.dart';

/// gif工具类
class GifUtil {
  /// 获取第一帧
  static Future<ImageInfo> getSplashFrame(ImageProvider provider) async {
    ui.Codec codec = await _getCodec(provider);
    var frameInfo = await codec.getNextFrame();
    return ImageInfo(image: frameInfo.image);
  }

  /// 获取所有帧
  static Future<List<ImageInfo>> getFrames(ImageProvider provider) async {
    List<ImageInfo> infos = [];
    ui.Codec codec = await _getCodec(provider);
    infos = [];
    for (int i = 0; i < codec.frameCount; i++) {
      ui.FrameInfo frameInfo = await codec.getNextFrame();
      //scale ??
      infos.add(ImageInfo(image: frameInfo.image));
    }
    return infos;
  }

  static Future<ui.Codec> _getCodec(ImageProvider provider) async {
    dynamic data;
    if (provider is NetworkImage) {
      var imageInfo = await SyncCachedNetworkImage(url: provider.url).getImage();
      var byteData = await imageInfo.image.toByteData(format: ui.ImageByteFormat.png);
      data = byteData!.buffer.asUint8List();
    } else if (provider is AssetImage) {
      AssetBundleImageKey key = await provider.obtainKey(const ImageConfiguration());
      data = await key.bundle.load(key.name);
    } else if (provider is FileImage) {
      data = await provider.file.readAsBytes();
    } else if (provider is MemoryImage) {
      data = provider.bytes;
    }
    ui.Codec codec = await PaintingBinding.instance.instantiateImageCodecWithSize(await ui.ImmutableBuffer.fromUint8List(data.buffer.asUint8List()));
    return codec;
  }

  ///生成gif
  static Future<List<int>?> generateGif(
    List<libImage.Image> frames, {
    int duration = 16,
  }) async {
    if (frames.isEmpty) {
      return [];
    }
    libImage.Animation animation = libImage.Animation();
    for (var i = 0; i < frames.length; i++) {
      var image = frames[i];
      image.duration = duration;
      animation.addFrame(image);
    }
    var encodeGifAnimation = await Executor().execute(arg1: animation, arg2: 10, fun2: _encodeGifAnim);
    return encodeGifAnimation;
  }
}

List<int>? _encodeGifAnim(libImage.Animation animation, int factor, TypeSendPort port) {
  return libImage.encodeGifAnimation(animation, samplingFactor: factor);
}
