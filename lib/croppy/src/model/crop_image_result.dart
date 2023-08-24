import 'dart:ui' as ui;

import 'package:cartoonizer/croppy/croppy.dart';

/// The result of a crop operation.
class CropImageResult {
  const CropImageResult({
    required this.uiImage,
    required this.transformationsData,
  });

  /// The `dart:ui` image.
  final ui.Image uiImage;

  /// The list of transformations applied to the image.
  final CroppableImageData transformationsData;
}
