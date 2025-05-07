import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  void _onLanguageChanged(String? newLang) {
    if (newLang == null) return;
    setState(() {
      _selectedLanguage = newLang;
    });
    widget.setLocale(Locale(newLang));
  }

  void _onThemeChanged(ThemeMode? newTheme) {
    if (newTheme == null) return;
    setState(() {
      _selectedTheme = newTheme;
    });
    widget.setThemeMode(newTheme);
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
          ],
        ),
      ),
    );
  }
}
