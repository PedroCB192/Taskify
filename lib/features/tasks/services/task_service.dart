import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskify/features/tasks/models/subtask.dart';
import 'package:taskify/features/tasks/models/task.dart';

class TaskService {
  final Box<Task> _taskBox = Hive.box<Task>('tasks');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new task to Hive and optionally to Firebase if the user is premium
  Future<void> addTask(Task task, bool isPremium) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Assign "No Category" if no category is selected
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
      userId: user.uid, // Associate the userId
    );

    // Save to Hive
    await _taskBox.put(task.id, taskWithUserId);

    // Save to Firebase if the user is premium
    if (isPremium) {
      await _firestore.collection('tasks').doc(task.id).set({
        'name': task.name,
        'date': task.date.toIso8601String(),
        'time':
            task.time != null
                ? '${task.time!.hour}:${task.time!.minute}' // Save as "HH:mm"
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

  // Synchronize tasks between Hive and Firebase
  Future<void> syncTasks(bool isPremium) async {
    if (!isPremium) return;

    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final remoteTasks =
        await _firestore
            .collection('tasks')
            .where('userId', isEqualTo: user.uid)
            .get();

    for (var remoteTask in remoteTasks.docs) {
      final localTask = _taskBox.get(remoteTask.id);

      if (localTask == null ||
          DateTime.parse(remoteTask['lastModified']).isAfter(localTask.date)) {
        // Update Hive with Firebase data
        await _taskBox.put(
          remoteTask.id,
          Task(
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
          ),
        );
      } else {
        // Update Firebase with Hive data
        await _firestore.collection('tasks').doc(localTask.id).set({
          'name': localTask.name,
          'date': localTask.date.toIso8601String(),
          'time':
              localTask.time != null
                  ? '${localTask.time!.hour}:${localTask.time!.minute}'
                  : null,
          'subtasks':
              localTask.subtasks
                  ?.map((subtask) => subtask.toFirestore())
                  .toList(),
          'categoryId': localTask.categoryId,
          'completed': localTask.completed,
          'userId': localTask.userId,
          'lastModified': DateTime.now().toIso8601String(),
        });
      }
    }
  }

  // Retrieve all tasks from Hive and optionally sync with Firebase if the user is premium
  Future<List<Task>> getAllTasks(bool isPremium) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Filter local tasks by userId
    final localTasks =
        _taskBox.values.where((task) => task.userId == user.uid).toList();

    if (!isPremium) {
      // If not premium, return only local tasks
      return localTasks;
    }

    // If premium, sync with Firebase
    await syncTasks(isPremium);

    // Return all updated local tasks
    return _taskBox.values.where((task) => task.userId == user.uid).toList();
  }

  // Retrieve a specific task by its ID from Hive or Firebase
  Future<Task?> getTask(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Read from Hive
    final localTask = _taskBox.get(id);
    if (localTask != null && localTask.userId == user.uid) {
      return localTask;
    }

    // Read from Firebase if not found in Hive
    final remoteTask = await _firestore.collection('tasks').doc(id).get();
    if (remoteTask.exists && remoteTask['userId'] == user.uid) {
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
      // Save to Hive for offline access
      await _taskBox.put(id, task);
      return task;
    }

    return null; // Not found
  }

  // Update an existing task in Hive and optionally in Firebase if the user is premium
  Future<void> updateTask(Task task, bool isPremium) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    if (task.userId != user.uid) throw Exception('Not authorized');

    // Update in Hive
    await _taskBox.put(task.id, task);

    // Update in Firebase if the user is premium
    if (isPremium) {
      await _firestore.collection('tasks').doc(task.id).update({
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
  }

  // Delete a task from Hive and optionally from Firebase if the user is premium
  Future<void> deleteTask(String id, bool isPremium) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final localTask = _taskBox.get(id);
    if (localTask == null || localTask.userId != user.uid) {
      throw Exception('Not authorized');
    }

    // Delete from Hive
    await _taskBox.delete(id);

    // Delete from Firebase if the user is premium
    if (isPremium) {
      await _firestore.collection('tasks').doc(id).delete();
    }
  }
}
