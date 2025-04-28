import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify/features/tasks/models/task.dart';
import 'package:taskify/features/categories/services/category_service.dart';
import 'package:taskify/features/tasks/widgets/tasks_edit_modal.dart';
import 'package:taskify/features/tasks/widgets/tasks_widget.dart';
import 'package:taskify/features/tasks/provider/task_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
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
            _buildSection('Today\'s TasksScreen', todayTasks),
          if (futureTasks.isNotEmpty)
            _buildSection('Future TasksScreen', futureTasks),
          if (completedTasks.isNotEmpty)
            _buildSection('Completed TasksScreen', completedTasks),
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
                onDismissed: (direction) async {
                  final player = AudioPlayer();

                  if (direction == DismissDirection.startToEnd) {
                    // Play sound when the task is toggled
                    if (task.completed) {
                      // If the task is completed, mark it as not completed
                      await player.play(AssetSource('sounds/pop-off.mp3'));
                      final updatedTask = task.copyWith(completed: false);
                      Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      ).updateTask(updatedTask);
                    } else {
                      // If the task is not completed, mark it as completed
                      await player.play(AssetSource('sounds/pop-on.mp3'));
                      final updatedTask = task.copyWith(completed: true);
                      Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      ).updateTask(updatedTask);
                    }
                  } else if (direction == DismissDirection.endToStart) {
                    // Play sound when the task is deleted
                    await player.play(AssetSource('sounds/pop-off.mp3'));

                    // Delete the task
                    Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    ).deleteTask(task.id);
                  }
                },
                child: TasksWidget(
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
                  onTap: () async {
                    final result = await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (context) => TasksEditModal(task: task),
                    );

                    // Recargar las tareas si se realizó una modificación
                    if (result == true) {
                      Provider.of<TaskProvider>(
                        context,
                        listen: false,
                      ).loadTasks();
                    }
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
