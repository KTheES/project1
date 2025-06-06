import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController _controller = TextEditingController();
  String filter = 'all';

  /// 날짜별 투두리스트 맵
  Map<String, List<Map<String, dynamic>>> todoByDate = {};

  // 위젯이 처음 생성될 때 Hive로부터 저장된 데이터를 불러옴
  @override
  void initState() {
    super.initState();
    loadTodosFromHive();
  }

  String getDateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

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
                    'assets/images/baby_lwf.gif', // gif로 교체됨
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
