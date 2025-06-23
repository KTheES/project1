import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:light_western_food/config/app_routes.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateBasedOnLogin();
    });
  }

  Future<void> _navigateBasedOnLogin() async {
    await Future.delayed(const Duration(seconds: 2)); // splash 대기 효과

    final user = FirebaseAuth.instance.currentUser;

    if (!mounted) return;

    if (user != null) {
      // 이미 로그인한 경우
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    } else {
      // 로그인하지 않은 경우
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(
          image: AssetImage('assets/images/splash_screen.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
