import 'package:flutter/material.dart';
import 'package:taskify/core/constants/app_colors.dart';
import 'package:taskify/core/constants/default_colors.dart';
import 'package:taskify/features/categories/models/category.dart';
import 'package:taskify/features/categories/services/category_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CategoriesCreateModal extends StatefulWidget {
  const CategoriesCreateModal({super.key});

  @override
  State<CategoriesCreateModal> createState() => _CategoriesCreateModalState();
}

class _CategoriesCreateModalState extends State<CategoriesCreateModal> {
  final TextEditingController _categoryNameController = TextEditingController();
  Color _selectedColor = DefaultColors.availableColors.first;
  final CategoryService _categoryService = CategoryService();
  bool _isSaving = false;

  @override
  void dispose() {
    _categoryNameController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final newCategory = Category(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: categoryName,
        userId: user.uid,
        color: _selectedColor.value, // Save color as ARGB int
      );

      await _categoryService.addCategory(newCategory);

      Navigator.pop(context, true); // Close modal and notify success
    } catch (e) {
      print('Error saving category: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.failedToSaveCategory),
        ),
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
              AppLocalizations.of(context)!.newCategory,
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
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveCategory,
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
