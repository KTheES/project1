import 'package:flutter/material.dart';
import 'package:light_western_food/config/app_routes.dart';

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  final List<String> itemImages = const [
    'assets/images/items/item_house.png',
    'assets/images/items/item_bell.png',
    'assets/images/items/item_bowl.png',
    'assets/images/items/item_mouse.png',
    'assets/images/items/item_tie.png',
    'assets/images/items/item_wool.png',
  ];

  final List<String> itemPrices = const [
    '50P',
    '30P',
    '10P',
    '20P',
    '30P',
    '20P',
  ];

  void _showPurchaseDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 40),
              const Text(
                '해당 아이템을 구매하시겠습니까?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ✅ Yes 버튼
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 첫 팝업 닫기

                      final overlayContext = Navigator.of(context).overlay!.context;

                      showDialog(
                        context: overlayContext,
                        barrierDismissible: false,
                        builder: (_) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            content: SizedBox(
                              height: 100,
                              child: const Center(
                                child: Text(
                                  '성공적으로 구매되셨습니다',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          );
                        },
                      );

                      Future.delayed(const Duration(milliseconds: 1500), () {
                        Navigator.of(overlayContext).pop();
                      });

                      debugPrint('아이템 $index 구매함');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('Yes'),
                  ),
                  const SizedBox(width: 16),
                  // ❌ No 버튼
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 첫 팝업만 닫기
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Text('No'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/store_background.png',
              fit: BoxFit.cover,
            ),
          ),

          // 홈 버튼 (왼쪽 최상단)
          Positioned(
            top: 30,
            left: 30,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(AppRoutes.home); // 홈 화면으로 이동
              },
              child: ClipOval(
                child: Container(
                  width: 40,
                  height: 40,
                  color: Colors.white.withOpacity(0.7),
                  child: Image.asset(
                    'assets/images/home_icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 200),
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 30,
              padding: const EdgeInsets.symmetric(horizontal: 30),
              children: List.generate(itemImages.length, (index) {
                return GestureDetector(
                  onTap: () {
                    debugPrint('아이템 $index 클릭됨');
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 90,
                        height: 90,
                        child: Image.asset(
                          itemImages[index],
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          _showPurchaseDialog(context, index);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          backgroundColor: Colors.white.withOpacity(0.9),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          itemPrices[index],
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
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
