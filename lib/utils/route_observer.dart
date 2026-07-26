import 'package:flutter/material.dart';
import 'package:tiny_finder/app.dart' show TinyFinderApp;
import 'package:tiny_finder/screens/home_screen.dart' show HomeScreen;

/// App-wide [RouteObserver] shared by [TinyFinderApp] (navigator observer)
/// and any screen that needs [RouteAware] callbacks (e.g. [HomeScreen]).
///
/// Declared here (not in home_screen.dart) so that app.dart and screens
/// can both import it without creating a circular dependency.
final RouteObserver<PageRoute> appRouteObserver = RouteObserver<PageRoute>();
