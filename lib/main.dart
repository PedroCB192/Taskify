import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taskify/core/constants/app_themes.dart';
import 'package:taskify/features/auth/screens/login.dart';
import 'package:taskify/features/auth/screens/register.dart';
import 'package:taskify/features/tasks/screens/tasks.dart';
import 'package:taskify/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: appLightTheme,
      routes: {
        '/home': (context) => const Login(),
        '/register': (context) => const Register(),
        '/tasks': (context) => const Tasks(),
      },
      home: const Login()
    );
  }
}
