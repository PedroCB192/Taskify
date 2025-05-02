import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskify/features/categories/models/category.dart' as taskify;
import 'package:taskify/features/categories/services/category_service.dart';
import 'package:taskify/features/profile/models/user.dart' as local;
import 'package:taskify/features/profile/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final CategoryService _categoryService = CategoryService();
  final UserService _userService = UserService(); // Instancia de UserService

  // Constructor to initialize persistence
  AuthService()
    : _auth = FirebaseAuth.instance,
      _firestore = FirebaseFirestore.instance {
    _initPersistence(); // Configure persistence
  }

  Future<void> _initPersistence() async {
    if (kIsWeb) {
      // Configure persistence only for web
      await _auth.setPersistence(Persistence.LOCAL);
    }
    // On mobile (Android/iOS), persistence is automatic
  }

  // Sign in with email and password
  Future<User?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      // Guardar el usuario localmente
      await _saveUserLocally(userCredential.user);

      return userCredential.user;
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );

      final user = userCredential.user;

      if (user != null) {
        // Guardar el usuario en Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': name,
          'email': email.trim(),
          'isPremium': false, // Por defecto, el usuario no es premium
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Crear la categoría "No Category" para el nuevo usuario
        final defaultCategory = taskify.Category(
          id: 'default', // ID único para la categoría predeterminada
          name: 'No Category',
          userId: user.uid,
          color: Colors.black.value, // Color predeterminado (negro)
        );
        await _categoryService.addCategory(defaultCategory); // No premium

        // Guardar el usuario localmente
        await _saveUserLocally(user);
      }

      return user;
    } catch (e) {
      debugPrint('Error registering: $e');
      rethrow;
    }
  }

  // Guardar el usuario localmente en Hive
  Future<void> _saveUserLocally(User? firebaseUser) async {
    if (firebaseUser == null) return;

    try {
      // Obtener los datos del usuario desde Firestore
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      final userData = userDoc.data();

      if (userData != null) {
        // Crear una instancia del modelo User
        final local.User user = local.User(
          id: firebaseUser.uid,
          name: userData['name'],
          isPremium: userData['isPremium'],
        );

        // Guardar el usuario en Hive
        await _userService.saveUser(user);

        debugPrint(
          'User saved locally: ${user.name}, Premium: ${user.isPremium}',
        );
      }
    } catch (e) {
      debugPrint('Error saving user locally: $e');
    }
  }

  // Sing out and remove user locally
  Future<void> signOut() async {
    try {
      // Sing out from Firebase
      await _auth.signOut();

      // Delete user locally
      await _userService.deleteUser();

      debugPrint('User signed out and removed locally');
    } on FirebaseAuthException catch (e) {
      debugPrint('Error signing out: ${e.message}');
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream for auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
