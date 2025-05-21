import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:game_2048/register_page.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';

import 'about_page.dart';
import 'home_page.dart';
import 'login_page.dart';
import 'settings_page.dart';

final internetChecker = CheckInternetConnection();
final connectionNotifier = ConnectionStatusValueNotifier();


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final settings = SettingsController();
  await settings.loadFromPrefs();
  syncScoreIfConnected();

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
          userEmail: FirebaseAuth.instance.currentUser?.email,
        ),
        '/main': (context) {
          final settings = Provider.of<SettingsController>(context, listen: false);
          return MainScreen(
            setLocale: settings.updateLocale,
            setThemeMode: settings.updateTheme,
          );
        },


      },
    );
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
    if(connectionNotifier.value!=ConnectionStatus.online) return;
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
        if(mounted) {
          final settingsController =
          Provider.of<SettingsController>(context, listen: false);

          settingsController.updateLocale(Locale(languageCode));
          settingsController.updateTheme(_getThemeModeFromString(themeMode));
        }
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
          HomePage(setLocale: widget.setLocale, bestScore: 15432,),
          const AboutPage(),
          SettingsPage(
            currentThemeMode: Theme.of(context).brightness == Brightness.dark
                ? ThemeMode.dark
                : ThemeMode.light,
            currentLocale: Localizations.localeOf(context),
            setLocale: widget.setLocale,
            setThemeMode: widget.setThemeMode,
            userEmail: FirebaseAuth.instance.currentUser?.email,
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
    await _updateUserPreferenceInFirestore('languageCode', newLocale.languageCode);
  }

  Future<void> updateTheme(ThemeMode mode) async {
    if (_themeMode == mode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme', _getStringFromThemeMode(mode));
    _themeMode = mode;
    notifyListeners();
    await _updateUserPreferenceInFirestore('themeMode', _getStringFromThemeMode(mode));
  }

  Future<void> _updateUserPreferenceInFirestore(
      String field, String value) async {
    if(connectionNotifier.value!=ConnectionStatus.online) return;
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
enum ConnectionStatus {
  online,
  offline,
}
class CheckInternetConnection {
  final Connectivity _connectivity = Connectivity();

  // Default will be online. This controller will help to emit new states when the connection changes.
  final _controller = BehaviorSubject.seeded(ConnectionStatus.online);
  StreamSubscription? _connectionSubscription;

  CheckInternetConnection() {
    _checkInternetConnection();
  }

  // The [ConnectionStatusValueNotifier] will subscribe to this
  // stream and every time the connection status changes it
  // will update its value
  Stream<ConnectionStatus> internetStatus() {
    _connectionSubscription ??= _connectivity.onConnectivityChanged
        .listen((_) => _checkInternetConnection());
    return _controller.stream;
  }

  // Code from StackOverflow
  Future<void> _checkInternetConnection() async {
    try {
      // Sometimes, after we connect to a network, this function will
      // be called but the device still does not have an internet connection.
      // This 3 seconds delay will give some time to the device to
      // connect to the internet in order to avoid false-positives
      await Future.delayed(const Duration(seconds: 3));
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        _controller.sink.add(ConnectionStatus.online);
      } else {
        _controller.sink.add(ConnectionStatus.offline);
      }
    } on SocketException catch (_) {
      _controller.sink.add(ConnectionStatus.offline);
    }
  }

  Future<void> close() async {
    // Cancel subscription and close controller
    await _connectionSubscription?.cancel();
    await _controller.close();
  }
}
class ConnectionStatusValueNotifier extends ValueNotifier<ConnectionStatus> {
  // Will keep a subscription to
  // the class [CheckInternetConnection]
  late StreamSubscription _connectionSubscription;

  ConnectionStatusValueNotifier() : super(ConnectionStatus.online) {
    // Everytime there a new connection status is emitted
    // we will update the [value]. This will make the widget
    // to rebuild
    _connectionSubscription = internetChecker
        .internetStatus()
        .listen((newStatus) => value = newStatus);
  }

  @override
  void dispose() {
    _connectionSubscription.cancel();
    super.dispose();
  }
}
void syncScoreIfConnected() async {
  if (connectionNotifier.value == ConnectionStatus.online) {
    final prefs = await SharedPreferences.getInstance();
    final int? unsyncedScore = prefs.getInt('best_score');
    if (unsyncedScore != null) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc =FirebaseFirestore.instance.collection('users').doc(user.uid);
        try {
          await userDoc.set({'bestScore': unsyncedScore}, SetOptions(merge: true));
        } catch (e) {
          debugPrint("Failed to upload best score: $e");
        }
      }
    }
  }
}
