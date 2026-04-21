import 'package:hive/hive.dart';
import '../models/task.dart';

class TaskService {
  final String _boxName = "taskBox";

  // Use a getter to ensure we are always pointing to the open box
  Box<Task> get _box => Hive.box<Task>(_boxName);

  // CREATE: We use 'add' so Hive manages the unique keys
  Future<void> addTask(Task task) async {
    await _box.add(task);
  }

  // READ: Fetch all objects currently stored in the backend
  List<Task> getTasks() {
    return _box.values.toList();
  }

  // DELETE: Remove specifically from the backend
  Future<void> deleteTask(Task task) async {
    await task.delete();
  }
}