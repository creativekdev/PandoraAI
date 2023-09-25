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
  banner,
  tool,
  feature,
  list,
  ad,
  gallery,
  UNDEFINED,
}

class HomeItemUtils {
  static HomeItem build(String? value) {
    switch (value) {
      case 'banner':
        return HomeItem.banner;
      case 'tool':
        return HomeItem.tool;
      case 'feature':
        return HomeItem.feature;
      case 'list':
        return HomeItem.list;
      case 'ad':
        return HomeItem.ad;
      case 'gallery':
        return HomeItem.gallery;
      default:
        return HomeItem.UNDEFINED;
    }
  }
}

extension HomeItemEx on HomeItem {
  value() {
    switch (this) {
      case HomeItem.banner:
        return 'banner';
      case HomeItem.tool:
        return 'tool';
      case HomeItem.feature:
        return 'feature';
      case HomeItem.list:
        return 'list';
      case HomeItem.ad:
        return 'ad';
      case HomeItem.gallery:
        return 'gallery';
      case HomeItem.UNDEFINED:
        return null;
    }
  }
}
