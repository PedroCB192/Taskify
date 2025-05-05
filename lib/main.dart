import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:taskify/core/constants/app_themes.dart';
import 'package:taskify/features/auth/datasourse/auth_wrapper.dart';
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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  // Initialize app data after the first frame
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    await initializeAppData();
  });
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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Locale? _currentLocale;

  @override
  void initState() {
    super.initState();
    _loadSavedLocale();
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocale = prefs.getString('selectedLocale');

    if (savedLocale != null) {
      setState(() {
        _currentLocale = Locale(savedLocale);
      });
      return;
    }

    // If no saved locale, use the system locale
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final supported = AppLocalizations.supportedLocales;

    setState(() {
      final savedLocale = prefs.getString('selectedLocale');
      _currentLocale =
          savedLocale != null
              ? Locale(savedLocale)
              : supported.firstWhere(
                (l) => l.languageCode == systemLocale.languageCode,
                orElse: () => const Locale('en'),
              );
    });
  }

  void _changeLanguage(Locale newLocale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedLocale', newLocale.languageCode);

    setState(() {
      _currentLocale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appLightTheme,
      locale: _currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: AuthWrapper(changeLanguage: _changeLanguage),
      routes: {
        '/login': (context) => const Login(),
        '/register': (context) => const Register(),
        '/main': (context) => const MainLayout(),
      },
    );
  }
}

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _extended = false;
  bool _lastWasWide = false;

  // Controladores de animación
  late AnimationController _railController;
  late AnimationController _navBarController;
  late Animation<double> _railAnimation;
  late Animation<double> _navBarAnimation;
  late AnimationController _fabController;

  final List<Widget> _screens = [
    TasksScreen(),
    CategoriesScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

  final List _leading = [null, null, null, null];

  @override
  void initState() {
    super.initState();

    // Inicializar controladores
    _railController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _navBarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Configurar animaciones
    _railAnimation = CurvedAnimation(
      parent: _railController,
      curve: Curves.easeOutBack,
    );

    _navBarAnimation = CurvedAnimation(
      parent: _navBarController,
      curve: Curves.easeInOut,
    );

    // Set initial state based on screen size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isWide = MediaQuery.of(context).size.width > 600;
      if (isWide) {
        _railController.forward();
        _fabController.forward();
      } else {
        _navBarController.forward();
      }
      _lastWasWide = isWide;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Verify the initial screen size
    _handleLayoutChange(MediaQuery.of(context).size.width);
  }

  void _handleLayoutChange(double width) {
    final isWide = width > 600;

    if (isWide != _lastWasWide) {
      if (isWide) {
        _navBarController.reverse();
        _railController.forward();
        _fabController.forward();
      } else {
        _railController.reverse();
        _navBarController.forward();
        _fabController.reverse();
      }
      _lastWasWide = isWide;
    }
  }

  void _onItemTapped(int index) {
    if (_currentIndex == index) return;
    setState(() {
      _currentIndex = index;
    });
  }

  // Titles for the NavigationRail
  List<String> get _railTitles {
    return [
      AppLocalizations.of(context)!.tasks,
      AppLocalizations.of(context)!.categories,
      AppLocalizations.of(context)!.calendar,
      AppLocalizations.of(context)!.profile,
    ];
  }

  // Icons for the NavigationRail
  List<IconData> get _railIcons {
    return [Icons.task, Icons.category, Icons.calendar_today, Icons.person];
  }

  @override
  void dispose() {
    _railController.dispose();
    _navBarController.dispose();
    _fabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var isWideScreen = true;
    isWideScreen = MediaQuery.of(context).size.width > 600;
    _handleLayoutChange(MediaQuery.of(context).size.width);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(_currentIndex),
          style: const TextStyle(fontSize: 30, color: Colors.white),
        ),
        leading: _leading[_currentIndex],
        actions:
            isWideScreen
                ? [
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _extended ? Icons.chevron_left : Icons.chevron_right,
                        key: ValueKey<bool>(_extended),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _extended = !_extended;
                      });
                    },
                  ),
                ]
                : null,
      ),
      body: isWideScreen ? _buildDesktopLayout() : _buildMobileLayout(),
      floatingActionButton: _buildAnimatedFAB(isWideScreen),
      floatingActionButtonLocation:
          isWideScreen
              ? FloatingActionButtonLocation.endFloat
              : FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar:
          isWideScreen ? null : _buildAnimatedNavBar(isWideScreen),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(-1, 0),
            end: Offset.zero,
          ).animate(_railAnimation),
          child: FadeTransition(
            opacity: _railAnimation,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _extended ? 180 : 72,
              child: NavigationRail(
                selectedIndex: _currentIndex,
                onDestinationSelected: _onItemTapped,
                extended: _extended,
                minExtendedWidth: 180,
                destinations: List.generate(
                  _railIcons.length,
                  (index) => NavigationRailDestination(
                    icon: Icon(_railIcons[index]),
                    label: Text(_railTitles[index]),
                  ),
                ),
              ),
            ),
          ),
        ),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: Container(child: _screens[_currentIndex])),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return Column(children: [Expanded(child: _screens[_currentIndex])]);
  }

  Widget _buildAnimatedFAB(bool isWideScreen) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      right: isWideScreen ? 16 : null,
      bottom: isWideScreen ? 16 : 70,
      left: isWideScreen ? null : MediaQuery.of(context).size.width / 2 - 28,
      child: FloatingActionButton(
        heroTag: 'main_fab',
        onPressed: () async {
          if (_currentIndex == 1) {
            final shouldReload = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder:
                  (context) => Padding(
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
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.9,
                        ),
                        child: const CategoriesCreateModal(),
                      ),
                    ),
                  ),
            );
            if (shouldReload == true) setState(() {});
          } else {
            final shouldReload = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder:
                  (context) => Padding(
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
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.9,
                        ),
                        child: const TasksCreateModal(),
                      ),
                    ),
                  ),
            );
            if (shouldReload == true) {
              Provider.of<TaskProvider>(context, listen: false).loadTasks();
            }
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildAnimatedNavBar(bool isWideScreen) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(_navBarAnimation),
      child: FadeTransition(
        opacity: _navBarAnimation,
        child: BottomAppBar(
          notchMargin: 9.0,
          shape: const CircularNotchedRectangle(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavIcon(0, Icons.task),
              _buildNavIcon(1, Icons.category),
              const SizedBox(width: 40),
              _buildNavIcon(2, Icons.calendar_today),
              _buildNavIcon(3, Icons.person),
            ],
          ),
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
        return AppLocalizations.of(context)!.tasks;
      case 1:
        return AppLocalizations.of(context)!.categories;
      case 2:
        return AppLocalizations.of(context)!.calendar;
      case 3:
        return AppLocalizations.of(context)!.profile;
      default:
        return AppLocalizations.of(context)!.taskify;
    }
  }
}
