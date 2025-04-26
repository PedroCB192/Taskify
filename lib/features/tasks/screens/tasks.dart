import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify/features/tasks/models/task.dart';
import 'package:taskify/features/tasks/services/category_service.dart';
import 'package:taskify/features/tasks/widgets/task_widget.dart';
import 'package:taskify/features/tasks/provider/task_provider.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  final CategoryService categoryService = CategoryService();

  // Map to track expanded state of tasks
  final Map<String, bool> _expandedTasks = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => Provider.of<TaskProvider>(context, listen: false).loadTasks(),
    );
  }

  void _toggleTaskExpansion(String taskId) {
    setState(() {
      _expandedTasks[taskId] = !(_expandedTasks[taskId] ?? false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final tasks = taskProvider.tasks;
    final now = DateTime.now();

    // Divide tasks into sections
    final overdueTasks =
        tasks
            .where(
              (task) =>
                  task.date.isBefore(now) &&
                  !isSameDay(task.date, now) &&
                  !task.completed,
            )
            .toList();
    final todayTasks =
        tasks
            .where((task) => isSameDay(task.date, now) && !task.completed)
            .toList();
    final futureTasks =
        tasks
            .where((task) => task.date.isAfter(now) && !task.completed)
            .toList();
    final completedTasks = tasks.where((task) => task.completed).toList();

    return Scaffold(
      body: ListView(
        children: [
          if (overdueTasks.isNotEmpty)
            _buildSection('Overdue Tasks', overdueTasks),
          if (todayTasks.isNotEmpty)
            _buildSection('Today\'s Tasks', todayTasks),
          if (futureTasks.isNotEmpty)
            _buildSection('Future Tasks', futureTasks),
          if (completedTasks.isNotEmpty)
            _buildSection('Completed Tasks', completedTasks),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Task> tasks) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...tasks.map((task) {
          return FutureBuilder(
            future: categoryService.getCategoryById(task.categoryId),
            builder: (context, categorySnapshot) {
              if (categorySnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final category = categorySnapshot.data;
              final categoryColor =
                  category != null
                      ? Color(category.color) // Convert ARGB int to Color
                      : Colors.grey; // Default color if category not found

              return Dismissible(
                key: Key(task.id), // Unique key for each task
                direction:
                    DismissDirection.horizontal, // Allow horizontal swipe
                background: Container(
                  color: Colors.green,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.check, color: Colors.white),
                ),
                secondaryBackground: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  if (direction == DismissDirection.startToEnd) {
                    // Mark task as completed
                    final updatedTask = task.copyWith(completed: true);
                    Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    ).updateTask(updatedTask);
                  } else if (direction == DismissDirection.endToStart) {
                    // Delete the task
                    Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    ).deleteTask(task.id);
                  }
                },
                child: TaskWidget(
                  task: task,
                  categoryColor: categoryColor,
                  isExpanded: _expandedTasks[task.id] ?? false,
                  onExpansionChanged: () => _toggleTaskExpansion(task.id),
                  onTaskUpdated: () {
                    Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    ).loadTasks();
                  },
                ),
              );
            },
          );
        }).toList(),
      ],
    );
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
