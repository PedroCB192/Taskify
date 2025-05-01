import 'package:flutter/material.dart';
import 'package:taskify/core/constants/app_colors.dart';
import 'package:taskify/core/constants/default_colors.dart';
import 'package:taskify/features/categories/services/category_service.dart';
import 'package:taskify/features/categories/models/category.dart';
import 'package:taskify/features/tasks/models/task.dart';
import 'package:taskify/features/tasks/models/subtask.dart';
import 'package:taskify/features/tasks/services/task_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:audioplayers/audioplayers.dart';

class TasksCreateModal extends StatefulWidget {
  const TasksCreateModal({super.key});

  @override
  State<TasksCreateModal> createState() => _TasksCreateModalState();
}

class _TasksCreateModalState extends State<TasksCreateModal> {
  final List<TextEditingController> _subtaskControllers = [];
  List<Category> categories = [];
  String? selectedCategory;
  final TextEditingController categoryController = TextEditingController();
  DateTime? _selectedDate; // Nullable to handle no selection
  final TextEditingController _taskNameController = TextEditingController();
  final CategoryService _categoryService = CategoryService();
  Color selectedColor = DefaultColors.availableColors.first; // Default color

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Default to current date
    _loadCategories(); // Load categories on initialization
  }

  Future<void> _loadCategories() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final loadedCategories = await _categoryService.getAllCategories();

      setState(() {
        // Ensure "No Category" is the first category
        categories =
            loadedCategories..sort((a, b) {
              if (a.name == 'No Category') return -1;
              if (b.name == 'No Category') return 1;
              return 0;
            });

        // Automatically select the first category
        selectedCategory = categories.isNotEmpty ? categories.first.id : null;
      });
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
                      controller: categoryController,
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
                                  selectedColor = color;
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
                                        selectedColor == color
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
                      final newCategoryName = categoryController.text.trim();
                      if (newCategoryName.isNotEmpty &&
                          !categories.any(
                            (cat) => cat.name == newCategoryName,
                          )) {
                        try {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null)
                            throw Exception('User not authenticated');

                          final newCategory = Category(
                            id:
                                DateTime.now().millisecondsSinceEpoch
                                    .toString(),
                            name: newCategoryName,
                            userId: user.uid,
                            color:
                                selectedColor.value, // Save color as ARGB int
                          );

                          await _categoryService.addCategory(newCategory);

                          // Update the list of categories and select the new one
                          setState(() {
                            categories.add(newCategory); // Add to local list
                            selectedCategory =
                                newCategory.id; // Select new category
                          });

                          // Update the dropdown value
                          if (mounted) {
                            this.setState(() {
                              selectedCategory = newCategory.id;
                            });
                          }
                        } catch (e) {
                          print('Error adding category: $e');
                        }
                      }
                      categoryController.clear();
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
    // Dispose of all subtask controllers
    for (var controller in _subtaskControllers) {
      controller.dispose();
    }
    // Dispose of the category controller
    categoryController.dispose();
    // Dispose of the task name controller
    _taskNameController.dispose();
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Title
            Text(
              'New Task',
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
                          icon: Icon(
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
            const SizedBox(height: 10),
            // Category, Date, Subtask, and Create Buttons
            Row(
              children: [
                // Category Dropdown
                Expanded(
                  flex: 4,
                  child: DropdownButtonFormField<String>(
                    value: selectedCategory,
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
                          selectedCategory = value;
                        });
                      }
                    },
                    items: [
                      ...categories.map((cat) {
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
                const SizedBox(width: 10),
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
                    onPressed: () => _addSubtaskField(),
                    child: const Icon(Icons.subject),
                  ),
                ),
                const SizedBox(width: 10),
                // Create Task Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        // Reproducir el sonido "pop-on"
                        final player = AudioPlayer();
                        await player.play(AssetSource('sounds/pop-on.mp3'));

                        final user = FirebaseAuth.instance.currentUser;
                        if (user == null)
                          throw Exception('User not authenticated');

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

                        // Asignar categoría predeterminada si no se selecciona ninguna
                        final categoryId =
                            (selectedCategory == 'New Category' ||
                                    selectedCategory == null)
                                ? 'default' // ID para "No Category"
                                : selectedCategory!;

                        // Crear la tarea
                        final newTask = Task(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          name: _taskNameController.text.trim(),
                          date: _selectedDate ?? DateTime.now(),
                          time: null,
                          subtasks: subtasks,
                          categoryId: categoryId,
                          completed: false,
                          isSynced: false,
                          userId: user.uid,
                        );

                        // Guardar la tarea
                        await TaskService().addTask(newTask);

                        // Notificar el cambio
                        Navigator.pop(
                          context,
                          true,
                        ); // Cerrar el modal y devolver true
                      } catch (e) {
                        print('Error saving task: $e');
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
