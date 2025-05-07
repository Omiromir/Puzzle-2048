import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final void Function(Locale) setLocale;
  final void Function(ThemeMode) setThemeMode;
  final ThemeMode currentThemeMode;
  final Locale currentLocale;

  const SettingsPage({
    super.key,
    required this.setLocale,
    required this.setThemeMode,
    required this.currentThemeMode,
    required this.currentLocale,
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
  }

  // Save the language and theme settings to Firestore
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
    widget.setLocale(Locale(newLang));
    _saveSettingsToFirestore(); // Save language setting
  }

  // Theme change handler
  void _onThemeChanged(ThemeMode? newTheme) {
    if (newTheme == null || _selectedTheme == newTheme) return;
    setState(() {
      _selectedTheme = newTheme;
    });
    widget.setThemeMode(newTheme);
    _saveSettingsToFirestore(); // Save theme setting
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Language Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.language),
                DropdownButton<String>(
                  value: _selectedLanguage,
                  onChanged: _onLanguageChanged,
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(value: 'ru', child: Text('Русский')),
                    DropdownMenuItem(value: 'kk', child: Text('Қазақша')),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Theme Dropdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(t.theme),
                DropdownButton<ThemeMode>(
                  value: _selectedTheme,
                  onChanged: _onThemeChanged,
                  items: const [
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Logout Button
            ElevatedButton.icon(
              onPressed: () async {
                // Clear SharedPreferences on logout
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();

                // Log out from Firebase
                await FirebaseAuth.instance.signOut();
              },
              icon: const Icon(Icons.logout),
              label: Text(t.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
