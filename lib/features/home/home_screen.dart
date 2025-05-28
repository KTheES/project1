import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // 1. 배경 + 캐릭터
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/home_room.png',
                    fit: BoxFit.cover,
                  ),
                ),
                Center(
                  child: Image.asset(
                    'assets/images/baby_lwf.png',
                    width: 120,
                  ),
                ),
              ],
            ),
          ),

          // 2. 날짜 선택 버튼
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(7, (index) {
                  final date = DateTime.now().add(Duration(days: index - 2));
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: Text('${date.month}/${date.day}'),
                    ),
                  );
                }),
              ),
            ),
          ),

          // 3. 투두 리스트
          Expanded(
            flex: 4,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                CheckboxListTile(
                  value: true,
                  onChanged: (val) {},
                  title: Text('고양이 밥 주기'),
                ),
                CheckboxListTile(
                  value: false,
                  onChanged: (val) {},
                  title: Text('스터디 하기'),
                ),
                CheckboxListTile(
                  value: false,
                  onChanged: (val) {},
                  title: Text('산책 다녀오기'),
                ),
              ],
            ),
          ),

          // 4. 할 일 추가 영역
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: '할 일 입력',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('추가'),
                ),
              ],
            ),
          ),

          // 5. 완료/미완료 필터 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(onPressed: () {}, child: Text('완료된 투두')),
              TextButton(onPressed: () {}, child: Text('완료되지 않은 투두')),
            ],
          ),
        ],
      ),
    );
  }
}
