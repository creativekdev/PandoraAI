enum AppTabId {
  HOME,
  DISCOVERY,
  MINE,
  ACTIVITY,
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
      case AppTabId.ACTIVITY:
        return 4;
      default:
        return 0;
    }
  }
}
