///auto generate code, please do not modify;
///
///   @JSONField(name: 'adType')
///   String? mAdTypeString;
///
///   @JSONField(serialize: false, deserialize: false)
///   AdType? _mAdType;
///
///   AdType get mAdType {
///     if (_mAdTypeEnum == null) {
///       _mAdType = AdTypeUtils.build(mAdTypeString);
///     }
///     return _mAdType!;
///   }
///
///   set mAdType(AdType type) {
///     _mAdType = type;
///     mAdTypeString = _mAdType!.value();
///   }

enum AdType {
  splash,
  card,
  processing,
  UNDEFINED,
}

class AdTypeUtils {
  static AdType build(String? value) {
    switch (value) {
      case 'splash':
        return AdType.splash;
      case 'card':
        return AdType.card;
      case 'processing':
        return AdType.processing;
      default:
        return AdType.UNDEFINED;
    }
  }
}

extension AdTypeEx on AdType {
  value() {
    switch (this) {
      case AdType.splash:
        return 'splash';
      case AdType.card:
        return 'card';
      case AdType.processing:
        return 'processing';
      case AdType.UNDEFINED:
        return null;
    }
  }
}
