import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:taskify/features/tasks/models/task.dart';
import 'package:taskify/features/tasks/widgets/subtasks_widget.dart';
import 'package:taskify/features/tasks/provider/task_provider.dart';
import 'package:taskify/features/tasks/widgets/tasks_edit_modal.dart';
import 'package:audioplayers/audioplayers.dart';

class TasksWidget extends StatefulWidget {
  final Task task;
  final Color categoryColor;
  final bool isExpanded;
  final VoidCallback onExpansionChanged;
  final VoidCallback onTaskUpdated;

  const TasksWidget({
    super.key,
    required this.task,
    required this.categoryColor,
    required this.isExpanded,
    required this.onExpansionChanged,
    required this.onTaskUpdated,
    required Future<Null> Function() onTap,
  });

  @override
  State<TasksWidget> createState() => _TasksWidgetState();
}

class _TasksWidgetState extends State<TasksWidget> {
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
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: GestureDetector(
        onTap: () {
          // Open the edit modal when the task is tapped
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => TasksEditModal(task: widget.task),
          );
        },
        child: Column(
          children: [
            ListTile(
              leading: GestureDetector(
                onTap: () async {
                  try {
                    final player = AudioPlayer();

                    if (widget.task.completed) {
                      // Reproducir sonido "pop-off" al descompletar
                      await player.play(AssetSource('sounds/pop-off.mp3'));
                    } else {
                      // Reproducir sonido "pop-on" al completar
                      await player.play(AssetSource('sounds/pop-on.mp3'));
                    }

                    // Toggle task completion
                    final updatedTask = widget.task.copyWith(
                      completed: !widget.task.completed,
                    );
                    Provider.of<TaskProvider>(
                      context,
                      listen: false,
                    ).updateTask(updatedTask);
                    widget.onTaskUpdated();
                  } catch (e) {
                    print('Error reproduciendo el sonido: $e');
                  }
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
                          ? const Icon(
                            Icons.check,
                            color: Colors.grey,
                            size: 16,
                          )
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
                  const SizedBox(height: 4),
                  Text(
                    'Due: $formattedDate', // Use the formatted date
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              trailing: IconButton(
                icon: Icon(
                  widget.isExpanded ? Icons.expand_less : Icons.expand_more,
                ),
                onPressed: widget.onExpansionChanged,
              ),
            ),
            if (widget.isExpanded && widget.task.subtasks != null)
              Padding(
                padding: const EdgeInsets.only(
                  left: 16.0,
                  right: 16.0,
                  bottom: 8.0,
                ),
                child: Column(
                  children:
                      widget.task.subtasks!.map((subtask) {
                        return SubtasksWidget(
                          subtask: subtask,
                          onSubtaskToggled: () {
                            setState(() {
                              subtask.completed = !subtask.completed;
                            });
                            // Update the task in the provider
                            final updatedTask = widget.task.copyWith(
                              subtasks: widget.task.subtasks,
                            );
                            Provider.of<TaskProvider>(
                              context,
                              listen: false,
                            ).updateTask(updatedTask);
                            widget.onTaskUpdated();
                          },
                        );
                      }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
