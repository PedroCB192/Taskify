import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taskify/features/auth/screens/login.dart';
import 'package:taskify/main.dart';

class AuthWrapper extends StatelessWidget {
  final Function(Locale) changeLanguage; // Añade esto

  const AuthWrapper({super.key, required this.changeLanguage});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return const MainLayout(); // Main layout for authenticated users
        }

        return const Login(); // Login screen for unauthenticated users
      },
    );
  }
}
