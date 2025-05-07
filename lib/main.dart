import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:game_2048/register_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

import 'about_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseDatabase database = FirebaseDatabase.instance;

  Locale _locale = const Locale('kk'); // Default to Kazakh
  ThemeMode _themeMode = ThemeMode.system;

  @override
  void initState() {
    super.initState();
    _loadCachedSettings();
  }

  Future<void> _loadCachedSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString('language') ?? 'kk';
    final theme = prefs.getString('theme') ?? 'system';

    setState(() {
      _locale = Locale(lang);
      _themeMode = theme == 'dark'
          ? ThemeMode.dark
          : theme == 'light'
              ? ThemeMode.light
              : ThemeMode.system;
    });
  }

  void _setLocale(Locale newLocale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLocale.languageCode);
    setState(() {
      _locale = newLocale;
    });
  }

  void _setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme',
        mode == ThemeMode.dark ? 'dark' : mode == ThemeMode.light ? 'light' : 'system');
    setState(() {
      _themeMode = mode;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '2048 Puzzle',
      debugShowCheckedModeBanner: false,
      locale: _locale,
      themeMode: _themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      supportedLocales: const [
        Locale('en'),
        Locale('ru'),
        Locale('kk'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (locale, supportedLocales) {
        if (locale == null) return const Locale('kk');
        for (var supported in supportedLocales) {
          if (supported.languageCode == locale.languageCode) {
            return supported;
          }
        }
        return const Locale('kk');
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return MainScreen(
              setLocale: _setLocale,
              setThemeMode: _setThemeMode,
            );
          } else {
            // Reset to default
            _setLocale(const Locale('kk'));
            _setThemeMode(ThemeMode.system);
            return const LoginPage();
          }
        },
      ),

      routes: {
        '/settings': (context) => SettingsPage(
              setLocale: _setLocale,
              setThemeMode: _setThemeMode,
              currentThemeMode: Theme.of(context).brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
              currentLocale: Localizations.localeOf(context),
            ),
        '/register': (context) => const RegisterPage(),
        '/login': (context) => const LoginPage(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final void Function(Locale) setLocale;
  final void Function(ThemeMode) setThemeMode;

  const MainScreen({
    super.key,
    required this.setLocale,
    required this.setThemeMode,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(setLocale: widget.setLocale),
      const AboutPage(),
      SettingsPage(
      setLocale: widget.setLocale,
      setThemeMode: widget.setThemeMode,
      currentThemeMode: Theme.of(context).brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      currentLocale: Localizations.localeOf(context),
    ),

    ];
    _loadUserSettings(); // Fetch settings on load
  }

  Future<void> _loadUserSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();
        final lang = data?['language'] ?? 'kk';
        final theme = data?['theme'] ?? 'system';

        widget.setLocale(Locale(lang));
        widget.setThemeMode(
          theme == 'dark'
              ? ThemeMode.dark
              : theme == 'light'
                  ? ThemeMode.light
                  : ThemeMode.system,
        );
      }
    }
  }

  void _onItemTapped(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: t.homeTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.info),
            label: t.aboutTitle,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: t.settings,
          ),
        ],
      ),
    );
  }
}
