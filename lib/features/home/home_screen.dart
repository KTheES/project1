import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
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

  // 위젯이 처음 생성될 때 Hive로부터 저장된 데이터를 불러옴
  @override
  void initState() {
    super.initState();
    loadTodosFromHive();
  }

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

  // Hive에 투두 데이터를 저장
  void saveTodosToHive() {
    final box = Hive.box('todoBox'); // 'todoBox'라는 이름의 저장소 사용
    box.put('todos', todoByDate); // 'todos'라는 키에 전체 맵 저장
  }

  // Hive에서 저장된 데이터를 불러오기
  void loadTodosFromHive() {
    final box = Hive.box('todoBox'); // 같은 저장소 사용
    final stored = box.get('todos'); // 'todos' 키로부터 값 가져오기
    if (stored != null && stored is Map) {
      // Hive는 Map<dynamic, dynamic> 형태로 가져오기 때문에 타입 안전하게 변환됨.
      todoByDate = Map<String, List<Map<String, dynamic>>>.from(
        stored.map((key, value) => MapEntry(
          key,
          List<Map<String, dynamic>>.from(
              (value as List).map((e) => Map<String, dynamic>.from(e))),
        )),
      );
      setState(() {}); // UI 갱신합니다.
    }
  }

  void addTodo(String task) {
    final key = getDateKey(selectedDate);
    todoByDate[key] ??= [];
    todoByDate[key]!.add({'task': task, 'done': false});
    _controller.clear();
    setState(() {});
  }

  void toggleTodo(Map<String, dynamic> todo) {
    final key = getDateKey(selectedDate);
    final todos = todoByDate[key];
    if (todos != null) {
      final index = todos.indexOf(todo);
      if (index != -1) {
        todos[index]['done'] = !todos[index]['done'];
        setState(() {});
      }
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

    final List<Map<String, dynamic>> filteredTodos = () {
      if (filter == 'done') {
        // 오늘 날짜 기준 완료된 투두
        return todos.where((t) => t['done'] == true).toList();
      } else if (filter == 'undone') {
        return todos.where((t) => t['done'] == false).toList();
      } else if (filter == 'all') {
        // 전체 날짜 기준 완료된 투두
        return todoByDate.values
            .expand((list) => list)
            .where((t) => t['done'] == true)
            .toList();
      } else {
        return todos;
      }
    }();

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
                    'assets/images/baby_lwf.gif',
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
                  onChanged: (_) => toggleTodo(todo),
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
