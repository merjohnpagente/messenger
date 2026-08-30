import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:messenger/main.dart';
import 'package:messenger/screens/login_screen.dart';
import 'package:messenger/screens/register_screen.dart';
import 'package:messenger/screens/splash_screen.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/splash',
    routes: [
      GoRoute(path: '/splash', builder: (c, s) => const SplashScreen()),
      GoRoute(path: '/login', builder: (c, s) => const LoginScreen()),
      GoRoute(path: '/register', builder: (c, s) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (c, s) => const MessengerHome()),
    ],
    errorBuilder: (c, s) => Scaffold(body: Center(child: Text(s.error.toString()))),
  );
}
