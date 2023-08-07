import 'package:cartoonizer/images-res.dart';

///auto generate code, please do not modify;
enum ImageEditionFunction {
  effect,
  filter,
  adjust,
  crop,
  removeBg,
  sticker,
  UNDEFINED,
}

class ImageEditionFunctionUtils {
  static ImageEditionFunction build(String? value) {
    switch (value) {
      case 'effect':
        return ImageEditionFunction.effect;
      case 'filter':
        return ImageEditionFunction.filter;
      case 'adjust':
        return ImageEditionFunction.adjust;
      case 'crop':
        return ImageEditionFunction.crop;
      case 'removeBg':
        return ImageEditionFunction.removeBg;
      case 'sticker':
        return ImageEditionFunction.sticker;
      default:
        return ImageEditionFunction.UNDEFINED;
    }
  }
}

extension ImageEditionFunctionEx on ImageEditionFunction {
  title() {
    switch (this) {
      case ImageEditionFunction.effect:
        return 'Effects';
      case ImageEditionFunction.filter:
        return 'Filters';
      case ImageEditionFunction.adjust:
        return 'Adjust';
      case ImageEditionFunction.crop:
        return 'Crop';
      case ImageEditionFunction.removeBg:
        return 'RemoveBG';
      case ImageEditionFunction.UNDEFINED:
        return null;
      case ImageEditionFunction.sticker:
        return 'Sticker';
    }
  }

  value() {
    switch (this) {
      case ImageEditionFunction.effect:
        return 'effect';
      case ImageEditionFunction.filter:
        return 'filter';
      case ImageEditionFunction.adjust:
        return 'adjust';
      case ImageEditionFunction.crop:
        return 'crop';
      case ImageEditionFunction.removeBg:
        return 'removeBg';
      case ImageEditionFunction.UNDEFINED:
        return null;
      case ImageEditionFunction.sticker:
        return 'sticker';
    }
  }

  icon() {
    switch (this) {
      case ImageEditionFunction.effect:
        return Images.ic_effect;
      case ImageEditionFunction.filter:
        return Images.ic_filter;
      case ImageEditionFunction.adjust:
        return Images.ic_adjust;
      case ImageEditionFunction.crop:
        return Images.ic_crop;
      case ImageEditionFunction.removeBg:
        return Images.ic_background;
      case ImageEditionFunction.UNDEFINED:
        return Images.ic_effect;
      case ImageEditionFunction.sticker:
        return Images.ic_sticker;
    }
  }
}
