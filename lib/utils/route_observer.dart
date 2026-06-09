import 'package:flutter/material.dart';

/// App-wide [RouteObserver] shared by [TinyFinderApp] (navigator observer)
/// and any screen that needs [RouteAware] callbacks (e.g. [HomeScreen]).
///
/// Declared here (not in home_screen.dart) so that app.dart and screens
/// can both import it without creating a circular dependency.
final RouteObserver<PageRoute> appRouteObserver = RouteObserver<PageRoute>();
