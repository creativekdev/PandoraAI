import 'dart:ui';

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

  color() {
    switch (this) {
      case EffectTag.NEW:
        return Color(0xffff9500);
      case EffectTag.HOT:
        return Color(0xffff0000);
      case EffectTag.UNDEFINED:
        return null;
    }
  }
}
