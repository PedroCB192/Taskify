import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:taskify/features/tasks/models/category.dart' as taskify;
import 'package:taskify/features/tasks/services/category_service.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final CategoryService _categoryService = CategoryService();

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
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      return result.user;
    } on FirebaseAuthException catch (e) {
      print(e.message);
      return null;
    }
  }

  // Register with email and password
  Future<User?> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Create the user in Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final User? user = result.user;

      // Save user data in Firestore
      await _firestore.collection('users').doc(user?.uid).set({
        'name': name,
        'email': email.trim(),
        'isPremium': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create the "No Category" category for the new user
      if (user != null) {
        final defaultCategory = taskify.Category(
          id: 'default', // Unique ID for the default category
          name: 'No Category',
          userId: user.uid,
          color: Colors.black.value, // Default color (black)
        );
        await _categoryService.addCategory(
          defaultCategory,
          false,
        ); // Not premium
      }

      return user;
    } catch (e) {
      print('Error registering user: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      print(e.message);
    }
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream to listen for authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
