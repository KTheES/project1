import 'package:flutter/material.dart';
import '../features/auth/login_screen.dart';
import '../features/home/home_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/store/store_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String home = '/home';
  static const String store = '/store';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    login: (context) => const LoginScreen(),
    home: (context) => const HomeScreen(),
    store: (context) => const StoreScreen(),
  };
}