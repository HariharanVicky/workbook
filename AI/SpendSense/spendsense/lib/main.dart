import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'providers/expense_provider.dart';
import 'providers/category_provider.dart';
import 'providers/settings_provider.dart';
import 'services/database_service.dart';
import 'screens/home_screen.dart';
import 'screens/expense_list_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/categories_screen.dart';
import 'screens/pin_entry_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final databaseService = DatabaseService();
  
  // Initialize database
  await databaseService.database;
  
  runApp(MyApp(
    prefs: prefs,
    databaseService: databaseService,
  ));
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  final DatabaseService databaseService;

  const MyApp({
    Key? key,
    required this.prefs,
    required this.databaseService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ExpenseProvider(databaseService)..loadExpenses(),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoryProvider(databaseService)..loadCategories(),
        ),
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(prefs),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return MaterialApp(
            title: 'SpendSense',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
              useMaterial3: true,
            ),
            darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.blue,
                brightness: Brightness.dark,
              ),
            ),
            themeMode: settingsProvider.themeMode,
            home: settingsProvider.shouldShowPinScreen() 
                ? const PinEntryScreen() 
                : const MainScreen(),
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int _selectedIndex = 0;
  bool _isAppPaused = false;

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExpenseListScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    switch (state) {
      case AppLifecycleState.paused:
        _isAppPaused = true;
        // Clear unlock time when app is paused for maximum security
        context.read<SettingsProvider>().clearUnlockTime();
        break;
      case AppLifecycleState.resumed:
        if (_isAppPaused) {
          _checkPinOnResume();
        }
        _isAppPaused = false;
        break;
      default:
        break;
    }
  }

  void _checkPinOnResume() {
    final settingsProvider = context.read<SettingsProvider>();
    if (settingsProvider.shouldRequirePinOnResume()) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const PinEntryScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.list),
            label: 'Expenses',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
