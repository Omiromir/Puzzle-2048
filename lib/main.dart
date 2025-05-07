import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:game_2048/register_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import 'about_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'settings_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final settings = SettingsController();
  await settings.loadFromPrefs();

  runApp(
    ChangeNotifierProvider.value(
      value: settings,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);

    return MaterialApp(
      title: '2048 Puzzle',
      debugShowCheckedModeBanner: false,
      locale: settings.locale,
      themeMode: settings.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(),
      supportedLocales: const [Locale('en'), Locale('ru'), Locale('kk')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: AuthGate(
        setLocale: settings.updateLocale,
        setThemeMode: settings.updateTheme,
      ),
      routes: {
        '/settings': (_) => SettingsPage(
          setLocale: settings.updateLocale,
          setThemeMode: settings.updateTheme,
          currentLocale: settings.locale,
          currentThemeMode: settings.themeMode,
        ),
      },
    );
  }

  Future<SettingsController> _loadSettings() async {
    final settingsController = SettingsController();
    await settingsController.loadFromPrefs();
    return settingsController;
  }
}

class AuthGate extends StatefulWidget {
  final void Function(Locale) setLocale;
  final void Function(ThemeMode) setThemeMode;

  const AuthGate({
    super.key,
    required this.setLocale,
    required this.setThemeMode,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool showLogin = true;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          return FutureBuilder(
            future: _fetchUserPreferences(), // Wait for preferences
            builder: (context, settingsSnapshot) {
              if (settingsSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(body: Center(child: CircularProgressIndicator()));
              }
              return MainScreen(
                setLocale: widget.setLocale,
                setThemeMode: widget.setThemeMode,
              );
            },
          );
        }


        return showLogin
            ? LoginPage(
                onSwitchToRegister: () => setState(() => showLogin = false))
            : RegisterPage(
                onSwitchToLogin: () => setState(() => showLogin = true));
      },
    );
  }

  Future<void> _fetchUserPreferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      final docSnapshot = await userDoc.get();

      if (docSnapshot.exists) {
        final userData = docSnapshot.data()!;
        final String languageCode = userData['language'] ?? 'kk';
        final String themeMode = userData['theme'] ?? 'system';

        // Update settings controller with fetched data
        final settingsController =
            Provider.of<SettingsController>(context, listen: false);
        settingsController.updateLocale(Locale(languageCode));
        settingsController.updateTheme(_getThemeModeFromString(themeMode));
      }
    }
  }

  ThemeMode _getThemeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
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
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: [
          HomePage(setLocale: widget.setLocale),
          const AboutPage(),
          SettingsPage(
            currentThemeMode: Theme.of(context).brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            currentLocale: Localizations.localeOf(context),
            setLocale: widget.setLocale,
            setThemeMode: widget.setThemeMode,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.info),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class SettingsController extends ChangeNotifier {
  Locale _locale = const Locale('kk');
  ThemeMode _themeMode = ThemeMode.system;

  Locale get locale => _locale;
  ThemeMode get themeMode => _themeMode;

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = Locale(prefs.getString('language') ?? 'kk');
    final theme = prefs.getString('theme') ?? 'system';
    _themeMode = _getThemeModeFromString(theme);
    notifyListeners();
  }

  Future<void> updateLocale(Locale newLocale) async {
    if (_locale == newLocale) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', newLocale.languageCode);
    _locale = newLocale;
    notifyListeners();
    await _updateUserPreferenceInFirestore('language', newLocale.languageCode);
  }

  Future<void> updateTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', _getStringFromThemeMode(mode));
    _themeMode = mode;
    notifyListeners();
    await _updateUserPreferenceInFirestore('theme', _getStringFromThemeMode(mode));
  }


  Future<void> _updateUserPreferenceInFirestore(
      String field, String value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      await userDoc.update({field: value});
    }
  }

  ThemeMode _getThemeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  String _getStringFromThemeMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      default:
        return 'system';
    }
  }
}
