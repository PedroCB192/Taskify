import 'package:flutter/material.dart';
import 'package:taskify/features/tasks/models/task.dart';
import 'package:taskify/features/tasks/services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  Future<void> loadTasks() async {
    _tasks = await _taskService.getAllTasks();
    notifyListeners(); // Notifica a los widgets que dependen de este estado
  }

  Future<void> addTask(Task task) async {
    await _taskService.addTask(task);
    _tasks.add(task);
    notifyListeners(); // Notifica a los widgets que dependen de este estado
  }

  Future<void> updateTask(Task task) async {
    await _taskService.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners(); // Notifica a los widgets que dependen de este estado
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _taskService.deleteTask(taskId);
    _tasks.removeWhere((task) => task.id == taskId);
    notifyListeners(); // Notifica a los widgets que dependen de este estado
  }

  Future<void> deleteTasksByCategoryId(String categoryId) async {
    // Filtrar las tareas asociadas a la categoría
    final tasksToDelete =
        _tasks.where((task) => task.categoryId == categoryId).toList();

    // Eliminar cada tarea individualmente
    for (final task in tasksToDelete) {
      await _taskService.deleteTask(task.id);
      _tasks.removeWhere((t) => t.id == task.id);
    }

    // Notificar a los widgets que dependen de TaskProvider
    notifyListeners();
  }
}
