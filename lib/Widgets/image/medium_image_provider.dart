import 'dart:ui' as ui;

import 'package:cartoonizer/Common/importFile.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:photo_gallery/photo_gallery.dart';

class MediumImage extends ImageProvider<MediumImage> {
  final Medium medium;

  final double scale;
  final int width;
  final int height;

  const MediumImage(
    this.medium, {
    this.scale = 1.0,
    required this.height,
    required this.width,
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
        var file = await medium.getFile();
        var uint8list = await FlutterImageCompress.compressWithFile(
          file.path,
          format: CompressFormat.heic,
          minWidth: 256,
          minHeight: 256,
          quality: 60,
        );
        bytes = uint8list!;
      } else {
        var byte = await medium.getThumbnail(width: width, height: height, highQuality: true);
        bytes = await Uint8List.fromList(byte);
      }
      if (bytes.lengthInBytes == 0) {
        // The file may become available later.
        PaintingBinding.instance.imageCache.evict(key);
        throw StateError('$medium is empty and cannot be loaded as an image.');
      }

      if (decode != null) {
        return decode(await ui.ImmutableBuffer.fromUint8List(bytes));
      }
      return decodeDeprecated!(bytes);
    } catch (e) {
      // The file may become available later.
      PaintingBinding.instance.imageCache.evict(key);
      throw StateError('$medium is empty and cannot be loaded as an image.');
    }
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
