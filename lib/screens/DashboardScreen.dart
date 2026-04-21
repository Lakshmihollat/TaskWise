import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:ui';
import '../providers/task_provider.dart';
import '../models/task.dart';

class DashboardScreen extends StatelessWidget {
  // Shared Palette
  final Color primaryDark = const Color(0xFF1A1A2E);
  final Color accentPurple = const Color(0xFF6C63FF);
  final Color accentOrange = const Color(0xFFFF8C42);
  final Color accentBlue = const Color(0xFF00D2FF);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final allTasks = taskProvider.tasks;

    double progress = taskProvider.getProgressPercentage();
    int total = allTasks.length;
    int completed = allTasks.where((t) => t.isCompleted).length;
    int pending = total - completed;

    // --- NEW LOGIC: Finding the Highest Streak ---
    int highestStreak = 0;
    if (allTasks.isNotEmpty) {
      highestStreak = allTasks.fold(0, (max, task) => task.streak > max ? task.streak : max);
    }

    return Scaffold(
      backgroundColor: primaryDark,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("LeaderBoard - Performance Metrics", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [accentPurple.withOpacity(0.1), primaryDark],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. DYNAMIC STREAK HERO CARD
              _buildStreakHero(highestStreak),

              const SizedBox(height: 30),
              _buildSectionLabel("Activity Analysis"),

              // 2. MODERN DONUT WHEEL
              _buildDonutChartCard(progress, completed, pending),

              const SizedBox(height: 30),
              _buildSectionLabel("Quick Stats"),

              // 3. STATS GRID
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 15,
                crossAxisSpacing: 15,
                childAspectRatio: 1.4,
                children: [
                  _buildStatTile("Total Scope", total.toString(), Icons.layers_outlined, Colors.blueAccent),
                  _buildStatTile("Goal Hit", completed.toString(), Icons.verified_user_outlined, Colors.greenAccent),
                  _buildStatTile("Backlog", pending.toString(), Icons.hourglass_empty_rounded, Colors.orangeAccent),
                  _buildStatTile("Rank", _getLevelString(progress), Icons.military_tech_outlined, Colors.amberAccent),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildStreakHero(int highest) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6C63FF), Color(0xFF3F3D56)],
        ),
        boxShadow: [
          BoxShadow(color: accentPurple.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("STREAK CHAMPION",
                  style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2)),
              Icon(Icons.workspace_premium, color: accentOrange, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text("$highest", style: const TextStyle(color: Colors.white, fontSize: 52, fontWeight: FontWeight.w900)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("DAYS", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text("MAX CONSISTENCY", style: TextStyle(color: Colors.white60, fontSize: 10)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          const LinearProgressIndicator(
            value: 0.8, // Just for visual flair
            backgroundColor: Colors.white10,
            color: Colors.white,
            minHeight: 2,
          )
        ],
      ),
    );
  }

  Widget _buildDonutChartCard(double progress, int completed, int pending) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 6,
                    centerSpaceRadius: 60,
                    startDegreeOffset: -90,
                    sections: [
                      PieChartSectionData(
                        value: completed.toDouble(),
                        title: "",
                        radius: 20,
                        color: accentPurple,
                        showTitle: false,
                      ),
                      PieChartSectionData(
                        value: pending == 0 && completed == 0 ? 1 : pending.toDouble(),
                        title: "",
                        radius: 15,
                        color: Colors.white.withOpacity(0.05),
                        showTitle: false,
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("${(progress * 100).toInt()}%",
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
                      const Text("EFFICIENCY", style: TextStyle(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _indicator("Done", accentPurple),
              _indicator("Left", Colors.white10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _indicator(String text, Color color) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatTile(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 5),
      child: Text(text,
          style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2)),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: const Color(0xFF25254B).withOpacity(0.5),
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: Colors.white.withOpacity(0.05)),
    );
  }

  String _getLevelString(double progress) {
    if (progress >= 1.0) return "ELITE";
    if (progress > 0.7) return "PRO";
    if (progress > 0.4) return "MASTER";
    return "NOVICE";
  }
}