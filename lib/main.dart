import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoProvider(),
      child: MaterialApp(
        title: 'Todo App',
        home: TodoScreen(),
      ),
    );
  }
}

class TodoScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final todos = todoProvider.todos;

    return Scaffold(
      appBar: AppBar(
        title: Text('Todo List'),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return Container(margin:const EdgeInsets.all(8),decoration: BoxDecoration(border: Border.all(color: Colors.blue),borderRadius: BorderRadius.circular(20)),child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [Checkbox(
                    value: todo.isCompleted,
                    onChanged: (value) {
                      todoProvider.updateTodoStatus(todo.id, value!);
                    },
                  ),
                  const SizedBox(width: 8,),
                  Text(todo.title,style:  TextStyle(fontSize: 18,fontWeight: todo.isCompleted ? FontWeight.normal : FontWeight.bold,decoration: todo.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,),),
                  
                  ],),
              GestureDetector(
                onTap: (){
                  todoProvider.deleteTodo(todo.id);
                },
                child: const Icon(Icons.delete,color: Colors.red,)),
              ],
            ),
          ),);

        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTodoDialog(context, todoProvider);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddTodoDialog(BuildContext context, TodoProvider provider) {
    TextEditingController textController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Todo"),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: "Enter todo"),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Add"),
              onPressed: () {
                String todoText = textController.text.trim();
                if (todoText.isNotEmpty) {
                  provider.addTodo(todoText);
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEditTodoDialog(BuildContext context, Todo todo, TodoProvider provider) {
  TextEditingController textController = TextEditingController(text: todo.title);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Edit Todo"),
        content: TextField(
          controller: textController,
          decoration: InputDecoration(hintText: "Enter new todo"),
        ),
        actions: <Widget>[
          TextButton(
            child: Text("Cancel"),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text("Update"),
            onPressed: () {
              String newTitle = textController.text.trim();
              if (newTitle.isNotEmpty) {
                // provider.updateTodoTitle(todo.id, newTitle);
              }
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
}

void main() {
  runApp(TodoApp());
}




// import 'package:flutter/material.dart';

class TodoProvider with ChangeNotifier {
  List<Todo> _todos = [];
  SharedPreferences? _prefs;

  TodoProvider() {
    _loadData();
  }

  List<Todo> get todos => _todos;

  List<Map<String, dynamic>> _toJsonList() {
  return _todos.map((todo) => todo.toJson()).toList();
}

void _fromJsonList(List<dynamic> jsonList) {
  _todos = jsonList.map((json) => Todo.fromJson(json)).toList();
}

  Future<void> _loadData() async {
    // _prefs = await SharedPreferences.getInstance();
    // Load todos from SharedPreferences
    _prefs = await SharedPreferences.getInstance();
  final String? jsonString = _prefs?.getString('todos');
  if (jsonString != null) {
    final List<dynamic> jsonList = json.decode(jsonString);
    _fromJsonList(jsonList);
    notifyListeners();
  }
  }

  Future<void> _saveData() async {
    // Save todos to SharedPreferences
   final List<Map<String, dynamic>> jsonList = _toJsonList();
  final String jsonString = json.encode(jsonList);
  await _prefs?.setString('todos', jsonString);
  }

  void addTodo(String title) {
    final newTodo = Todo(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      isCompleted: false,
    );
    _todos.add(newTodo);
    _saveData();
    notifyListeners();
  }

  void updateTodoStatus(int id, bool isCompleted) {
    final index = _todos.indexWhere((todo) => todo.id == id);
    if (index != -1) {
      _todos[index] = Todo(
        id: _todos[index].id,
        title: _todos[index].title,
        isCompleted: isCompleted,
      );
      _saveData();
      notifyListeners();
    }
  }

  void deleteTodo(int id) {
    _todos.removeWhere((todo) => todo.id == id);
    _saveData();
    notifyListeners();
  }
}


class Todo {
  final int id;
  final String title;
  final bool isCompleted;

  Todo({required this.id, required this.title, required this.isCompleted});

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'isCompleted': isCompleted,
    };
  }

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'],
      title: json['title'],
      isCompleted: json['isCompleted'],
    );
  }
}