
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
//import 'package:json_annotation/json_annotation.dart';

//@JsonSerializable()
class Task {
  String id;
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

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'mediaPath': mediaPath,
        'isFinished': isFinished,
        'created': created.toIso8601String(),
        'timeSpent': timeSpent.inSeconds,
      };
    
  Task fromJson(Map<String, dynamic> json) {
    id = json['id'];
    description = json['description'];
    mediaPath = json['mediaPath'];
    isFinished = json['isFinished'];
    created = DateTime.parse(json['created']);
    timeSpent = Duration(seconds: json['timeSpent']);
    return this;
  }

}

class TaskData {
  final List<Task> tasks = [];

  Future<void> loadTasks() async {
    tasks.clear();
    return SharedPreferencesAccessor().loadTasks().then((value) {
      if (value != null) {
        tasks.addAll(value);
      }
    });
  }

  storeTask(Task task) {
    var taskWithSameId = tasks.where((element) => element.id == task.id);
    if (taskWithSameId.isNotEmpty) {
      tasks.remove(taskWithSameId.first);
    }

    tasks.add(task);
    SharedPreferencesAccessor().saveTasks(tasks);
  }
}

class SharedPreferencesAccessor {
  
  Future<void> _save<T>(String key, T data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(data));
  }

  Future<List<dynamic>?> _loadMapList<T>(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString != null) {
      final data = jsonDecode(jsonString);
      return data;
    }
    return null;
  }

  Future<void> saveTasks(List<Task> tasks) async {
    await _save("tasks", tasks.map((Task t) => t.toJson()).toList());
  }

  Future<List<Task>?> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString("tasks");
    if (jsonString != null) {
      final data = jsonDecode(jsonString);

      List<Task> tasks = [];
      for (var taskData in data) {
        var task = Task();
        task.fromJson(taskData);
        tasks.add(task);
      }


//      final List<Task> tasks = data.map((json) => Task().fromJson(json)).toList();
      return tasks;
    }
    return null;
  }
}