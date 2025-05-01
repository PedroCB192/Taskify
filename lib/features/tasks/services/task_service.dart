import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskify/features/tasks/models/subtask.dart';
import 'package:taskify/features/tasks/models/task.dart';
import 'package:taskify/features/profile/services/user_service.dart';

class TaskService {
  final Box<Task> _taskBox = Hive.box<Task>('tasks');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // Obtener si el usuario es premium desde el almacenamiento local
  bool get _isPremium => _userService.getUser()?.isPremium ?? false;

  // Agregar una nueva tarea
  Future<void> addTask(Task task) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Asignar "No Category" si no se seleccionó ninguna categoría
    final categoryId = task.categoryId.isEmpty ? 'default' : task.categoryId;

    final taskWithUserId = Task(
      id: task.id,
      name: task.name,
      date: task.date,
      time: task.time,
      subtasks: task.subtasks,
      categoryId: categoryId,
      completed: task.completed,
      isSynced: task.isSynced,
      userId: user.uid, // Asociar el userId
    );

    // Guardar en Hive
    await _taskBox.put(task.id, taskWithUserId);

    // Guardar en Firebase si el usuario es premium
    if (_isPremium) {
      await _firestore.collection('tasks').doc(task.id).set({
        'name': task.name,
        'date': task.date.toIso8601String(),
        'time':
            task.time != null
                ? '${task.time!.hour}:${task.time!.minute}' // Guardar como "HH:mm"
                : null,
        'subtasks':
            task.subtasks?.map((subtask) => subtask.toFirestore()).toList(),
        'categoryId': categoryId,
        'completed': task.completed,
        'userId': user.uid,
        'lastModified': DateTime.now().toIso8601String(),
      });
    }
  }

  // Sincronizar tareas entre Hive y Firebase
  Future<void> syncTasks() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final remoteTasks =
        await _firestore
            .collection('tasks')
            .where('userId', isEqualTo: user.uid)
            .get();

    for (var remoteTask in remoteTasks.docs) {
      final task = Task(
        id: remoteTask.id,
        name: remoteTask['name'],
        date: DateTime.parse(remoteTask['date']),
        time:
            remoteTask['time'] != null
                ? TimeOfDay(
                  hour: int.parse(remoteTask['time'].split(':')[0]),
                  minute: int.parse(remoteTask['time'].split(':')[1]),
                )
                : null,
        subtasks:
            remoteTask['subtasks'] != null
                ? (remoteTask['subtasks'] as List)
                    .map((subtask) => Subtask.fromFirestore(subtask))
                    .toList()
                : null,
        categoryId: remoteTask['categoryId'],
        completed: remoteTask['completed'],
        isSynced: true,
        userId: remoteTask['userId'],
      );

      // Guardar en Hive
      await _taskBox.put(remoteTask.id, task);
    }
  }

  // Obtener todas las tareas desde Hive
  Future<List<Task>> getAllTasks() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Filtrar tareas locales por userId
    return _taskBox.values.where((task) => task.userId == user.uid).toList();
  }

  // Obtener una tarea específica desde Hive
  Future<Task?> getTask(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Leer desde Hive
    final localTask = _taskBox.get(id);
    if (localTask != null && localTask.userId == user.uid) {
      return localTask;
    }

    return null; // No encontrada
  }

  // Actualizar una tarea existente en Hive y opcionalmente en Firebase
  Future<void> updateTask(Task task) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    if (task.userId != user.uid) throw Exception('Not authorized');

    // Actualizar en Hive
    await _taskBox.put(task.id, task);

    // Actualizar en Firebase si el usuario es premium
    if (_isPremium) {
      print('Updating task in Firebase: ${task.id}');
      final docRef = _firestore.collection('tasks').doc(task.id);

      try {
        // Verificar si el documento existe
        final docSnapshot = await docRef.get();
        if (docSnapshot.exists) {
          // Actualizar el documento si existe
          await docRef.update({
            'name': task.name,
            'date': task.date.toIso8601String(),
            'time':
                task.time != null
                    ? '${task.time!.hour}:${task.time!.minute}'
                    : null,
            'subtasks':
                task.subtasks?.map((subtask) => subtask.toFirestore()).toList(),
            'categoryId': task.categoryId,
            'completed': task.completed,
            'userId': task.userId,
            'lastModified': DateTime.now().toIso8601String(),
          });
        } else {
          // Crear el documento si no existe
          await docRef.set({
            'name': task.name,
            'date': task.date.toIso8601String(),
            'time':
                task.time != null
                    ? '${task.time!.hour}:${task.time!.minute}'
                    : null,
            'subtasks':
                task.subtasks?.map((subtask) => subtask.toFirestore()).toList(),
            'categoryId': task.categoryId,
            'completed': task.completed,
            'userId': task.userId,
            'lastModified': DateTime.now().toIso8601String(),
          });
        }
      } catch (e) {
        print('Error updating or creating task in Firebase: $e');
        throw Exception('Failed to update or create task in Firebase');
      }
    }
  }

  // Eliminar una tarea de Hive y opcionalmente de Firebase
  Future<void> deleteTask(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final localTask = _taskBox.get(id);
    if (localTask == null || localTask.userId != user.uid) {
      throw Exception('Not authorized');
    }

    // Eliminar de Hive
    await _taskBox.delete(id);

    // Eliminar de Firebase si el usuario es premium
    if (_isPremium) {
      await _firestore.collection('tasks').doc(id).delete();
    }
  }
}
