import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  // Constructor modificado para inicializar la persistencia
  AuthService()
      : _auth = FirebaseAuth.instance,
        _firestore = FirebaseFirestore.instance {
    _initPersistence(); // Configuración de persistencia
  }

  Future<void> _initPersistence() async {
    if (kIsWeb) {
      // Solo configurar persistencia en web
      await _auth.setPersistence(Persistence.LOCAL);
    }
    // En móviles (Android/iOS) la persistencia es automática
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
      UserCredential result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password.trim(),
          );
      // Save user data to Firestore
      await _firestore
          .collection('users')
          .doc(result.user?.uid)
          .set({
            'name': name,
            'email': email.trim(),
            'isPremium': false,
            'createdAt': FieldValue.serverTimestamp(),
          });
      return result.user;
    } catch (e) {
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
  
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}