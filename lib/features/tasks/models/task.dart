import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'subtask.dart';

part 'task.g.dart'; // Automatically generated file by Hive

@HiveType(typeId: 0) // Unique identifier for Hive
class Task {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final TimeOfDay? time;

  @HiveField(4)
  final List<Subtask>? subtasks;

  @HiveField(5)
  final String categoryId;

  @HiveField(6)
  bool completed; // Removed `late`

  @HiveField(7)
  final bool isSynced;

  @HiveField(8)
  final String userId;

  Task({
    required this.id,
    required this.name,
    required this.date,
    this.time,
    this.subtasks,
    required this.categoryId,
    this.completed = false, // Default value
    this.isSynced = false,
    required this.userId,
  });

  // Method to convert the model to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'time': time != null ? '${time!.hour}:${time!.minute}' : null,
      'subtasks': subtasks?.map((subtask) => subtask.toFirestore()).toList(),
      'categoryId': categoryId,
      'completed': completed,
      'isSynced': isSynced,
      'userId': userId,
    };
  }

  // Method to create a Task instance from a Firestore document
  factory Task.fromFirestore(Map<String, dynamic> data) {
    return Task(
      id: data['id'],
      name: data['name'],
      date: DateTime.parse(data['date']),
      time:
          data['time'] != null
              ? TimeOfDay(
                hour: int.parse(data['time'].split(':')[0]),
                minute: int.parse(data['time'].split(':')[1]),
              )
              : null,
      subtasks:
          data['subtasks'] != null
              ? (data['subtasks'] as List)
                  .map((subtask) => Subtask.fromFirestore(subtask))
                  .toList()
              : null,
      categoryId: data['categoryId'],
      completed: data['completed'], // Initialize directly
      isSynced: data['isSynced'],
      userId: data['userId'],
    );
  }
}
