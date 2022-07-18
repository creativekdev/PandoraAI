enum AppTabId {
  HOME,
  DISCOVERY,
  MINE,
}

extension AppTabIdEx on AppTabId {
  int id() {
    switch (this) {
      case AppTabId.HOME:
        return 1;
      case AppTabId.DISCOVERY:
        return 2;
      case AppTabId.MINE:
        return 3;
      default:
        return 0;
    }
  }
}
