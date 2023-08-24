import 'package:cartoonizer/croppy/croppy.dart';
import 'package:flutter/widgets.dart';

import '../../../utils/img_utils.dart';

/// Resizes a given [cropRect] to match the given [newAspectRatio].
Rect resizeCropRectWithAspectRatio(
  Rect cropRect,
  CropAspectRatio? newAspectRatio,
  Size originSize,
) {
  if (newAspectRatio == null) return cropRect;
  return ImageUtils.getTargetCoverRect(originSize, Size(newAspectRatio.width.toDouble(), newAspectRatio.height.toDouble()));
}
