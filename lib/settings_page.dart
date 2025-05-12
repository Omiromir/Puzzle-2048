import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:game_2048/login_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';

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

  Future<void> _loadUserSettings() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null) {
          final String lang = data['languageCode'] ?? widget.currentLocale.languageCode;
          final String themeStr = data['themeMode'] ?? 'system';

          final ThemeMode theme = switch (themeStr) {
            'dark' => ThemeMode.dark,
            'light' => ThemeMode.light,
            'system' => ThemeMode.system,
            _ => widget.currentThemeMode,
          };

          setState(() {
            _selectedLanguage = lang;
            _selectedTheme = theme;
          });

          // Schedule updates after build
          Future.microtask(() {
            widget.setLocale(Locale(lang));
            widget.setThemeMode(theme);
          });
        }
      }
    }
  }

  Future<void> _saveSettingsToFirestore() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'languageCode': _selectedLanguage,
        'themeMode': switch (_selectedTheme) {
          ThemeMode.dark => 'dark',
          ThemeMode.light => 'light',
          ThemeMode.system => 'system',
        },
      }, SetOptions(merge: true));
    }
  }

  void _onLanguageChanged(String? newLang) {
    if (newLang == null || _selectedLanguage == newLang) return;
    setState(() {
      _selectedLanguage = newLang;
    });
    widget.setLocale(Locale(newLang));
    _saveSettingsToFirestore();
  }

  void _onThemeChanged(ThemeMode? newTheme) {
    if (newTheme == null || _selectedTheme == newTheme) return;
    setState(() {
      _selectedTheme = newTheme;
    });
    widget.setThemeMode(newTheme);
    _saveSettingsToFirestore();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final settingsController = Provider.of<SettingsController>(context, listen: false);
    final isGuest = widget.userEmail == null;

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isGuest) ...[
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
                    Expanded(
                      child: Text(
                        t.guestModeMessage,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),

                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => AuthGate(
                          setLocale: settingsController.updateLocale,
                          setThemeMode: settingsController.updateTheme,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.login),
                  label: Text(t.login),
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
              Text(
                "Email: ${widget.userEmail}",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
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
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();
                    await prefs.setString('language', 'kk');
                    await prefs.setString('theme', 'system');
                    await FirebaseAuth.instance.signOut();

                    settingsController.updateLocale(const Locale('kk'));
                    settingsController.updateTheme(ThemeMode.system);

                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => AuthGate(
                          setLocale: settingsController.updateLocale,
                          setThemeMode: settingsController.updateTheme,
                        ),
                      ),
                    );
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
