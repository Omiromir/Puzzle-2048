import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:game_2048/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final void Function(Locale) setLocale;
  final void Function(ThemeMode) setThemeMode;
  final ThemeMode currentThemeMode;
  final Locale currentLocale;
  final String? userEmail;

  const SettingsPage({
    super.key,
    required this.setLocale,
    required this.setThemeMode,
    required this.currentThemeMode,
    required this.currentLocale,
    required this.userEmail,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _selectedLanguage;
  late ThemeMode _selectedTheme;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = widget.currentLocale.languageCode;
    _selectedTheme = widget.currentThemeMode;

    // Load user settings from Firestore
    _loadUserSettings();
  }

  // Load user settings from Firestore
  Future<void> _loadUserSettings() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      // Fetch settings from Firestore
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          // Apply saved language and theme if available
          setState(() {
            _selectedLanguage = data['languageCode'] ?? widget.currentLocale.languageCode;
            _selectedTheme = data['themeMode'] == 'dark' ? ThemeMode.dark : ThemeMode.light;
          });
          widget.setLocale(Locale(_selectedLanguage));  // Update locale
          widget.setThemeMode(_selectedTheme);  // Update theme
        }
      }
    }
  }

  // Save the settings to Firestore
  void _saveSettingsToFirestore() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'languageCode': _selectedLanguage,
        'themeMode': _selectedTheme == ThemeMode.dark ? 'dark' : 'light',
      }, SetOptions(merge: true));
    }
  }

  // Language change handler
  void _onLanguageChanged(String? newLang) {
    if (newLang == null || _selectedLanguage == newLang) return;
    setState(() {
      _selectedLanguage = newLang;
    });
    widget.setLocale(Locale(newLang));  // Update locale
    _saveSettingsToFirestore();  // Save language setting
  }

  // Theme change handler
  void _onThemeChanged(ThemeMode? newTheme) {
    if (newTheme == null || _selectedTheme == newTheme) return;
    setState(() {
      _selectedTheme = newTheme;
    });
    widget.setThemeMode(newTheme);  // Update theme mode
    _saveSettingsToFirestore();  // Save theme setting
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    bool isGuest = widget.userEmail == null;

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isGuest) ...[
              // Guest Mode UI
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(child: Text(t.guestModeMessage)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Login Button for Guests
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    // Navigate to LoginPage when the button is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage(onSwitchToRegister: () { })),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: Text("Login"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ] else ...[
              // Logged-in user settings
              Text("Email: ${widget.userEmail}", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
              const SizedBox(height: 24),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(t.language),
                        trailing: DropdownButton<String>(
                          value: _selectedLanguage,
                          onChanged: _onLanguageChanged,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 'en', child: Text('English')),
                            DropdownMenuItem(value: 'ru', child: Text('Русский')),
                            DropdownMenuItem(value: 'kk', child: Text('Қазақша')),
                          ],
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(t.theme),
                        trailing: DropdownButton<ThemeMode>(
                          value: _selectedTheme,
                          onChanged: _onThemeChanged,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                            DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                            DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Logout button
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    await FirebaseAuth.instance.signOut();
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(t.logout),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
