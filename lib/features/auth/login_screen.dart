import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 이미지
          Positioned.fill(
            child: Image.asset(
              'assets/images/login_screen.png',
              fit: BoxFit.cover,
            ),
          ),

          // 구글 로그인 버튼 (아이콘 제거)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: ElevatedButton(
                onPressed: () {
                  // TODO: 구글 로그인 기능 구현
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent, // 배경 이미지와 어울리게
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.transparent, // 텍스트 보이지 않도록
                  padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40), // 클릭 범위 확보
                ),
                child: const Text(''), // 텍스트 없음
              ),
            ),
          ),
        ],
      ),
    );
  }
}
