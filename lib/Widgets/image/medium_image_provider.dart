import 'dart:ui' as ui;

import 'package:cartoonizer/Common/importFile.dart';
import 'package:cartoonizer/Widgets/image/sync_image_provider.dart';
import 'package:cartoonizer/utils/utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photo_gallery/photo_gallery.dart';

class MediumImage extends ImageProvider<MediumImage> {
  final Medium medium;
  final String failedImageAssets;
  final Function(Medium medium)? onError;

  final double scale;
  final int width;
  final int height;

  const MediumImage(
    this.medium, {
    this.scale = 1.0,
    required this.height,
    required this.width,
    required this.failedImageAssets,
    this.onError,
  })  : assert(medium != null),
        assert(scale != null);

  @override
  Future<MediumImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<MediumImage>(this);
  }

  @override
  ImageStreamCompleter load(MediumImage key, DecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, null, decode),
      scale: key.scale,
      debugLabel: key.medium.filename,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Path: ${medium.filename}'),
      ],
    );
  }

  @override
  ImageStreamCompleter loadBuffer(MediumImage key, DecoderBufferCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode, null),
      scale: key.scale,
      debugLabel: key.medium.filename,
      informationCollector: () => <DiagnosticsNode>[
        ErrorDescription('Path: ${medium.filename}'),
      ],
    );
  }

  Future<ui.Codec> _loadAsync(MediumImage key, DecoderBufferCallback? decode, DecoderCallback? decodeDeprecated) async {
    assert(key == this);

    try {
      Uint8List bytes;
      if ((medium.filename ?? '').toUpperCase().contains('.HEIC')) {
        var file = await heicToImage(medium);
        var uint8list = await FlutterImageCompress.compressWithFile(
          file.path,
          format: CompressFormat.heic,
          minWidth: width,
          minHeight: height,
          quality: 100,
        );
        bytes = uint8list!;
      } else {
        var byte = await medium.getThumbnail(width: width, height: height, highQuality: true);
        bytes = await Uint8List.fromList(byte);
      }
      if (bytes.lengthInBytes == 0) {
        // The file may become available later.
        PaintingBinding.instance.imageCache.evict(key);
        return await getWrongData(decode, decodeDeprecated);
      }

      if (decode != null) {
        return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
      }
      return decodeDeprecated!(bytes);
    } catch (e) {
      // The file may become available later.
      PaintingBinding.instance.imageCache.evict(key);
      return await getWrongData(decode, decodeDeprecated);
      // throw StateError('$medium is empty and cannot be loaded as an image.');
    }
  }

  getWrongData(DecoderBufferCallback? decode, DecoderCallback? decodeDeprecated) async {
    onError?.call(medium);
    var wrongImage = await SyncAssetImage(assets: failedImageAssets).getImage();
    var byteData = await wrongImage.image.toByteData(format: ui.ImageByteFormat.png);
    var byte = byteData!.buffer.asUint8List();
    if (decode != null) {
      return decode(await ui.ImmutableBuffer.fromUint8List(byte));
    }
    return decodeDeprecated!(byte);
  }

  @override
  bool operator ==(Object other) {
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is MediumImage && other.medium.filename == medium.filename && other.scale == scale;
  }

  @override
  int get hashCode => Object.hash(medium.filename, scale);

  @override
  String toString() => '${objectRuntimeType(this, 'MediumImage')}("${medium.filename}", scale: $scale)';
}
