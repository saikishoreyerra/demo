import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:kishore_todo/provider/todo_provider.dart';
import 'package:provider/provider.dart';

import 'model/todo_model.dart';

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



class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  TextEditingController textController = TextEditingController();
    TextEditingController descController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    textController.dispose();
    descController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final todos = todoProvider.todos;

    return Scaffold(
      appBar: AppBar(
        title:  Text(
          'Todo List',
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.purple.shade900),
        ),
      ),
      body: todos.isEmpty ? const Center(child: Padding(
        padding: EdgeInsets.all(45.0),
        child: Text("Come on Increase your productivity, Start creating Todo's",style: TextStyle(fontSize: 20,fontWeight: FontWeight.bold,),textAlign: TextAlign.center,),
      ),) : ListView.builder(
        itemCount: todos.length,
        itemBuilder: (context, index) {
          final todo = todos[index];
          return todoContainer(todoProvider,todo);
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

  Widget todoContainer(TodoProvider todoProvider,Todo todo){
    return Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
                border: Border.all(color: Colors.purple,width: 2),
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
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Text(
                              todo.title,
                              style: TextStyle(
                                color: todo.isCompleted
                                    ? Colors.grey
                                    : Colors.grey.shade700,
                                fontSize: 18,
                                fontWeight: todo.isCompleted
                                    ? FontWeight.normal
                                    : FontWeight.bold,
                                decoration: todo.isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,
                              ),
                            ),
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width * 0.6,
                              child: Text(
                                todo.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: todo.isCompleted
                                      ? Colors.grey
                                      : Colors.grey.shade600,
                                  decoration: todo.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ))
                        ],
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
  }

  void _showAddTodoDialog(BuildContext context, TodoProvider provider) {
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Todo"),
          content: SizedBox(
            height: MediaQuery.of(context).size.height * 0.25,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: textController,
                      decoration: const InputDecoration(
                          hintText: "Enter title", border: InputBorder.none),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: TextField(
                      controller: descController,
                      decoration: const InputDecoration(
                          hintText: "Enter Description",
                          border: InputBorder.none),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            GestureDetector(
              onTap: () {
                String todoText = textController.text.trim();
                if (todoText.isEmpty || descController.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: "Please fill out all fields",
                  );

                  return;
                }

                provider.addTodo(
                    title: todoText, description: descController.text);
                Fluttertoast.showToast(
                  msg: "Added Task",
                );

                Navigator.of(context).pop();
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(20)),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16,vertical: 8),
                  child: Text(
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

//   void _showEditTodoDialog(BuildContext context, Todo todo, TodoProvider provider) {
//   TextEditingController textController = TextEditingController(text: todo.title);

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


