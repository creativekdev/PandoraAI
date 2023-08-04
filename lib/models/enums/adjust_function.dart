import 'package:cartoonizer/images-res.dart';

///auto generate code, please do not modify;
enum AdjustFunction {
  brightness,
  contrast,
  saturation,
  noise,
  pixelate,
  blur,
  sharpen,
  hue,
  UNDEFINED,
}

class AdjustFunctionUtils {
  static AdjustFunction build(String? value) {
    switch (value) {
      case 'brightness':
        return AdjustFunction.brightness;
      case 'contrast':
        return AdjustFunction.contrast;
      case 'saturation':
        return AdjustFunction.saturation;
      case 'noise':
        return AdjustFunction.noise;
      case 'pixelate':
        return AdjustFunction.pixelate;
      case 'blur':
        return AdjustFunction.blur;
      case 'sharpen':
        return AdjustFunction.sharpen;
      case 'hue':
        return AdjustFunction.hue;
      default:
        return AdjustFunction.UNDEFINED;
    }
  }
}

extension AdjustFunctionEx on AdjustFunction {
  title() {
    switch (this) {
      case AdjustFunction.brightness:
        return 'Brightness';
      case AdjustFunction.contrast:
        return 'Contrast';
      case AdjustFunction.saturation:
        return 'Saturation';
      case AdjustFunction.noise:
        return 'Noise';
      case AdjustFunction.pixelate:
        return 'Pixelate';
      case AdjustFunction.blur:
        return 'Blur';
      case AdjustFunction.sharpen:
        return 'Sharpen';
      case AdjustFunction.hue:
        return 'Hue';
      case AdjustFunction.UNDEFINED:
        return 'UNDEFINED';
    }
  }

  value() {
    switch (this) {
      case AdjustFunction.brightness:
        return 'brightness';
      case AdjustFunction.contrast:
        return 'contrast';
      case AdjustFunction.saturation:
        return 'saturation';
      case AdjustFunction.noise:
        return 'noise';
      case AdjustFunction.pixelate:
        return 'pixelate';
      case AdjustFunction.blur:
        return 'blur';
      case AdjustFunction.sharpen:
        return 'sharpen';
      case AdjustFunction.hue:
        return 'hue';
      case AdjustFunction.UNDEFINED:
        return 'UNDEFINED';
    }
  }

  icon() {
    switch (this) {
      case AdjustFunction.brightness:
        return Images.brightness;
      case AdjustFunction.contrast:
        return Images.contrast;
      case AdjustFunction.saturation:
        return Images.saturation;
      case AdjustFunction.noise:
        return Images.noise;
      case AdjustFunction.pixelate:
        return Images.pixelate;
      case AdjustFunction.blur:
        return Images.blur;
      case AdjustFunction.sharpen:
        return Images.sharpen;
      case AdjustFunction.hue:
        return Images.hue;
      case AdjustFunction.UNDEFINED:
        return Images.brightness;
    }
  }
}
