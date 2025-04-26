import 'package:flutter/material.dart';
import 'package:taskify/core/constants/app_colors.dart';
import 'package:taskify/core/constants/default_colors.dart';
import 'package:taskify/features/tasks/models/task.dart';
import 'package:taskify/features/tasks/models/subtask.dart';
import 'package:taskify/features/tasks/models/category.dart';
import 'package:taskify/features/tasks/services/category_service.dart';
import 'package:provider/provider.dart';
import 'package:taskify/features/tasks/provider/task_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class TasksEditModal extends StatefulWidget {
  final Task task; // Recibe la tarea como parámetro

  const TasksEditModal({super.key, required this.task});

  @override
  State<TasksEditModal> createState() => _TaskEditModalState();
}

class _TaskEditModalState extends State<TasksEditModal> {
  late TextEditingController _taskNameController;
  late DateTime _selectedDate;
  late List<TextEditingController> _subtaskControllers;

  final List<Category> _categories = [];
  String? _selectedCategory;
  final TextEditingController _categoryController = TextEditingController();
  final CategoryService _categoryService = CategoryService();
  final bool _isPremium = true; // Cambia esto según la lógica de tu app
  Color _selectedColor = DefaultColors.availableColors.first;

  @override
  void initState() {
    super.initState();
    // Inicializar los controladores con los datos de la tarea
    _taskNameController = TextEditingController(text: widget.task.name);
    _selectedDate = widget.task.date;
    _subtaskControllers =
        widget.task.subtasks != null
            ? widget.task.subtasks!
                .map((subtask) => TextEditingController(text: subtask.name))
                .toList()
            : [];
    _selectedCategory = widget.task.categoryId;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final loadedCategories = await _categoryService.getAllCategories(
        _isPremium,
      );

      setState(() {
        _categories.addAll(loadedCategories);
        if (!_categories.any((cat) => cat.id == _selectedCategory)) {
          _selectedCategory =
              _categories.isNotEmpty ? _categories.first.id : null;
        }
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                backgroundColor: AppColors.backgroundLight,
                title: const Text('Add new category'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _categoryController,
                      decoration: const InputDecoration(
                        label: Text("Enter category name"),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Select a color:'),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children:
                          DefaultColors.availableColors.map((color) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = color;
                                });
                              },
                              child: Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        _selectedColor == color
                                            ? Colors.black
                                            : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final newCategoryName = _categoryController.text.trim();
                      if (newCategoryName.isNotEmpty &&
                          !_categories.any(
                            (cat) => cat.name == newCategoryName,
                          )) {
                        try {
                          final newCategory = Category(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            name: newCategoryName,
                            userId: widget.task.userId,
                            color: _selectedColor.value,
                          );

                          await _categoryService.addCategory(
                            newCategory,
                            _isPremium,
                          );

                          setState(() {
                            _categories.add(newCategory);
                            _selectedCategory = newCategory.id;
                          });
                        } catch (e) {
                          print('Error adding category: $e');
                        }
                      }
                      _categoryController.clear();
                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _categoryController.dispose();
    for (var controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16.0,
          right: 16.0,
          top: 16.0,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Title
            Text(
              'Edit Task',
              style: TextStyle(fontSize: 25, color: AppColors.roseBonbon),
            ),
            const SizedBox(height: 10),
            // Task Name Field
            TextField(
              controller: _taskNameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Task Name',
              ),
            ),
            const SizedBox(height: 10),
            // Subtasks
            if (_subtaskControllers.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _subtaskControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => _removeSubtaskField(index),
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.lavenderFloral,
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _subtaskControllers[index],
                            decoration: InputDecoration(
                              labelText: "Subtask ${index + 1}",
                              border: const OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: // Category Selector
                      DropdownButtonFormField<String>(
                    value:
                        _categories.any((cat) => cat.id == _selectedCategory)
                            ? _selectedCategory
                            : null, // Aseguramos que la categoría seleccionada sea válida
                    hint: const Text('Select Category'),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                    ),
                    onChanged: (value) {
                      if (value == 'New Category') {
                        _showAddCategoryDialog();
                      } else {
                        setState(() {
                          _selectedCategory = value;
                        });
                      }
                    },
                    items: [
                      ..._categories.map((cat) {
                        return DropdownMenuItem<String>(
                          value: cat.id,
                          child: Text(cat.name),
                        );
                      }).toList(),
                      const DropdownMenuItem<String>(
                        value: 'New Category',
                        child: Text('New Category'),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                // Date Picker Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _selectDate(context),
                    child: const Icon(Icons.calendar_today),
                  ),
                ),
                const SizedBox(width: 10),
                // Add Subtask Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: _addSubtaskField,
                    child: const Icon(
                      Icons.subject,
                      color: AppColors.lavenderFloral,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Lógica para cerrar el modal sin guardar cambios
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.cancel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lavenderFloral,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Delete Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // Reproducir el sonido "pop-off"
                        final player = AudioPlayer();
                        await player.play(AssetSource('sounds/pop-off.mp3'));

                        // Eliminar la tarea
                        Provider.of<TaskProvider>(
                          context,
                          listen: false,
                        ).deleteTask(widget.task.id);

                        // Cerrar el modal después de eliminar
                        Navigator.pop(context);
                      } catch (e) {
                        print('Error deleting task: $e');
                      }
                    },
                    child: const Icon(Icons.delete),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lavenderFloral,
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Save Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // Reproducir el sonido "pop-on"
                        final player = AudioPlayer();
                        await player.play(AssetSource('sounds/pop-on.mp3'));

                        // Obtener las subtareas
                        final subtasks =
                            _subtaskControllers
                                .map(
                                  (controller) => Subtask(
                                    name: controller.text.trim(),
                                    completed: false,
                                  ),
                                )
                                .toList();

                        // Actualizar la tarea existente
                        final updatedTask = widget.task.copyWith(
                          name: _taskNameController.text.trim(),
                          date: _selectedDate,
                          subtasks: subtasks,
                          categoryId: _selectedCategory,
                        );

                        // Guardar la tarea actualizada
                        Provider.of<TaskProvider>(
                          context,
                          listen: false,
                        ).updateTask(updatedTask);

                        // Cerrar el modal y notificar el cambio
                        Navigator.pop(context, true);
                      } catch (e) {
                        print('Error updating task: $e');
                      }
                    },
                    child: const Icon(Icons.check),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _addSubtaskField() {
    setState(() {
      _subtaskControllers.add(TextEditingController());
    });
  }

  void _removeSubtaskField(int index) {
    setState(() {
      _subtaskControllers[index].dispose();
      _subtaskControllers.removeAt(index);
    });
  }
}
