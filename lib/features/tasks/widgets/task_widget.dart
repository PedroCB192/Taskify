import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:taskify/features/tasks/models/task.dart';
import 'package:taskify/features/tasks/widgets/subtask_widget.dart';

class TaskWidget extends StatefulWidget {
  final Task task;
  final Color categoryColor;

  const TaskWidget({
    super.key,
    required this.task,
    required this.categoryColor,
    required void Function() onTaskUpdated,
  });

  @override
  State<TaskWidget> createState() => _TaskWidgetState();
}

class _TaskWidgetState extends State<TaskWidget> {
  bool _isExpanded = false; // Controls whether subtasks are shown

  @override
  Widget build(BuildContext context) {
    final taskColor =
        widget.task.completed ? Colors.grey : widget.categoryColor;

    // Format the date using intl
    final formattedDate = DateFormat('yyyy-MM-dd').format(widget.task.date);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: taskColor, // Use category color or grey if completed
          width: 2.0, // Border width
        ),
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
      ),
      child: Column(
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: () {
                // Toggle task completion
                setState(() {
                  widget.task.completed = !widget.task.completed;
                });
              },
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        widget.task.completed
                            ? Colors.grey
                            : widget.categoryColor,
                    width: 2,
                  ),
                ),
                child:
                    widget.task.completed
                        ? const Icon(Icons.check, color: Colors.grey, size: 16)
                        : null,
              ),
            ),
            title: Text(
              widget.task.name,
              style: TextStyle(
                decoration:
                    widget.task.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 4,
                ), // Add spacing between title and subtitle
                Text(
                  'Due: $formattedDate', // Use the formatted date
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            trailing: IconButton(
              icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
            ),
          ),
          if (_isExpanded && widget.task.subtasks != null)
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                bottom: 8.0,
              ),
              child: Column(
                children:
                    widget.task.subtasks!
                        .map((subtask) => SubtaskWidget(subtask: subtask))
                        .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
