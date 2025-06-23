import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:light_western_food/config/app_routes.dart';

import '../home/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> signInWithGoogle(BuildContext context) async {
    print('⏳ Google Sign-In 시작됨');

    try {
      final GoogleSignIn googleSignIn;

      if (kIsWeb) {
        final provider = GoogleAuthProvider();
        await FirebaseAuth.instance.signInWithPopup(provider);

        return;
      } else if (Platform.isAndroid || Platform.isIOS) {
        googleSignIn = GoogleSignIn(scopes: ['email']);
      } else {
        throw UnsupportedError("⚠ 이 플랫폼은 지원되지 않습니다.");
      }

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        print('❌ 로그인 취소됨');
        return;
      }

      final googleAuth = await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      print('🎉 Firebase 로그인 성공');

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

      // authStateChanges가 자동으로 홈으로 전환해줌!
    } catch (e) {
      print('❌ 로그인 중 오류 발생: $e');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('로그인에 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_screen_ver2.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: GestureDetector(
                onTap: () => signInWithGoogle(context),
                child: Image.asset(
                  'assets/images/google_login_button.png',
                  width: 240,
                  height: 40,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
