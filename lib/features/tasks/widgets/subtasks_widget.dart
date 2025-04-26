import 'package:flutter/material.dart';
import 'package:taskify/features/tasks/models/subtask.dart';
import 'package:audioplayers/audioplayers.dart';

class SubtaskWidget extends StatelessWidget {
  final Subtask subtask;
  final VoidCallback onSubtaskToggled;

  const SubtaskWidget({
    super.key,
    required this.subtask,
    required this.onSubtaskToggled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          final player = AudioPlayer();

          if (subtask.completed) {
            // Reproducir sonido "pop-off" al descompletar
            await player.play(AssetSource('sounds/pop-off.mp3'));
          } else {
            // Reproducir sonido "pop-on" al completar
            await player.play(AssetSource('sounds/pop-on.mp3'));
          }

          // Toggle subtask completion
          onSubtaskToggled();
        } catch (e) {
          print('Error reproduciendo el sonido: $e');
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0),
        decoration: BoxDecoration(
          border: Border.all(
            color:
                subtask.completed ? Colors.grey : Colors.blue, // Border color
            width: 1.5, // Border width
          ),
          borderRadius: BorderRadius.circular(8.0), // Rounded corners
        ),
        child: ListTile(
          leading: Icon(
            subtask.completed
                ? Icons.check_circle
                : Icons.radio_button_unchecked,
            color: subtask.completed ? Colors.grey : Colors.blue,
          ),
          title: Text(
            subtask.name,
            style: TextStyle(
              decoration:
                  subtask.completed
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
              color: subtask.completed ? Colors.grey : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
