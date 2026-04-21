import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import '../services/task_service.dart';
import '../services/notification_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks = _taskService.getTasks();
    // Check for "New Day" (simulated as 1 minute) every time we load
    await checkAndResetDailyTasks();
    _tasks = _taskService.getTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task, BuildContext context) async {
     //await _taskService.addTask(task);
     //await loadTasks();
     //NotificationService().showUrgencyAlert(context, task.title, task.urgencyScore);
    await _taskService.addTask(task);
    await loadTasks();

    if (_tasks.isEmpty) return;

    // Find most urgent task
    Task mostUrgent = _tasks.reduce(
          (a, b) => a.urgencyScore > b.urgencyScore ? a : b,
    );

    NotificationService().showUrgencyAlert(
      context,
      mostUrgent.title,
      mostUrgent.urgencyScore,
    );

  }

  Future<void> toggleComplete(Task task) async {
    task.isCompleted = !task.isCompleted;
    if (task.isDaily && task.isCompleted) {
      task.streak++;
    } else if (task.isDaily && !task.isCompleted) {
      task.streak = (task.streak > 0) ? task.streak - 1 : 0;
    }
    await task.save();
    notifyListeners();
  }

  Future<void> deleteTaskByTask(Task task) async {
    await _taskService.deleteTask(task);
    await loadTasks();
  }

  // --- DEMO-READY STREAK LOGIC (Minute-Based Simulation) ---
  Future<void> checkAndResetDailyTasks() async {
    var settingsBox = Hive.box('settings');

    // We store the last time the "Day" was reset
    int? lastResetTimestamp = settingsBox.get('lastResetTimestamp');
    int now = DateTime.now().millisecondsSinceEpoch;

    // DEMO RULE: 60,000 milliseconds = 1 Minute = "One Day"
    // can change 60000 to 86400000 (24 hours)
    const int simulatedDayFrame = 60000;

    if (lastResetTimestamp != null) {
      if (now - lastResetTimestamp > simulatedDayFrame) {
        // A "New Day" has passed!
        for (var task in _tasks) {
          if (task.isDaily) {
            // Reset streak if they missed their 1-minute window
            if (!task.isCompleted) {
              task.streak = 0;
            }
            task.isCompleted = false; // Reset checkbox
            await task.save();
          }
        }
        await settingsBox.put('lastResetTimestamp', now);
        debugPrint("SIMULATION: A new 'day' has passed. Tasks reset.");
      }
    } else {
      await settingsBox.put('lastResetTimestamp', now);
    }
  }

  Map<String, List<Task>> getGroupedTasks() {
    final sortedTasks = List<Task>.from(_tasks);
    sortedTasks.sort((a, b) => b.urgencyScore.compareTo(a.urgencyScore));
    Map<String, List<Task>> groups = {};
    for (var task in sortedTasks) {
      if (!groups.containsKey(task.category)) groups[task.category] = [];
      groups[task.category]!.add(task);
    }
    return groups;
  }

  double getProgressPercentage() {
    if (_tasks.isEmpty) return 0;
    return _tasks.where((t) => t.isCompleted).length / _tasks.length;
  }
}