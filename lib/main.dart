import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:taskify/core/constants/app_themes.dart';
import 'package:taskify/features/categories/services/category_service.dart';
import 'package:taskify/features/profile/models/user.dart' as local;
import 'package:taskify/features/tasks/provider/task_provider.dart';
import 'package:taskify/features/auth/screens/login.dart';
import 'package:taskify/features/auth/screens/register.dart';
import 'package:taskify/features/calendar/screens/calendar_screen.dart';
import 'package:taskify/features/categories/screens/categories_screen.dart';
import 'package:taskify/features/profile/screens/profile_screen.dart';
import 'package:taskify/features/tasks/models/task.dart';
import 'package:taskify/features/categories/models/category.dart';
import 'package:taskify/features/tasks/models/subtask.dart';
import 'package:taskify/features/tasks/screens/tasks_screen.dart';
import 'package:taskify/features/tasks/services/task_service.dart';
import 'package:taskify/features/tasks/widgets/tasks_create_modal.dart';
import 'package:taskify/features/categories/widgets/categories_create_modal.dart';
import 'package:taskify/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taskify/features/profile/services/user_service.dart';
import 'package:taskify/features/profile/provider/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Iniciar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Iniciar Hive
  await Hive.initFlutter();

  // Registrar adaptadores de Hive
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(SubtaskAdapter());
  Hive.registerAdapter(
    local.UserAdapter(),
  ); // Registrar el adaptador para el modelo User

  // Abrir cajas de Hive
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<local.User>('userBox'); // Abrir la caja para el usuario

  // Guardar el usuario al abrir la app
  await initializeUser();
  await initializeAppData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider(),
        ), // Agregar UserProvider
      ],
      child: const MainApp(),
    ),
  );
}

Future<void> initializeUser() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  // Verificar si hay un usuario autenticado
  final firebaseUser = _auth.currentUser;

  if (firebaseUser != null) {
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

        print('User saved locally: ${user.name}, Premium: ${user.isPremium}');
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  } else {
    print('No authenticated user found');
  }
}

Future<void> initializeAppData() async {
  final categoryService = CategoryService();
  final taskService = TaskService();

  // Sincronizar categorías
  await categoryService.syncCategories();

  // Sincronizar tareas
  await taskService.syncTasks();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appLightTheme,
      home: const MainLayout(),
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/tasks': (context) => const TasksScreen(),
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
    TasksScreen(),
    CategoriesScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

  final List _leading = [null, null, null, null];

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = Provider.of<UserProvider>(context).isPremium;
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(_currentIndex),
          style: const TextStyle(fontSize: 30, color: Colors.white),
        ),
        leading: _leading[_currentIndex],
      ),
      body: Column(
        children: [
          if (user != null) // Verificar que el usuario no sea nulo
            Container(
              color: isPremium ? Colors.green : Colors.red,
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium
                        ? 'You are a Premium User!'
                        : 'You are not a Premium User.',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'User Name: ${user.name}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                  Text(
                    'User ID: ${user.id}',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ),
          Expanded(child: _screens[_currentIndex]),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_currentIndex == 1) {
            // Abrir el modal para crear categorías
            final shouldReload = await showModalBottomSheet<bool>(
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
                    child: const CategoriesCreateModal(),
                  ),
                );
              },
            );

            // Recargar las categorías si se creó una nueva
            if (shouldReload == true) {
              setState(() {}); // Recargar la pantalla de categorías
            }
          } else {
            // Abrir el modal para crear tareas
            final shouldReload = await showModalBottomSheet<bool>(
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
                    child: const TasksCreateModal(),
                  ),
                );
              },
            );

            // Recargar las tareas si se creó una nueva
            if (shouldReload == true) {
              Provider.of<TaskProvider>(context, listen: false).loadTasks();
            }
          }
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
        return 'Profile';
      default:
        return 'Taskify';
    }
  }
}
