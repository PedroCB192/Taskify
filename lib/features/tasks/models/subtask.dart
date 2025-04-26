import 'package:hive/hive.dart';

part 'subtask.g.dart'; // Automatically generated file by Hive

@HiveType(typeId: 1) // Unique identifier for Hive
class Subtask {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final bool completed;

  Subtask({required this.name, this.completed = false});

  // Method to convert the model to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {'name': name, 'completed': completed};
  }

  // Method to create a Subtask instance from a Firestore document
  factory Subtask.fromFirestore(Map<String, dynamic> data) {
    return Subtask(name: data['name'], completed: data['completed']);
  }
}
