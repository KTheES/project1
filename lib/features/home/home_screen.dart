import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:light_western_food/models/item.dart';
import 'package:light_western_food/config/app_routes.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  DateTime selectedDate = DateTime.now();
  final TextEditingController _controller = TextEditingController();
  String filter = 'all';

  /// 날짜별 투두리스트 맵
  Map<String, List<Map<String, dynamic>>> todoByDate = {};

  List<Item> _purchasedItems = [];

  String _currentCatGifPath = 'assets/images/baby_lwf.gif';

  String getDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadTodoData();
    _loadPurchasedItems();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // 스토어 화면에서 pop되어 돌아올 때는 Navigator.pop의 결과값을 사용하여 로드할 수 있으므로,
      // 이 didChangeAppLifecycleState는 앱이 완전히 백그라운드에서 포그라운드로 돌아올 때 사용됩니다.
      _loadPurchasedItems();
    }
  }

  void _loadTodoData() {
    // 투두 리스트 데이터 로딩 로직 (현재는 앱 재시작 시 초기화)
  }

  Future<void> _loadPurchasedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? purchasedItemsJson = prefs.getString('purchasedItems');
    if (purchasedItemsJson != null) {
      final List<dynamic> jsonList = jsonDecode(purchasedItemsJson);
      setState(() {
        _purchasedItems = jsonList.map((json) => Item.fromJson(json)).toList();
        debugPrint('홈 화면: 구매된 아이템 로드됨: ${_purchasedItems.map((e) => e.id).join(', ')}');
      });
    } else {
      setState(() {
        _purchasedItems = [];
      });
    }
    _updateCatGif();
  }

  void _updateCatGif() {
    bool hasBell = _purchasedItems.any((item) => item.id == 'bell');
    bool hasRibbon = _purchasedItems.any((item) => item.id == 'ribbon');

    String newGifPath;
    if (hasBell && hasRibbon) {
      newGifPath = 'assets/images/items_home/baby_lwf_both.gif';
    } else if (hasBell) {
      newGifPath = 'assets/images/items_home/baby_lwf_bell.gif';
    } else if (hasRibbon) {
      newGifPath = 'assets/images/items_home/baby_lwf_ribbon.gif';
    } else {
      newGifPath = 'assets/images/baby_lwf.gif';
    }

    if (_currentCatGifPath != newGifPath) {
      setState(() {
        _currentCatGifPath = newGifPath;
      });
    }
  }

  void addTodo(String task) {
    final key = getDateKey(selectedDate);
    todoByDate[key] ??= [];
    todoByDate[key]!.add({'task': task, 'done': false});
    _controller.clear();
    setState(() {});
  }

  void toggleTodo(int index) {
    final key = getDateKey(selectedDate);
    if (todoByDate[key] != null) {
      todoByDate[key]![index]['done'] = !todoByDate[key]![index]['done'];
      setState(() {});
    }
  }

  void changeFilter(String newFilter) {
    setState(() {
      filter = newFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final key = getDateKey(selectedDate);
    final todos = todoByDate[key] ?? [];

    final filteredTodos = filter == 'done'
        ? todos.where((t) => t['done'] == true).toList()
        : filter == 'undone'
        ? todos.where((t) => t['done'] == false).toList()
        : todos;

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
                Positioned(
                  left: 220,
                  top: 160,
                  child: Image.asset(
                    _currentCatGifPath,
                    width: 120,
                  ),
                ),

                // 구매된 아이템 배치 로직
                ..._purchasedItems
                    .where((item) => ['bowl', 'mouse', 'wool'].contains(item.id))
                    .map((item) {
                  Offset position = Offset.zero;
                  double itemWidth = 80;
                  double itemHeight = 80;

                  switch (item.id) {
                    case 'bowl':
                      position = const Offset(50, 210);
                      break;
                    case 'mouse':
                      position = const Offset(100, 150);
                      break;
                    case 'wool':
                      position = const Offset(150, 100);
                      break;
                    default:
                      position = const Offset(10, 10);
                      break;
                  }

                  return Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: Image.asset(
                      item.homeImagePath,
                      width: itemWidth,
                      height: itemHeight,
                      fit: BoxFit.contain,
                    ),
                  );
                }).toList(),
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
                  final formatted = DateFormat('MM/dd').format(date);
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedDate = date;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: getDateKey(date) == getDateKey(selectedDate)
                            ? Colors.purple[100]
                            : Colors.white,
                        foregroundColor: Colors.black,
                      ),
                      child: Text(formatted),
                    ),
                  );
                }),
              ),
            ),
          ),

          // 3. 투두 리스트
          Expanded(
            flex: 4,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredTodos.length,
              itemBuilder: (context, index) {
                final todo = filteredTodos[index];
                return CheckboxListTile(
                  value: todo['done'],
                  onChanged: (_) => toggleTodo(todos.indexOf(todo)),
                  title: Text(todo['task']),
                );
              },
            ),
          ),

          // 4. 할 일 추가
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '캔따개의 할 일',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_controller.text.trim().isNotEmpty) {
                      addTodo(_controller.text.trim());
                    }
                  },
                  child: Text('냥'),
                ),
              ],
            ),
          ),

          // 5. 필터 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () => changeFilter('done'),
                child: Text('딴 캔'),
              ),
              TextButton(
                onPressed: () => changeFilter('undone'),
                child: Text('따야하는 캔'),
              ),
              TextButton(
                onPressed: () => changeFilter('all'),
                child: Text('다 먹은 캔'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
