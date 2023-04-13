import 'package:cartoonizer/Common/importFile.dart';

class AppRouteObserver extends NavigatorObserver {
  Route<dynamic>? _currentRoute;

  Route<dynamic>? get currentRoute => _currentRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _currentRoute = route;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _currentRoute = previousRoute;
  }
}
