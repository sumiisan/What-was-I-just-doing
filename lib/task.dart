
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class Task {
  late final String id;
  String description = "";
  String mediaPath = "";
  bool isFinished = false;
  DateTime created = DateTime.now();
  Duration timeSpent = Duration.zero;

  Task({this.id = ""}) {
    if (id.isEmpty) {
      var formatter = DateFormat('yyyyMMdd-HHmmss');
      var dateString = formatter.format(DateTime.now());
      id = "Task-$dateString";
    }
  }
}

class TaskData {
  final List<Task> tasks = [];

  storeTask(Task task) {
    var taskWithSameId = tasks.where((element) => element.id == task.id);
    if (taskWithSameId.isNotEmpty) {
      tasks.remove(taskWithSameId.first);
    }

    tasks.add(task);
  }
}

class SharedPreferencesAccessor {
  
  Future<void> _save<T>(String key, T data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  Future<T?> _loadMap<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      final data = jsonDecode(jsonString);
      return data;
    }
    return null;
  }

  Future<void> saveTasks(List<Task> tasks) async {
    await _save("tasks", tasks);
  }

  Future<List<Task>?> loadTasks() {
    return _loadMap("tasks");
  }
}