import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:light_western_food/features/home/home_screen.dart';
import 'dart:io';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  Future<void> signInWithGoogle(BuildContext context) async {
    print('⏳ Google Sign-In 시작됨');

    try {
      final GoogleSignIn googleSignIn; // 로그인 분기 처리
      if (Platform.isAndroid) {
        googleSignIn = GoogleSignIn();
        print('📱 Android 환경에서 Google 로그인 시작');
      } else if (Platform.isIOS) {
        googleSignIn = GoogleSignIn(
          scopes: ['email'],
          hostedDomain: "", // 필요 시 설정
        );
        print('iOS 환경에서 Google 로그인 시작');
      } else {
        throw UnsupportedError("⚠이 플랫폼은 지원되지 않습니다"); // chrome으로 들어갔을 시 예외처리
      }

      // 사용자 계정 선택 UI
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        print('❌ 로그인 취소됨');
        return;
      }
      print('✅ 사용자 선택됨: ${googleUser.email}');

      // 인증 토큰 획득
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      print('✅ 인증 토큰 획득 완료');

      // Firebase 인증용 Credential 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('🔐 Credential 생성 완료');

      // Firebase에 로그인
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      print('🎉 Firebase 로그인 성공: ${userCredential.user?.email}');

      // 다음 화면으로 이동
      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      print('❌ 로그인 중 오류 발생: $e');

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "로그인에 실패했습니다. 다시 시도해주세요.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_screen_ver2.png',
              fit: BoxFit.cover,
            ),
          ),

          // 구글 로그인 버튼
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: GestureDetector(
                onTap: () => signInWithGoogle(context),
                child: Image.asset(
                  'assets/images/google_login_button.png',
                  width: 240,
                  height: 60,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
