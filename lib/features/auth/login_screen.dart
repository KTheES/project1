import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:light_western_food/features/home/home_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  // 로그인 function
  Future<void> signInWithGoogle(BuildContext context) async {
    try{
      // 사용자에게 계정 선택 UI
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if(googleUser == null) return;  // 로그인 취소함

      //인증 정보 획득함
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // firebase에 credential 생성 후 넘김
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      // firebase 로그인
      await FirebaseAuth.instance.signInWithCredential(credential);

      if(!context.mounted) return;
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
      );

    } catch (e) {
      if(!context.mounted) return;    // 예외시 context 확인

      if(kDebugMode) {                // 디버깅용 출력문입니다.
        print('로그인 오류 발생 $e');
      }

      ScaffoldMessenger.of(context).showSnackBar(   // 실패 알림
          SnackBar(
              content: Text(
                "로그인에 실패했습니다. 다시 시도해주세요.",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.grey,
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

          // 구글 로그인 버튼 (아이콘 제거)
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 80),
              child: GestureDetector(                     // image 버튼 처리용으로 썼습니다.
                onTap: () => signInWithGoogle(context),
                  // TODO: 구글 로그인 기능 구현
                child: Image.asset(
                  'assets/images/google_login_button.png',
                    width: 240,
                    height: 60,
                )

                  // 일단 GestureDetector로 Button 처리 해놓았으나, 혹시 몰라 남겨둡니다.
                // style: ElevatedButton.styleFrom(
                //   backgroundColor: Colors.transparent, // 배경 이미지와 어울리게
                //   shadowColor: Colors.transparent,
                //   foregroundColor: Colors.transparent, // 텍스트 보이지 않도록
                //   padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 40), // 클릭 범위 확보
                // ),
                // child: const Text(''), // 텍스트 없음

              ),
            ),
          ),
        ],
      ),
    );
  }
}
