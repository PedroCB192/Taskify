import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category.g.dart'; // Automatically generated file by Hive

@HiveType(typeId: 2) // Unique identifier for Hive
class Category {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final bool isSynced;

  @HiveField(3)
  final String userId;

  @HiveField(4)
  final int color; // Store color as an integer (ARGB value)

  Category({
    required this.id,
    required this.name,
    this.isSynced = false,
    required this.userId,
    required this.color,
  });

  // Method to convert the model to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'name': name,
      'isSynced': isSynced,
      'userId': userId,
      'color': color, // Include color in Firestore
    };
  }

  // Method to create a Category instance from a Firestore document
  factory Category.fromFirestore(Map<String, dynamic> data, String id) {
    return Category(
      id: id,
      name: data['name'],
      isSynced: data['isSynced'],
      userId: data['userId'],
      color: data['color'], // Retrieve color from Firestore
    );
  }

  // Convert the integer color back to a Flutter Color object
  Color get colorAsColor => Color(color);

  // Add the copyWith method
  Category copyWith({
    String? id,
    String? name,
    bool? isSynced,
    String? userId,
    int? color,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      isSynced: isSynced ?? this.isSynced,
      userId: userId ?? this.userId,
      color: color ?? this.color,
    );
  }
}
