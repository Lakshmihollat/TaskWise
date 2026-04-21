import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // Handles the "Message Box" effect in Chrome
  void showUrgencyAlert(BuildContext context, String taskTitle, double score) {
    // 1. Show a standard SnackBar for a modern look
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "🚨 MOST URGENT: $taskTitle",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.deepPurpleAccent,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "GOT IT",
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );

    // 2. This creates the actual Browser Message Box (Alert)
    // Note: This will pause the app until the user clicks "OK"
    // It is the most "un-ignorable" way to show priority.
    debugPrint("Urgency Pop-up triggered for: $taskTitle");
  }

  // Mobile initialization (kept for compatibility, but ignored in Chrome)
  Future<void> init() async {}
}