import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taskify/core/constants/app_themes.dart';
import 'package:taskify/features/tasks/provider/task_provider.dart';
import 'package:taskify/features/auth/datasourse/auth_wrapper.dart';
import 'package:taskify/features/auth/screens/login.dart';
import 'package:taskify/features/auth/screens/register.dart';
import 'package:taskify/features/calendar/screens/calendar.dart';
import 'package:taskify/features/categories/screens/categories.dart';
import 'package:taskify/features/profile/screens/profile.dart';
import 'package:taskify/features/tasks/models/task.dart';
import 'package:taskify/features/tasks/models/category.dart';
import 'package:taskify/features/tasks/models/subtask.dart';
import 'package:taskify/features/tasks/screens/tasks.dart';
import 'package:taskify/features/tasks/widgets/tasks_create_modal.dart';
import 'package:taskify/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Inicializar Hive
  await Hive.initFlutter();
  // Limpiar las cajas de Hive (solo para desarrollo)
  /*
  await Hive.deleteBoxFromDisk('tasks');
  await Hive.deleteBoxFromDisk('categories');
  await Hive.deleteBoxFromDisk('subtasks');
  */
  // Registrar adaptadores
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(SubtaskAdapter());

  // Abrir cajas
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Category>('categories');

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TaskProvider())],
      child: const MainApp(),
    ),
  );
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

  final List<Widget> _screens = [Tasks(), Categories(), Calendar(), Profile()];

  final List _leading = [null, null, null, null];

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(_currentIndex),
          style: const TextStyle(fontSize: 30, color: Colors.white),
        ),
        leading: _leading[_currentIndex],
      ),
      body: _screens[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20),
                    ),
                  ),
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.9,
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: TasksCreateModal(),
                    ),
                  ),
                ),
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        notchMargin: 9.0,
        shape: const CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavIcon(0, Icons.task),
            _buildNavIcon(1, Icons.category),
            const SizedBox(width: 40), // Espacio para el FAB
            _buildNavIcon(2, Icons.calendar_today),
            _buildNavIcon(3, Icons.person),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(int index, IconData icon) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () => _onItemTapped(index),
      color:
          _currentIndex == index ? Colors.white : Colors.white.withOpacity(0.6),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Tasks';
      case 1:
        return 'Categories';
      case 2:
        return 'Calendar';
      case 3:
        return 'P';
      default:
        return 'Taskify';
    }
  }
}
