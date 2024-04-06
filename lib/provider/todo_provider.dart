import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kishore_todo/model/todo_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
