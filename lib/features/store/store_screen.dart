import 'package:flutter/material.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Stack은 여러 위젯을 겹쳐서 배치할 수 있도록 해주는 위젯
      // 예: 배경 위에 아이템 목록을 겹쳐서 보여줄 때 사용
      body: Stack(
        children: [
          // Positioned.fill은 Stack의 전체 영역을 채우도록 함
          // 여기서는 배경 이미지를 화면 전체에 채워서 보여줌
          Positioned.fill(
            child: Image.asset(
              'assets/images/store_background.png', // 배경 이미지 경로 (밤 배경, 건물, 캐릭터 포함된 통합 이미지)
              fit: BoxFit.cover, // 이미지가 화면 크기에 맞게 비율을 유지하며 꽉 차도록 설정
            ),
          ),

          // 가운데에 강아지집 모양 아이템들을 격자(Grid) 형태로 보여줌
          Center(
            child: GridView.count(
              crossAxisCount: 3, // 한 줄에 아이템을 3개씩 배치 (총 9개라면 3x3 형태)
              padding: const EdgeInsets.symmetric(
                horizontal: 30, // 좌우 여백
                vertical: 80,   // 상하 여백
              ),
              children: List.generate(9, (index) {
                // GestureDetector를 사용해 아이템을 터치할 수 있게 만듦
                return GestureDetector(
                  onTap: () {
                    // 아이템을 눌렀을 때 실행할 동작
                    // 예: 구매 확인 창 띄우기, 포인트 차감 등
                    debugPrint('아이템 $index 클릭됨');
                  },
                  // 실제로 화면에 표시될 아이템 이미지 (강아지집 형태)
                  child: Image.asset(
                    'assets/images/item_house.png', // 아이템 이미지 경로
                    fit: BoxFit.contain, // 아이템 크기에 맞게 비율 유지하며 표시
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}