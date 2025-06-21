import 'package:flutter/material.dart';
import 'package:light_western_food/config/app_routes.dart';
import 'package:shared_preferences/shared_preferences.dart'; // ✅ 추가

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final List<String> itemImages = const [
    'assets/images/items_store/bell.png',
    'assets/images/items_store/bowl.png',
    'assets/images/items_store/mouse.png',
    'assets/images/items_store/ribbon.png',
    'assets/images/items_store/wool.png',
  ];

  final List<int> itemPrices = const [30, 10, 20, 30, 20]; // ✅ 숫자형 가격

  final String _purchaseButtonImage = 'assets/images/purchase_button.png';
  final String _purchasedButtonImage = 'assets/images/purchased_button.png';

  late List<bool> _isItemPurchased;
  int userPoints = 100;

  @override
  void initState() {
    super.initState();
    _isItemPurchased = List.generate(itemImages.length, (index) => false);
    _loadData(); // ✅ 포인트 & 구매 상태 불러오기
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userPoints = prefs.getInt('user_points') ?? 100;
      final purchasedList = prefs.getStringList('purchased_items');
      if (purchasedList != null && purchasedList.length == itemImages.length) {
        _isItemPurchased = purchasedList.map((e) => e == 'true').toList();
      }
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_points', userPoints);
    await prefs.setStringList(
      'purchased_items',
      _isItemPurchased.map((e) => e.toString()).toList(),
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
              Text(
                '보유 포인트: $userPoints P',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
              const SizedBox(height: 165),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildItem(0),
                        const SizedBox(width: 25),
                        _buildItem(1),
                        const SizedBox(width: 25),
                        _buildItem(2),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildItem(3),
                        const SizedBox(width: 25),
                        _buildItem(4),
                      ],
                    ),
                  ],
                ),
              ),
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
          width: 100,
          height: 100,
          child: Image.asset(
            itemImages[index],
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: _isItemPurchased[index]
              ? null
              : () async {
                  if (userPoints >= itemPrices[index]) {
                    setState(() {
                      _isItemPurchased[index] = true;
                      userPoints -= itemPrices[index];
                    });
                    await _saveData(); // ✅ 저장

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
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  } else {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        content: const Text(
                          '포인트가 부족합니다!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  }
                },
          child: Image.asset(
            _isItemPurchased[index] ? _purchasedButtonImage : _purchaseButtonImage,
            width: 90,
            height: 45,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
