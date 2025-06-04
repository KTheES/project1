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
          content: SingleChildScrollView(
            child: Column(
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
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();

                        final overlayContext = Navigator.of(context).overlay!.context;

                        showDialog(
                          context: overlayContext,
                          barrierDismissible: false,
                          builder: (_) {
                            return AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              content: const SizedBox(
                                height: 100,
                                child: Center(
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
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
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
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/store_background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 홈 버튼
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.home);
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
              ),

              const SizedBox(height: 40),

              // 아이템 목록 (Wrap으로 래핑)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 120, 20, 0),
                child: Wrap(
                  spacing: 30,
                  runSpacing: 70, // 줄 간 간격 넓게
                  alignment: WrapAlignment.center,
                  children: List.generate(itemImages.length, (index) {
                    return Column(
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
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
