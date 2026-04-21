import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'models/task.dart';
import 'providers/task_provider.dart';
import 'screens/add_task_screen.dart';
import 'screens/DashboardScreen.dart';
import 'screens/welcome_screen.dart';
import 'services/notification_service.dart';

const Color kPrimaryDark = Color(0xFF1A1A2E);
const Color kAccentPurple = Color(0xFF6C63FF);
const Color kSurfaceColor = Color(0xFF25254B);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(TaskAdapter());
  }
  await Hive.openBox<Task>('taskBox');
  await Hive.openBox('settings');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()..loadTasks()),
      ],
      child: TaskWiseApp(),
    ),
  );
}

class TaskWiseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TaskWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kPrimaryDark,
        colorScheme: ColorScheme.dark(primary: kAccentPurple, surface: kSurfaceColor),
      ),
      home: WelcomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget { // Changed to StatefulWidget
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Automatically check for resets every 10 seconds
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      Provider.of<TaskProvider>(context, listen: false).loadTasks();
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Clean up the timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("TaskWise", style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Icons.insights_rounded, color: kAccentPurple),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DashboardScreen())),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final groupedTasks = taskProvider.getGroupedTasks();
          if (groupedTasks.isEmpty) return _buildEmptyState();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: groupedTasks.entries.map((entry) {
              return _buildTaskCategory(entry.key, entry.value, taskProvider);
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: kAccentPurple,
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddTaskScreen())),
        label: const Text("New Task", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        icon: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_awesome_mosaic, size: 80, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text("No tasks yet", style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 18)),
          const Text("Ready to be productive?", style: TextStyle(color: Colors.white24)),
        ],
      ),
    );
  }

  Widget _buildTaskCategory(String category, List<Task> tasks, TaskProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(
              color: kAccentPurple,
              fontWeight: FontWeight.bold,
              fontSize: 11,
              letterSpacing: 1.5,
            ),
          ),
        ),
        ...tasks.map((task) => _buildTaskCard(task, provider)).toList(),
      ],
    );
  }

  Widget _buildTaskCard(Task task, TaskProvider provider) {
    return Dismissible(
      key: Key(task.key.toString() + task.title),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      // Swipe-to-delete logic
      onDismissed: (direction) => provider.deleteTaskByTask(task),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: kSurfaceColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: GestureDetector(
            onTap: () => provider.toggleComplete(task),
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: task.isCompleted ? kAccentPurple : Colors.white24,
                  width: 2,
                ),
                color: task.isCompleted ? kAccentPurple : Colors.transparent,
              ),
              child: task.isCompleted ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
            ),
          ),
          title: Text(
            task.title,
            style: TextStyle(
              color: task.isCompleted ? Colors.white38 : Colors.white,
              fontWeight: FontWeight.bold,
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Row(
              children: [
                if (task.isDaily) ...[
                  const Icon(Icons.local_fire_department, color: Colors.orange, size: 16),
                  const SizedBox(width: 4),
                  Text("${task.streak} Day Streak", style: const TextStyle(color: Colors.orange, fontSize: 12)),
                ] else ...[
                  const Icon(Icons.access_time_rounded, color: Colors.white38, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    task.deadline != null
                        ? DateFormat('MMM dd, h:mm a').format(task.deadline!)
                        : "No Deadline",
                    style: TextStyle(
                      // If deadline exists AND it is in the past, make it Red
                      color: (task.deadline != null && task.deadline!.isBefore(DateTime.now()))
                          ? Colors.redAccent
                          : Colors.white38,
                      fontSize: 12,
                      fontWeight: (task.deadline != null && task.deadline!.isBefore(DateTime.now()))
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}