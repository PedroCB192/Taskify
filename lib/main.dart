import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taskify/core/constants/app_themes.dart';
import 'package:taskify/features/auth/datasourse/auth_wrapper.dart';
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
      debugShowCheckedModeBanner: false,
      theme: appLightTheme,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/tasks': (context) => const Tasks(),
      },
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const Tasks(),
    Container(color: Colors.white, child: const Center(child: Text('Ajustes'))) // Pantalla de ajustes (placeholder)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Taskify'),
        centerTitle: true,
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.task),
            label: 'Tareas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}