import 'package:flutter/material.dart';
import 'package:light_western_food/config/app_routes.dart';
import 'package:light_western_food/models/item.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen> {
  final List<Item> availableItems = [
    Item(
      id: 'bell',
      storeImagePath: 'assets/images/items_store/bell.png',
      homeImagePath: 'assets/images/items_home/bell.png',
      price: 30,
      characterGifPath: 'assets/images/character/baby_lwf_bell.gif',
    ),
    Item(
      id: 'bowl',
      storeImagePath: 'assets/images/items_store/bowl.png',
      homeImagePath: 'assets/images/items_home/bowl.png',
      price: 10,
    ),
    Item(
      id: 'mouse',
      storeImagePath: 'assets/images/items_store/mouse.png',
      homeImagePath: 'assets/images/items_home/mouse.png',
      price: 20,
    ),
    Item(
      id: 'ribbon',
      storeImagePath: 'assets/images/items_store/ribbon.png',
      homeImagePath: 'assets/images/items_home/ribbon.png',
      price: 30,
      characterGifPath: 'assets/images/character/baby_lwf_ribbon.gif',
    ),
    Item(
      id: 'wool',
      storeImagePath: 'assets/images/items_store/wool.png',
      homeImagePath: 'assets/images/items_home/wool.png',
      price: 20,
    ),
    Item(
      id: 'hammy',
      storeImagePath: 'assets/images/items_store/hammy.png',
      homeImagePath: 'assets/images/character/hammy.png',
      price: 50,
    ),
  ];

  final String _purchaseButtonImage = 'assets/images/purchase_button.png';
  final String _purchasedButtonImage = 'assets/images/purchased_button.png';

  Set<String> _purchasedItemIds = {};
  int userPoints = 100;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // StoreScreen 클래스 내부----개발용(초기화)
  Future<void> _clearAllSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 모든 SharedPreferences 데이터 삭제
    debugPrint('DEBUG: SharedPreferences 데이터가 모두 초기화되었습니다.');
    // ✨ 수정: 데이터 초기화 후, _loadData() 호출로 모든 변수 상태를 갱신
    await _loadData(); // _purchasedItemIds와 userPoints를 SharedPreferences에서 다시 로드
    // _loadData() 내부에 setState가 있으므로 별도 호출은 필요 없을 수 있으나,
    // 확실하게 UI를 갱신하려면 여기에 setState()를 한 번 더 추가해주는 것이 좋습니다.
    setState(() {
      // 명시적으로 setState를 호출하여 _purchasedItemIds와 userPoints의 변경사항이 UI에 반영되도록 함
      // _purchasedItemIds = {}; // 이 값은 _loadData()에서 이미 업데이트됩니다.
      // userPoints = 100;       // 이 값도 _loadData()에서 업데이트됩니다.
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final String? purchasedItemsJson = prefs.getString('purchasedItems');
    if (purchasedItemsJson != null) {
      final List<dynamic> jsonList = jsonDecode(purchasedItemsJson);
      _purchasedItemIds = jsonList.map((e) => e['id'] as String).toSet();
    }
    userPoints = prefs.getInt('user_points') ?? 100;
    setState(() {});
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('user_points', userPoints);

    final List<Item> purchasedItems = availableItems
        .where((item) => _purchasedItemIds.contains(item.id))
        .toList();
    final List<Map<String, dynamic>> jsonList =
    purchasedItems.map((item) => item.toJson()).toList();
    await prefs.setString('purchasedItems', jsonEncode(jsonList));
  }

  void _handlePurchase(Item item) async {
    if (_purchasedItemIds.contains(item.id)) return;

    if (userPoints >= item.price) {
      setState(() {
        _purchasedItemIds.add(item.id);
        userPoints -= item.price;
      });
      await _saveData();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: const SizedBox(
            height: 100,
            child: Center(
              child: Text(
                '아이템 구매 완료!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      );
      await Future.delayed(const Duration(milliseconds: 1500));
      Navigator.of(context).pop();
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: const Text(
            '포인트가 부족합니다!',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
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
                        width: 45,
                        height: 45,
                        color: Colors.white,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/images/home_icon.png'),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                '보유 포인트: $userPoints P',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 130),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildItem(availableItems[0]),
                        const SizedBox(width: 25),
                        _buildItem(availableItems[1]),
                        const SizedBox(width: 25),
                        _buildItem(availableItems[2]),
                      ],
                    ),
                    const SizedBox(height: 50),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildItem(availableItems[3]),
                        const SizedBox(width: 25),
                        _buildItem(availableItems[4]),
                        const SizedBox(width: 25),
                        _buildItem(availableItems[5]),
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

  Widget _buildItem(Item item) {
    final bool isPurchased = _purchasedItemIds.contains(item.id);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 100,
          height: 100,
          child: Image.asset(item.storeImagePath, fit: BoxFit.contain),
        ),
        const SizedBox(height: 2),
        GestureDetector(
          onTap: isPurchased ? null : () => _handlePurchase(item),
          child: Image.asset(
            isPurchased ? _purchasedButtonImage : _purchaseButtonImage,
            width: 90,
            height: 45,
          ),
        ),
      ],
    );
  }
}