import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:kishore_todo/provider/todo_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(TodoApp());
}

class TodoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoProvider(),
      child: const MaterialApp(
        title: 'Todo App',
        home: TodoScreen(),
      ),
    );
  }
}

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final todos = todoProvider.todos;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.blue),
                borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: todo.isCompleted,
                        onChanged: (value) {
                          todoProvider.updateTodoStatus(todo.id, value!);
                        },
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Text(
                        todo.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: todo.isCompleted
                              ? FontWeight.normal
                              : FontWeight.bold,
                          decoration: todo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                      onTap: () {
                        todoProvider.deleteTodo(todo.id);
                      },
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      )),
                ],
              ),
            ),
          );
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

  // void _showEditTodoDialog(
  //     BuildContext context, Todo todo, TodoProvider provider) {
  //   TextEditingController textController =
  //       TextEditingController(text: todo.title);

  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Edit Todo"),
  //         content: TextField(
  //           controller: textController,
  //           decoration: InputDecoration(hintText: "Enter new todo"),
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text("Cancel"),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //           TextButton(
  //             child: Text("Update"),
  //             onPressed: () {
  //               String newTitle = textController.text.trim();
  //               if (newTitle.isNotEmpty) {
  //                 // provider.updateTodoTitle(todo.id, newTitle);
  //               }
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
}
