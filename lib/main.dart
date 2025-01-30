import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tapps/config/firebase_config.dart';
import 'package:tapps/constants/app_colors.dart';
import 'package:tapps/screens/home_screen.dart';
import 'package:tapps/screens/pick_location_screen.dart';
import 'package:tapps/screens/provinces_screen.dart';
import 'package:tapps/screens/report_screen.dart';
import 'package:tapps/screens/search_screen.dart';
import 'package:tapps/screens/weather_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set status bar color and style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.black,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  // Initialize Firebase for web with optimized settings
  if (kIsWeb) {
    try {
      await Firebase.initializeApp(
        options: FirebaseConfig.webOptions,
      );

      // Configure Firestore settings with optimized cache
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: 10485760, // 10 MB cache limit
        sslEnabled: true,
        ignoreUndefinedProperties: true,
      );

      // Enable Firestore offline persistence with size limit
      await FirebaseFirestore.instance
          .enablePersistence(
        const PersistenceSettings(synchronizeTabs: true),
      )
          .catchError((e) {
        debugPrint('⚠️ Persistence initialization warning: $e');
      });

      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Firebase: $e');
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to initialize app',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your internet connection and try again.\nError: ${e.toString()}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Reload the app
                      main();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      return;
    }
  } else {
    try {
      await Firebase.initializeApp();  // Use default options for mobile
      debugPrint('✅ Firebase initialized successfully');
    } catch (e) {
      debugPrint('❌ Failed to initialize Firebase: $e');
      runApp(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to initialize app',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your internet connection and try again.\nError: ${e.toString()}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Reload the app
                      main();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      return;
    }
  }

  runApp(const ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tapps',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: AppColors.background,
        platform: kIsWeb ? TargetPlatform.android : Theme.of(context).platform,
      ),
      routes: {
        '/': (context) => const MainScreen(),
        '/search': (context) => const SearchScreen(),
        '/pick_location': (context) => const PickLocationScreen(),
      },
      initialRoute: '/',
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _screens = [
    const HomeScreen(),
    WeatherScreen(),
    const ProvincesScreen(),
    const ReportScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: Container(
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.only(top: 8, bottom: 8),
        color: AppColors.primaryBlue,
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 28),
              activeIcon: Icon(Icons.home, size: 28),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.wb_sunny_outlined, size: 28),
              activeIcon: Icon(Icons.wb_sunny, size: 28),
              label: 'Weather',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.location_on_outlined, size: 28),
              activeIcon: Icon(Icons.location_on, size: 28),
              label: 'Provinces',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.report_outlined, size: 28),
              activeIcon: Icon(Icons.report, size: 28),
              label: 'Report',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.5),
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.primaryBlue,
          elevation: 0,
          iconSize: 28,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
