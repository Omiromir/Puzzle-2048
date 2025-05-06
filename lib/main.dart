import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_database/firebase_database.dart';

import 'about_page.dart';
import 'home_page.dart';
import 'settings_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  static Locale _locale = const Locale('kk');
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
      routes: {
        '/': (context) => MainScreen(setLocale: _setLocale, setThemeMode: _setThemeMode),
        '/settings': (context) => SettingsPage(
              setLocale: _setLocale,
              setThemeMode: _setThemeMode,
            ),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final void Function(Locale) setLocale;
  final void Function(ThemeMode) setThemeMode;

  const MainScreen({super.key, required this.setLocale, required this.setThemeMode});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  late final List<Widget> _pages;

  @override
  void initState() {
    _pages = [
      HomePage(setLocale: widget.setLocale),
      const AboutPage(),
      SettingsPage(setLocale: widget.setLocale, setThemeMode: widget.setThemeMode),
    ];
    super.initState();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
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
          BottomNavigationBarItem(icon: const Icon(Icons.home), label: t.homeTitle),
          BottomNavigationBarItem(icon: const Icon(Icons.info), label: t.aboutTitle),
          BottomNavigationBarItem(icon: const Icon(Icons.settings), label: t.settings),
        ],
      ),
    );
  }
}
