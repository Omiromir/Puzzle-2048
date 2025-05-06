import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:game_2048/register_page.dart';
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

  void _setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  void _setThemeMode(ThemeMode mode) {
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
      // 👇 Listen to the user's auth state
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
            return const LoginPage();
          }
        },
      ),
      routes: {
        '/settings': (context) => SettingsPage(
          setLocale: _setLocale,
          setThemeMode: _setThemeMode,
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
      ),
    ];
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
            icon: const Icon(Icons.
            info),
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
