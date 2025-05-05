import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:taskify/core/constants/app_colors.dart';
import 'package:taskify/core/constants/default_colors.dart';
import 'package:taskify/features/categories/models/category.dart';
import 'package:taskify/features/categories/services/category_service.dart';
import 'package:taskify/features/tasks/provider/task_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoriesEditModal extends StatefulWidget {
  final Category category;

  const CategoriesEditModal({super.key, required this.category});

  @override
  State<CategoriesEditModal> createState() => _CategoriesEditModalState();
}

class _CategoriesEditModalState extends State<CategoriesEditModal> {
  late TextEditingController _categoryNameController;
  late Color _selectedColor;
  final CategoryService _categoryService = CategoryService();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inicializar los valores con los datos de la categoría
    _categoryNameController = TextEditingController(text: widget.category.name);
    _selectedColor = Color(widget.category.color);
  }

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  Future<void> _updateCategory() async {
    final categoryName = _categoryNameController.text.trim();
    if (categoryName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.categoryNameCannotBeEmpty,
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final updatedCategory = widget.category.copyWith(
        name: categoryName,
        color: _selectedColor.value, // Guardar el color como ARGB int
      );

      await _categoryService.updateCategory(updatedCategory);

      Navigator.pop(context, true); // Cerrar el modal y notificar éxito
    } catch (e) {
      print('Error updating category: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update category')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
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
          children: [
            Text(
              AppLocalizations.of(context)!.editCategory,
              style: TextStyle(fontSize: 25, color: AppColors.roseBonbon),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _categoryNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.categoryName,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context)!.selectAColor),
            const SizedBox(height: 8),
            Wrap(
              spacing: 30,
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
                        width: 50,
                        height: 50,
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
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Cancel Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lavenderFloral,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Icon(Icons.close),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete Button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.lavenderFloral,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: Text(
                                AppLocalizations.of(context)!.deleteCategory,
                              ),
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.allTasksAssociatedWithThisCategoryWillBeDeletedAreYouSureYouWantToProceed,
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: Text(
                                    AppLocalizations.of(context)!.cancel,
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: Text(
                                    AppLocalizations.of(context)!.delete,
                                  ),
                                ),
                              ],
                            ),
                      );

                      if (confirm == true) {
                        try {
                          // Eliminar todas las tareas asociadas a esta categoría
                          final taskProvider = Provider.of<TaskProvider>(
                            context,
                            listen: false,
                          );
                          taskProvider.deleteTasksByCategoryId(
                            widget.category.id,
                          );

                          // Eliminar la categoría
                          await _categoryService.deleteCategory(
                            widget.category.id,
                          );

                          Navigator.pop(
                            context,
                            true,
                          ); // Cerrar el modal y notificar éxito
                        } catch (e) {
                          print('Error deleting category and tasks: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                AppLocalizations.of(
                                  context,
                                )!.failedToDeleteCategoryAndTasks,
                              ),
                            ),
                          );
                        }
                      }
                    },
                    child: const Icon(Icons.delete),
                  ),
                ),
                const SizedBox(width: 8),
                // Update Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _updateCategory,
                    child:
                        _isSaving
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : const Icon(Icons.check),
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
}
