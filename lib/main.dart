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

  // Start Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Start Hive
  await Hive.initFlutter();

  // Hive adapters
  Hive.registerAdapter(TaskAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(SubtaskAdapter());
  Hive.registerAdapter(local.UserAdapter());

  // Open Hive boxes
  await Hive.openBox<Task>('tasks');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<local.User>('userBox');

  // Save user data to Hive
  await initializeUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(
          create: (_) => UserProvider()..loadUser(), // get user data from Hive
        ),
      ],
      child: const MainApp(),
    ),
  );
}

Future<void> initializeUser() async {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UserService _userService = UserService();

  // Verify if the user is logged in
  final firebaseUser = _auth.currentUser;

  if (firebaseUser != null) {
    try {
      // Get user data from Firestore
      final userDoc =
          await _firestore.collection('users').doc(firebaseUser.uid).get();
      final userData = userDoc.data();

      if (userData != null) {
        // Create a local user model
        final local.User user = local.User(
          id: firebaseUser.uid,
          name: userData['name'],
          isPremium: userData['isPremium'],
        );

        // Save user data to Hive
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

  // Sync categories
  await categoryService.syncCategories();

  // Synce tasks
  await taskService.syncTasks();
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appLightTheme,
      home:
          const MainLayout(), // Redirigir al MainLayout como pantalla principal
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/tasks': (context) => const MainLayout(), // Ruta para MainLayout
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(_currentIndex),
          style: const TextStyle(fontSize: 30, color: Colors.white),
        ),
        leading: _leading[_currentIndex],
      ),
      body: Column(children: [Expanded(child: _screens[_currentIndex])]),
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

            // Recharge the categories if a new one was created
            if (shouldReload == true) {
              setState(() {});
            }
          } else {
            // Open the modal to create tasks
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

            // Recharge the tasks if a new one was created
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
            const SizedBox(width: 40), // Space for the FAB
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
