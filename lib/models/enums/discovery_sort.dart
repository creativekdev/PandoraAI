///auto generate code, please do not modify;
enum DiscoverySort {
  likes,
  newest,
  UNDEFINED,
}

class DiscoverySortUtils {
  static DiscoverySort build(String? value) {
    switch (value) {
      case 'likes':
        return DiscoverySort.likes;
      case 'newest':
        return DiscoverySort.newest;
      default:
        return DiscoverySort.UNDEFINED;
    }
  }
}

extension DiscoverySortEx on DiscoverySort {
  apiValue() {
    switch (this) {
      case DiscoverySort.likes:
        return 't.likes';
      case DiscoverySort.newest:
        return 't.id';
      case DiscoverySort.UNDEFINED:
        return null;
    }
  }

  value() {
    switch (this) {
      case DiscoverySort.likes:
        return 'likes';
      case DiscoverySort.newest:
        return 'newest';
      case DiscoverySort.UNDEFINED:
        return null;
    }
  }
}
