import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskify/core/constants/app_colors.dart';

class TasksCreateModal extends StatefulWidget {
  const TasksCreateModal({super.key});

  @override
  State<TasksCreateModal> createState() => _TasksCreateModalState();
}

class _TasksCreateModalState extends State<TasksCreateModal> {
  final List<TextEditingController> _controllers = [];
  List<String> categories = ['No category', 'Work', 'Personal', 'New Category'];
  String? selectedCategory;
  final TextEditingController controller = TextEditingController();
  late DateTime _selectedDate;
  final TextEditingController _taskNameController = TextEditingController();

  void _showAddCategoryDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Agregar nueva categoría'),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Nombre de la categoría',
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newCategory = controller.text.trim();
                  if (newCategory.isNotEmpty &&
                      !categories.contains(newCategory)) {
                    setState(() {
                      categories.insert(categories.length - 1, newCategory);
                      selectedCategory = newCategory;
                    });
                  }
                  controller.clear();
                  Navigator.pop(context);
                },
                child: const Text('Agregar'),
              ),
            ],
          ),
    );
  }

  void _addTextField() {
    setState(() {
      _controllers.add(TextEditingController());
    });
  }

  void _removeTextField(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now(); // Fecha actual por defecto
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
        if (_controllers.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _controllers.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _removeTextField(index),
                      icon: Icon(Icons.close, color: AppColors.lavenderFloral),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controllers[index],
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
        // Menu
        Row(
          children: [
            Expanded(
              flex: 3,
              child: DropdownMenu<String>(
                initialSelection: selectedCategory,
                onSelected: (value) {
                  if (value == 'New Category') {
                    _showAddCategoryDialog();
                  } else {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
                dropdownMenuEntries:
                    categories.map((cat) {
                      return DropdownMenuEntry<String>(value: cat, label: cat);
                    }).toList(),
              ),
            ),
            SizedBox(width: 16),
            // select date
            Expanded(
              child: OutlinedButton(
                onPressed: () async {
                  final DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    helpText: 'Select a date',
                    cancelText: 'Cancel',
                    confirmText: 'Accept',
                  );
                  if (pickedDate != null && pickedDate != _selectedDate) {
                    setState(() {
                      _selectedDate = pickedDate;
                    });
                  }
                },
                child: Icon(Icons.calendar_today),
              ),
            ),
            const SizedBox(width: 16),
            // Select category
            Expanded(
              child: OutlinedButton(
                onPressed: () => _addTextField(),
                child: Icon(Icons.subject),
              ),
            ),
            const SizedBox(width: 16),
            // Create task
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Aquí puedes usar _selectedDate, _taskNameController.text y _taskDescController.text
                  // para crear la tarea
                  print(
                    'Task created: ${_taskNameController.text} - ${DateFormat('dd/MM/yyyy').format(_selectedDate)}',
                  );
                },
                child: Icon(Icons.check),
              ),
            ),
          ],
        ),
        SizedBox(height: 30),
      ],
    );
  }
}
