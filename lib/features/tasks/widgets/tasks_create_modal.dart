import 'package:flutter/material.dart';
import 'package:taskify/core/constants/app_colors.dart';
import 'package:taskify/core/constants/default_colors.dart';
import 'package:taskify/features/tasks/services/category_service.dart';
import 'package:taskify/features/tasks/models/category.dart';
import 'package:taskify/features/tasks/models/task.dart';
import 'package:taskify/features/tasks/models/subtask.dart';
import 'package:taskify/features/tasks/services/task_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  final bool isPremium = true; // Change based on your app's logic
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

      final loadedCategories = await _categoryService.getAllCategories(
        isPremium,
      );

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

                          await _categoryService.addCategory(
                            newCategory,
                            isPremium,
                          );

                          // Actualizar la lista de categorías y seleccionar la nueva
                          setState(() {
                            categories.add(newCategory); // Add to local list
                            selectedCategory =
                                newCategory.id; // Select new category
                          });

                          // Actualizar el estado principal para reflejar los cambios
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
    for (var controller in _subtaskControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        // Title
        Text(
          'New Task',
          style: TextStyle(fontSize: 25, color: AppColors.roseBonbon),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _taskNameController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Task Name',
          ),
        ),
        SizedBox(height: 10),
        if (_subtaskControllers.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _subtaskControllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _removeSubtaskField(index),
                      icon: Icon(Icons.close, color: AppColors.lavenderFloral),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _subtaskControllers[index],
                        decoration: InputDecoration(
                          labelText: "Subtask ${index + 1}",
                          border: OutlineInputBorder(),
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
              flex: 3,
              child: DropdownButtonFormField<String>(
                value:
                    selectedCategory, // Automatically selects the first category
                hint: const Text('Select Category'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: AppColors.argentinianBlue),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.argentinianBlue,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  filled: true,
                  fillColor: AppColors.backgroundLight,
                ),
                dropdownColor: AppColors.backgroundLight,
                iconEnabledColor: AppColors.argentinianBlue,
                iconDisabledColor: AppColors.textSecondary,
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
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _selectDate(context),
                child: const Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () => _addSubtaskField(),
                child: Icon(Icons.subject),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) throw Exception('User not authenticated');

                    // Get subtasks
                    final subtasks =
                        _subtaskControllers
                            .map(
                              (controller) => Subtask(
                                name: controller.text.trim(),
                                completed: false,
                              ),
                            )
                            .toList();

                    // Assign default category if "New Category" or null
                    final categoryId =
                        (selectedCategory == 'New Category' ||
                                selectedCategory == null)
                            ? 'default' // ID for "No Category"
                            : selectedCategory!;

                    // Create the task
                    final newTask = Task(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      name: _taskNameController.text.trim(),
                      date:
                          _selectedDate ?? DateTime.now(), // Use selected date
                      time: null, // Add logic for time if needed
                      subtasks: subtasks,
                      categoryId: categoryId,
                      completed: false,
                      isSynced: false,
                      userId: user.uid,
                    );

                    // Save the task
                    await TaskService().addTask(newTask, isPremium);

                    // Close the modal and notify the parent to reload tasks
                    Navigator.pop(context, true);
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
