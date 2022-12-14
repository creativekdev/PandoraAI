enum AppTabId {
  HOME,
  DISCOVERY,
  MINE,
  ACTIVITY,
  AI,
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
      case AppTabId.AI:
        return 5;
      default:
        return 0;
    }
  }
}
