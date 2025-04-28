import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taskify/features/categories/models/category.dart';

class CategoryService {
  final Box<Category> _categoryBox = Hive.box<Category>('categories');
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Add a new category to Hive and optionally to Firebase if the user is premium
  Future<void> addCategory(Category category, bool isPremium) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final categoryWithUserId = Category(
      id: category.id,
      name: category.name,
      isSynced: category.isSynced,
      userId: user.uid, // Associate the userId
      color: category.color, // Include color
    );

    // Save to Hive
    await _categoryBox.put(category.id, categoryWithUserId);

    // Save to Firebase if the user is premium
    if (isPremium) {
      await _firestore.collection('categories').doc(category.id).set({
        'name': category.name,
        'isSynced': category.isSynced,
        'userId': user.uid,
        'color': category.color, // Include color in Firestore
        'lastModified': DateTime.now().toIso8601String(),
      });
    }
  }

  // Retrieve all categories from Hive and optionally sync with Firebase if the user is premium
  Future<List<Category>> getAllCategories(bool isPremium) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Filter local categories by userId
    final localCategories =
        _categoryBox.values
            .where((category) => category.userId == user.uid)
            .toList();

    if (!isPremium) {
      // If not premium, return only local categories
      return localCategories;
    }

    // If premium, sync with Firebase
    final remoteCategories =
        await _firestore
            .collection('categories')
            .where('userId', isEqualTo: user.uid) // Filter by userId
            .get();

    for (var remoteCategory in remoteCategories.docs) {
      final localCategory = _categoryBox.get(remoteCategory.id);

      if (localCategory == null ||
          DateTime.parse(
            remoteCategory['lastModified'],
          ).isAfter(DateTime.now())) {
        // Update Hive with Firebase data
        await _categoryBox.put(
          remoteCategory.id,
          Category(
            id: remoteCategory.id,
            name: remoteCategory['name'],
            isSynced: remoteCategory['isSynced'],
            userId: remoteCategory['userId'],
            color: remoteCategory['color'], // Retrieve color from Firestore
          ),
        );
      }
    }

    // Return all updated local categories
    return _categoryBox.values
        .where((category) => category.userId == user.uid)
        .toList();
  }

  // Retrieve a specific category by its ID
  Future<Category?> getCategoryById(String id) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Check in Hive first
    final localCategory = _categoryBox.get(id);
    if (localCategory != null && localCategory.userId == user.uid) {
      return localCategory;
    }

    // If not found in Hive, check in Firestore
    final remoteCategory =
        await _firestore.collection('categories').doc(id).get();
    if (remoteCategory.exists && remoteCategory['userId'] == user.uid) {
      final category = Category(
        id: remoteCategory.id,
        name: remoteCategory['name'],
        isSynced: remoteCategory['isSynced'],
        userId: remoteCategory['userId'],
        color: remoteCategory['color'], // Retrieve color from Firestore
      );

      // Save to Hive for offline access
      await _categoryBox.put(id, category);
      return category;
    }

    return null; // Return null if not found
  }

  // Update an existing category in Hive and optionally in Firebase if the user is premium
  Future<void> updateCategory(Category category, bool isPremium) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    if (category.userId != user.uid) {
      throw Exception('Not authorized to update this category');
    }

    // Update in Hive
    await _categoryBox.put(category.id, category);

    // Update in Firebase if the user is premium
    if (isPremium) {
      await _firestore.collection('categories').doc(category.id).update({
        'name': category.name,
        'isSynced': category.isSynced,
        'userId': user.uid,
        'color': category.color, // Include color in Firestore
        'lastModified': DateTime.now().toIso8601String(),
      });
    }
  }

  // Delete a category from Hive and optionally from Firebase if the user is premium
  Future<void> deleteCategory(String id, bool isPremium) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final category = _categoryBox.get(id);
    if (category == null || category.userId != user.uid) {
      throw Exception('Not authorized to delete this category');
    }

    // Delete from Hive
    await _categoryBox.delete(id);

    // Delete from Firebase if the user is premium
    if (isPremium) {
      await _firestore.collection('categories').doc(id).delete();
    }
  }
}
