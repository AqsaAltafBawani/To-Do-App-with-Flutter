import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TaskProvider(),
      child: MaterialApp(
        home: ToDoApp(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal, // Use teal as the primary color
          colorScheme: ColorScheme.light(
            secondary: Colors.teal, // Sea Blue Accent Color
          ),
        ),
      ),
    );
  }
}

class ToDoApp extends StatelessWidget {
  final TextEditingController taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("To-Do App"),
        centerTitle: true,
        backgroundColor: Colors.teal, // Sea Blue color for AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: taskController,
                    decoration: InputDecoration(
                      labelText: "Add a task",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    if (taskController.text.isNotEmpty) {
                      taskProvider.addTask(taskController.text);
                      taskController.clear();
                      _showSnackbar(context, "Task Added!");
                    } else {
                      _showSnackbar(context, "Task cannot be empty");
                    }
                  },
                  child: Text("Add"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Sea Blue button color
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: taskProvider.tasks.length,
                itemBuilder: (context, index) {
                  final task = taskProvider.tasks[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 10),
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      title: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                      leading: Checkbox(
                        value: task.isCompleted,
                        onChanged: (_) => taskProvider.toggleTask(index),
                        activeColor:
                            Colors.teal, // Sea Blue for active checkbox
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => taskProvider.deleteTask(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to show a Snackbar with a message
  void _showSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class Task {
  String title;
  bool isCompleted;

  Task(this.title, this.isCompleted);

  // Convert Task to Map for JSON encoding
  Map<String, dynamic> toJson() => {'title': title, 'isCompleted': isCompleted};

  // Convert Map back to Task from JSON
  static Task fromJson(Map<String, dynamic> json) =>
      Task(json['title'], json['isCompleted']);
}

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  TaskProvider() {
    loadTasks();
  }

  void addTask(String title) {
    _tasks.add(Task(title, false));
    _saveTasks();
    notifyListeners();
  }

  void deleteTask(int index) {
    _tasks.removeAt(index);
    _saveTasks();
    notifyListeners();
  }

  void toggleTask(int index) {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    _saveTasks();
    notifyListeners();
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        'tasks', jsonEncode(_tasks.map((task) => task.toJson()).toList()));
  }

  // Load tasks from SharedPreferences
  Future<void> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksString = prefs.getString('tasks');
    if (tasksString != null) {
      _tasks = (jsonDecode(tasksString) as List)
          .map((task) => Task.fromJson(task))
          .toList();
      notifyListeners();
    }
  }
}
