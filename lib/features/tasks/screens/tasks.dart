import 'package:flutter/material.dart';
import 'package:taskify/features/tasks/models/task.dart';
import 'package:taskify/features/tasks/services/category_service.dart';
import 'package:taskify/features/tasks/services/task_service.dart';
import 'package:taskify/features/tasks/widgets/task_widget.dart';

class Tasks extends StatefulWidget {
  const Tasks({super.key});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  final TaskService taskService = TaskService();
  final CategoryService categoryService = CategoryService();

  late Future<List<Task>> _tasksFuture;

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Load tasks on initialization
  }

  void _loadTasks() {
    setState(() {
      _tasksFuture = taskService.getAllTasks(false); // Fetch tasks
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Task>>(
        future: _tasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks available.'));
          }

          final tasks = snapshot.data!;
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

          return ListView(
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
          );
        },
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

              return TaskWidget(
                task: task,
                categoryColor: categoryColor,
                onTaskUpdated:
                    _loadTasks, // Reload tasks when a task is updated
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
