import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify/features/categories/models/category.dart';
import 'package:taskify/features/categories/services/category_service.dart';
import 'package:taskify/features/categories/widgets/categories_widget.dart';
import 'package:taskify/features/tasks/provider/task_provider.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final CategoryService _categoryService = CategoryService();
  List<Category> _categories = [];
  Map<String, int> _taskCounts = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Cargar categorías
      final categories = await _categoryService.getAllCategories(true);

      // Obtener tareas desde el TaskProvider
      final tasks = Provider.of<TaskProvider>(context, listen: false).tasks;

      // Calcular la cantidad de tareas por categoría
      final taskCounts = <String, int>{};
      for (var category in categories) {
        taskCounts[category.id] =
            tasks.where((task) => task.categoryId == category.id).length;
      }

      setState(() {
        _categories = categories;
        _taskCounts = taskCounts;
      });
    } catch (e) {
      print('Error loading data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          _categories.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.0,
                    mainAxisSpacing: 16.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final taskCount = _taskCounts[category.id] ?? 0;

                    return CategoriesWidget(
                      category: category,
                      taskCount: taskCount,
                    );
                  },
                ),
              ),
    );
  }
}
