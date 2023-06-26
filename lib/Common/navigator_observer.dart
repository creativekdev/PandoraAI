import 'package:cartoonizer/Common/importFile.dart';

class AppRouteObserver extends NavigatorObserver {
  List<Route<dynamic>> _routeHistory = [];
  Route<dynamic>? _currentRoute;

  Route<dynamic>? get currentRoute => _currentRoute;

  Route<dynamic>? get lastRoute {
    if (_routeHistory.length >= 2) {
      return _routeHistory[_routeHistory.length - 2];
    }
    return null;
  }

  bool isContainRoute(String route) {
    for (var i = 0; i < _routeHistory.length; i++) {
      if (_routeHistory[i].settings.name == route) {
        return true;
      }
    }
    return false;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _routeHistory.add(route);
    _currentRoute = route;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _routeHistory.remove(route);
    _currentRoute = previousRoute;
  }
}
