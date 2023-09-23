///auto generate code, please do not modify;
///
///   @JSONField(name: 'mHomeItem')
///   String? mHomeItemString;
///
///   @JSONField(serialize: false, deserialize: false)
///   HomeItem? _mHomeItem;
///
///   HomeItem get mHomeItem {
///     if (_mHomeItem == null) {
///       _mHomeItem = HomeItemUtils.build(mHomeItemString);
///     }
///     return _mHomeItem!;
///   }
///
///   set mHomeItem(HomeItem type) {
///     _mHomeItem = type;
///     mHomeItemString = _mHomeItem!.value();
///   }

enum HomeItem {
  banners,
  tools,
  features,
  galleries,
  UNDEFINED,
}

class HomeItemUtils {
  static HomeItem build(String? value) {
    switch (value) {
      case 'banners':
        return HomeItem.banners;
      case 'tools':
        return HomeItem.tools;
      case 'features':
        return HomeItem.features;
      case 'galleries':
        return HomeItem.galleries;
      default:
        return HomeItem.UNDEFINED;
    }
  }
}

extension HomeItemEx on HomeItem {
  value() {
    switch (this) {
      case HomeItem.banners:
        return 'banners';
      case HomeItem.tools:
        return 'tools';
      case HomeItem.features:
        return 'features';
      case HomeItem.galleries:
        return 'galleries';
      case HomeItem.UNDEFINED:
        return null;
    }
  }
}

