import 'package:flutter/material.dart';
import 'package:light_western_food/config/app_routes.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {

  final List<String> itemImages = const [
    'assets/images/items/item_bell.png',
    'assets/images/items/item_bowl.png',
    'assets/images/items/item_mouse.png',
    'assets/images/items/item_tie.png',
    'assets/images/items/item_wool.png',
  ];

  final List<String> itemPrices = const [
    '30P',
    '10P',
    '20P',
    '30P',
    '20P',
  ];

  final String _purchaseButtonImage = 'assets/images/purchase_button.png';
  final String _purchasedButtonImage = 'assets/images/purchased_button.png';

  late List<bool> _isItemPurchased;

  @override
  void initState() {
    super.initState();
    _isItemPurchased = List.generate(itemImages.length, (index) => false);
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
            // mainAxisAlignment: MainAxisAlignment.center, // <-- 이 부분을 제거합니다.
            children: [
              // 홈 버튼 (좌측 상단에 고정)
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
                        width: 45,
                        height: 45,
                        color: Colors.white.withOpacity(1.0),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset(
                            'assets/images/home_icon.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(flex: 1),

              // 아이템 목록
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // 아이템 목록 Column은 최소 공간만 차지
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildItem(0),
                        const SizedBox(width: 40),
                        _buildItem(1),
                        const SizedBox(width: 40),
                        _buildItem(2),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildItem(3),
                        const SizedBox(width: 40),
                        _buildItem(4),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(int index) {
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
        const SizedBox(height: 2),
        GestureDetector(
          onTap: _isItemPurchased[index]
              ? null
              : () {
            setState(() {
              _isItemPurchased[index] = true;
            });

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) {
                return AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  content: const SizedBox(
                    height: 100,
                    child: Center(
                      child: Text(
                        '아이템 구매 완료!',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            );

            Future.delayed(const Duration(milliseconds: 1500), () {
              Navigator.of(context).pop();
            });

            debugPrint('아이템 $index 구매 완료');
          },
          child: Image.asset(
            _isItemPurchased[index] ? _purchaseButtonImage : _purchaseButtonImage,
            width: 90,
            height: 45,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}