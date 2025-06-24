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

  Map<String, List<Map<String, dynamic>>> todoByDate = {};

  List<Item> _purchasedItems = [];
  String _currentCatImagePath = 'assets/images/baby_lwf.gif';

  bool _isLwfGrown = false;
  bool _isHammyGrown = false;
  int _totalCompletedTodos = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    loadTodosFromHive();
    _loadPurchasedItems();
    _loadGrowthState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _loadPurchasedItems();
    }
  }

  String getDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  Future<void> _loadGrowthState() async {
    final prefs = await SharedPreferences.getInstance();
    _isLwfGrown = prefs.getBool('isLwfGrown') ?? false;
    _isHammyGrown = prefs.getBool('isHammyGrown') ?? false;
    _totalCompletedTodos = prefs.getInt('totalCompletedTodos') ?? 0;
    _updateCatImagePathBasedOnState();
    setState(() {});
  }

  Future<void> _saveGrowthState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLwfGrown', _isLwfGrown);
    await prefs.setBool('isHammyGrown', _isHammyGrown);
    await prefs.setInt('totalCompletedTodos', _totalCompletedTodos);
  }

  Future<void> _loadPurchasedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final String? purchasedItemsJson = prefs.getString('purchasedItems');
    if (purchasedItemsJson != null) {
      final List<dynamic> jsonList = jsonDecode(purchasedItemsJson);
      setState(() {
        _purchasedItems = jsonList.map((json) => Item.fromJson(json)).toList();
      });
    } else {
      setState(() {
        _purchasedItems = [];
      });
    }
    _updateCatImagePathBasedOnState();
  }

  void _updateCatImagePathBasedOnState() {
    bool hasHammy = _purchasedItems.any((item) => item.id == 'hammy');
    bool hasBell = _purchasedItems.any((item) => item.id == 'bell');
    bool hasRibbon = _purchasedItems.any((item) => item.id == 'ribbon');

    String newImagePath;

    if (hasHammy) {
      newImagePath = _isHammyGrown
          ? 'assets/images/character/hammy_growth.png'
          : 'assets/images/character/hammy_little.png';
    } else {
      if (_isLwfGrown) {
        newImagePath = hasBell && hasRibbon
            ? 'assets/images/character/adult_lwf_both.gif'
            : hasBell
            ? 'assets/images/character/adult_lwf_bell.gif'
            : hasRibbon
            ? 'assets/images/character/adult_lwf_ribbon.gif'
            : 'assets/images/character/adult_lwf.gif';
      } else {
        newImagePath = hasBell && hasRibbon
            ? 'assets/images/character/baby_lwf_both.gif'
            : hasBell
            ? 'assets/images/character/baby_lwf_bell.gif'
            : hasRibbon
            ? 'assets/images/character/baby_lwf_ribbon.gif'
            : 'assets/images/baby_lwf.gif';
      }
    }

    if (_currentCatImagePath != newImagePath) {
      setState(() {
        _currentCatImagePath = newImagePath;
      });
    }
  }

  void loadTodosFromHive() {
    final box = Hive.box('todoBox');
    final stored = box.get('todos');
    if (stored != null && stored is Map) {
      todoByDate = Map<String, List<Map<String, dynamic>>>.from(
        stored.map((key, value) => MapEntry(
          key,
          List<Map<String, dynamic>>.from(
              (value as List).map((e) => Map<String, dynamic>.from(e))),
        )),
      );
      setState(() {});
    }
  }

  void addTodo(String task) {
    final key = getDateKey(selectedDate);
    todoByDate[key] ??= [];
    todoByDate[key]!.add({'task': task, 'done': false});
    _controller.clear();
    setState(() {});
  }

  void toggleTodo(Map<String, dynamic> todo) async {
    final key = getDateKey(selectedDate);
    final todos = todoByDate[key];
    if (todos != null) {
      final index = todos.indexOf(todo);
      if (index != -1) {
        bool previousDoneState = todos[index]['done'];
        todos[index]['done'] = !todos[index]['done'];

        if (!previousDoneState && todos[index]['done']) {
          _totalCompletedTodos++;
          await _saveGrowthState();

          if (_totalCompletedTodos >= 5 && !_isLwfGrown) {
            _isLwfGrown = true;
            await _saveGrowthState();
            _showGrowthDialog('lwf');
          }

          if (_purchasedItems.any((item) => item.id == 'hammy') &&
              _totalCompletedTodos >= 5 &&
              !_isHammyGrown) {
            _isHammyGrown = true;
            await _saveGrowthState();
            _showGrowthDialog('hammy');
          }
        } else if (previousDoneState && !todos[index]['done']) {
          if (_totalCompletedTodos > 0) {
            _totalCompletedTodos--;
            await _saveGrowthState();
          }
        }
        setState(() {});
        _updateCatImagePathBasedOnState();
      }
    }
  }

  void _showGrowthDialog(String characterId) {
    String message = characterId == 'lwf' ? '양식이가 성장했어요!' : '햄이가 성장했어요!';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: SizedBox(
          height: 100,
          child: Center(
            child: Text(
              message,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
    Future.delayed(const Duration(milliseconds: 1500)).then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void changeFilter(String newFilter) {
    setState(() {
      filter = newFilter;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final key = getDateKey(selectedDate);
    final todos = todoByDate[key] ?? [];

    final List<Map<String, dynamic>> filteredTodos = () {
      if (filter == 'done') {
        return todos.where((t) => t['done'] == true).toList();
      } else if (filter == 'undone') {
        return todos.where((t) => t['done'] == false).toList();
      } else {
        return todoByDate.values.expand((list) => list).where((t) => t['done'] == true).toList();
      }
    }();

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset('assets/images/home_room.png', fit: BoxFit.cover),
                ),
                Positioned(
                  left: screenWidth * 0.04,
                  top: screenHeight * 0.03,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, AppRoutes.store);
                    },
                    child: Image.asset(
                      'assets/images/home_to_store_button.png',
                      width: screenWidth * 0.15,
                    ),
                  ),
                ),
                Positioned(
                  left: screenWidth * 0.55,
                  top: screenHeight * 0.27,
                  child: Image.asset(_currentCatImagePath, width: screenWidth * 0.2),
                ),
                ..._purchasedItems
                    .where((item) => ['bowl', 'mouse', 'wool'].contains(item.id))
                    .map((item) {
                  double left, top, width, height;

                  switch (item.id) {
                    case 'bowl':
                      left = screenWidth * 0.1;
                      top = screenHeight * 0.27;
                      width = screenWidth * 0.15;
                      height = screenWidth * 0.15;
                      break;
                    case 'mouse':
                      left = screenWidth * 0.4;
                      top = screenHeight * 0.18;
                      width = screenWidth * 0.08;
                      height = screenWidth * 0.08;
                      break;
                    case 'wool':
                      left = screenWidth * 0.7;
                      top = screenHeight * 0.29;
                      width = screenWidth * 0.08;
                      height = screenWidth * 0.08;
                      break;
                    default:
                      left = screenWidth * 0.1;
                      top = screenHeight * 0.1;
                      width = screenWidth * 0.1;
                      height = screenWidth * 0.1;
                      break;
                  }
                  return Positioned(
                    left: left,
                    top: top,
                    child: Image.asset(item.homeImagePath, width: width, height: height),
                  );
                }).toList(),
              ],
            ),
          ),
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

extension ListExtension<T> on List<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
