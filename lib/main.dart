import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'config/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List With Your Pet',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.splash, // 앱 시작화면
      routes: AppRoutes.routes,        // 화면 라우팅 설정
    );
  }
}