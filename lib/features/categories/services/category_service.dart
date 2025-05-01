import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskify/features/categories/models/category.dart';
import 'package:taskify/features/profile/services/user_service.dart';

class CategoryService {
  final Box<Category> _categoryBox = Hive.box<Category>('categories');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // Obtener si el usuario es premium desde el almacenamiento local
  bool get _isPremium => _userService.getUser()?.isPremium ?? false;

  // Agregar una nueva categoría
  Future<void> addCategory(Category category) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final categoryWithUserId = Category(
      id: category.id,
      name: category.name,
      isSynced: category.isSynced,
      userId: user.uid, // Asociar el userId
      color: category.color, // Incluir el color
    );

    // Guardar en Hive
    await _categoryBox.put(category.id, categoryWithUserId);

    // Guardar en Firebase si el usuario es premium
    if (_isPremium) {
      await _firestore.collection('categories').doc(category.id).set({
        'name': category.name,
        'isSynced': category.isSynced,
        'userId': user.uid,
        'color': category.color, // Incluir el color en Firestore
        'lastModified': DateTime.now().toIso8601String(),
      });
    }
  }

  // Obtener todas las categorías desde Hive
  Future<List<Category>> getAllCategories() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Filtrar categorías locales por userId
    return _categoryBox.values
        .where((category) => category.userId == user.uid)
        .toList();
  }

  // Obtener una categoría específica desde Hive
  Future<Category?> getCategoryById(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Leer desde Hive
    final localCategory = _categoryBox.get(id);
    if (localCategory != null && localCategory.userId == user.uid) {
      return localCategory;
    }

    return null; // No encontrada
  }

  // Actualizar una categoría existente en Hive y opcionalmente en Firebase
  Future<void> updateCategory(Category category) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    if (category.userId != user.uid) {
      throw Exception('Not authorized to update this category');
    }

    // Actualizar en Hive
    await _categoryBox.put(category.id, category);

    // Actualizar en Firebase si el usuario es premium
    if (_isPremium) {
      await _firestore.collection('categories').doc(category.id).update({
        'name': category.name,
        'isSynced': category.isSynced,
        'userId': user.uid,
        'color': category.color, // Incluir el color en Firestore
        'lastModified': DateTime.now().toIso8601String(),
      });
    }
  }

  // Eliminar una categoría de Hive y opcionalmente de Firebase
  Future<void> deleteCategory(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final category = _categoryBox.get(id);
    if (category == null || category.userId != user.uid) {
      throw Exception('Not authorized to delete this category');
    }

    // Eliminar de Hive
    await _categoryBox.delete(id);

    // Eliminar de Firebase si el usuario es premium
    if (_isPremium) {
      await _firestore.collection('categories').doc(id).delete();
    }
  }

  // Sincronizar categorías desde Firebase a Hive
  Future<void> syncCategories() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final remoteCategories =
        await _firestore
            .collection('categories')
            .where('userId', isEqualTo: user.uid)
            .get();

    for (var remoteCategory in remoteCategories.docs) {
      final category = Category(
        id: remoteCategory.id,
        name: remoteCategory['name'],
        isSynced: true,
        userId: remoteCategory['userId'],
        color: remoteCategory['color'],
      );

      // Guardar en Hive
      await _categoryBox.put(remoteCategory.id, category);
    }
  }
}
