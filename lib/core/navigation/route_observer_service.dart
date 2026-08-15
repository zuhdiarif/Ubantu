import 'package:flutter/material.dart';

class AppRouteObserver extends NavigatorObserver {
  String? _currentRoute;

  String? get currentRoute => _currentRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _currentRoute = route.settings.name;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _currentRoute = previousRoute?.settings.name;
  }
}
