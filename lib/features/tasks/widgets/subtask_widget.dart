import 'package:flutter/material.dart';
import 'package:taskify/features/tasks/models/subtask.dart';

class SubtaskWidget extends StatelessWidget {
  final Subtask subtask;

  const SubtaskWidget({super.key, required this.subtask});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: subtask.completed ? Colors.grey : Colors.blue, // Border color
          width: 1.5, // Border width
        ),
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
      ),
      child: ListTile(
        leading: Icon(
          subtask.completed ? Icons.check_circle : Icons.radio_button_unchecked,
          color: subtask.completed ? Colors.grey : Colors.blue,
        ),
        title: Text(
          subtask.name,
          style: TextStyle(
            decoration:
                subtask.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
