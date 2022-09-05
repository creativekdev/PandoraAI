import 'dart:ui';

import 'package:cartoonizer/images-res.dart';

///auto generate code, please do not modify;
enum EffectTag {
  NEW,
  HOT,
  UNDEFINED,
}

class EffectTagUtils {
  static EffectTag build(String? value) {
    switch (value?.toLowerCase()) {
      case 'new':
        return EffectTag.NEW;
      case 'hot':
        return EffectTag.HOT;
      default:
        return EffectTag.UNDEFINED;
    }
  }
}

extension EffectTagEx on EffectTag {
  value() {
    switch (this) {
      case EffectTag.NEW:
        return 'New';
      case EffectTag.HOT:
        return 'Hot';
      case EffectTag.UNDEFINED:
        return null;
    }
  }

  image() {
    switch (this) {
      case EffectTag.NEW:
        return Images.ic_tag_new;
      case EffectTag.HOT:
        return Images.ic_tag_hot;
      case EffectTag.UNDEFINED:
        return null;
    }
  }
}
