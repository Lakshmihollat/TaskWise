import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {

  @HiveField(0)
  String title;

  @HiveField(1)
  DateTime? deadline;

  @HiveField(2)
  int priority; // 1 (Low) to 3 (High)

  @HiveField(3)
  bool isDaily;

  @HiveField(4)
  bool isCompleted;

  @HiveField(5)
  int streak;

  @HiveField(6)
  String category;

  Task({
    required this.title,
    this.deadline,
    required this.priority,
    required this.isDaily,
    this.isCompleted = false,
    this.streak = 0,
    this.category = "General",
  });

  // --- INTELLIGENT SCORING LOGIC ---
  // This calculates the "Urgency" for the rule-based prioritization [cite: 15]
  // Inside task.dart
  double get urgencyScore {
    if (isCompleted) return -1.0;

    double score = priority * 10.0;

    if (!isDaily && deadline != null) {
      final now = DateTime.now();
      // Calculate difference in minutes for higher precision
      final diffInMinutes = deadline!.difference(now).inMinutes;

      if (diffInMinutes <= 0) {
        score += 100.0; // Overdue
      } else if (diffInMinutes <= 120) {
        score += 80.0;  // Due in less than 2 hours (Very Urgent) [cite: 17]
      } else if (diffInMinutes <= 720) {
        score += 50.0;  // Due in less than 12 hours [cite: 17]
      } else if (diffInMinutes <= 1440) {
        score += 30.0;  // Due in 24 hours [cite: 17]
      }
    }

    if (isDaily) score += 15.0;
    return score;
  }

  @override
  String toString() {
    return 'Task(title: $title, priority: $priority, score: $urgencyScore)';
  }
}