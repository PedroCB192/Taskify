import 'package:flutter/material.dart';
import 'package:taskify/features/categories/models/category.dart';

class CategoriesWidget extends StatelessWidget {
  final Category category;
  final int taskCount;

  const CategoriesWidget({
    super.key,
    required this.category,
    required this.taskCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 150,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 2.0),
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Círculo con el color de la categoría
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: category.colorAsColor, // Usar el color de la categoría
              border: Border.all(color: Colors.black, width: 2.0),
            ),
          ),
          const SizedBox(height: 10),

          // Nombre de la categoría
          Text(
            category.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),

          // Cantidad de tareas
          Text(
            '$taskCount Tasks',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
