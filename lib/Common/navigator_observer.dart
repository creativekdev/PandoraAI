import 'package:cartoonizer/Common/importFile.dart';

class AppRouteObserver extends NavigatorObserver {
  List<Route<dynamic>> routeHistory = [];
  Route<dynamic>? _currentRoute;

  Route<dynamic>? get currentRoute => _currentRoute;

  Route<dynamic>? get lastRoute {
    if (routeHistory.length >= 2) {
      return routeHistory[routeHistory.length - 2];
    }
    return null;
  }

  bool isContainRoute(String route) {
    for (var i = 0; i < routeHistory.length; i++) {
      if (routeHistory[i].settings.name == route) {
        return true;
      }
    }
    return false;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    routeHistory.add(route);
    _currentRoute = route;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    routeHistory.remove(route);
    _currentRoute = previousRoute;
  }
}
