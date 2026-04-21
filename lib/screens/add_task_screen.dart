import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import 'package:intl/intl.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController(text: "General");

  int _priority = 1;
  bool _isDaily = false;
  DateTime? _selectedDate;

  // Consistent Color Palette
  final Color primaryDark = const Color(0xFF1A1A2E);
  final Color accentPurple = const Color(0xFF6C63FF);

  void _saveTask() {
    if (_titleController.text.trim().isEmpty) return;

    final task = Task(
      title: _titleController.text.trim(),
      deadline: _isDaily ? null : _selectedDate,
      priority: _priority,
      isDaily: _isDaily,
      category: _categoryController.text.trim(),
    );

    // PASS THE CONTEXT HERE
    Provider.of<TaskProvider>(context, listen: false).addTask(task, context);

    Navigator.pop(context);

  }

  void _pickDate() async {
    // 1. Pick the Date
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // 2. Pick the Time
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          // Combine Date and Time into one DateTime object
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryDark, // Matches Welcome Screen
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("New Assignment", style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TITLE INPUT SECTION
            _buildSectionLabel("What needs to be done?"),
            TextField(
              controller: _titleController,
              style: const TextStyle(color: Colors.white, fontSize: 18),
              decoration: InputDecoration(
                hintText: "Enter task name...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.assignment_outlined, color: accentPurple),
              ),
            ),

            const SizedBox(height: 25),

            // DUAL TASK TYPE SELECTOR
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  _buildTypeTab("One-time Task", !_isDaily, Icons.timer_outlined),
                  _buildTypeTab("Daily Habit", _isDaily, Icons.auto_awesome_rounded),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // MAIN CONFIGURATION CARD
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  // PRIORITY SELECTOR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.flag_rounded, color: _getPriorityColor(_priority)),
                          const SizedBox(width: 10),
                          const Text("Priority Level", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      DropdownButton<int>(
                        value: _priority,
                        dropdownColor: primaryDark,
                        underline: const SizedBox(),
                        items: [1, 2, 3].map((p) => DropdownMenuItem(
                          value: p,
                          child: Text("Level $p", style: TextStyle(color: _getPriorityColor(p))),
                        )).toList(),
                        onChanged: (val) => setState(() => _priority = val!),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white10, height: 30),

                  // CATEGORY INPUT [cite: 49]
                  TextField(
                    controller: _categoryController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: "Category",
                      labelStyle: TextStyle(color: Colors.white38),
                      prefixIcon: Icon(Icons.folder_open, color: Colors.white38),
                      border: InputBorder.none,
                    ),
                  ),

                  if (!_isDaily) ...[
                    const Divider(color: Colors.white10, height: 30),
                    // DATE PICKER [cite: 17]
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      onTap: _pickDate,
                      leading: Icon(Icons.calendar_month, color: accentPurple),
                      title: Text(
                        _selectedDate == null
                            ? "Set Deadline"
                            : DateFormat('MMM dd, yyyy').format(_selectedDate!),
                        style: const TextStyle(color: Colors.white),
                      ),
                      trailing: const Icon(Icons.chevron_right, color: Colors.white38),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 40),

            // GLOWING SAVE BUTTON
            GestureDetector(
              onTap: _saveTask,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [accentPurple, Colors.deepPurpleAccent]),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: accentPurple.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "Create Task",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildTypeTab(String label, bool isSelected, IconData icon) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isDaily = label == "Daily Habit"),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? accentPurple : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : Colors.white38),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(int p) {
    if (p == 3) return Colors.redAccent;
    if (p == 2) return Colors.orangeAccent;
    return Colors.greenAccent;
  }
}