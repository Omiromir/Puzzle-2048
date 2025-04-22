import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  final void Function(Locale) setLocale;
  final void Function(ThemeMode) setThemeMode;

  const SettingsPage({
    super.key,
    required this.setLocale,
    required this.setThemeMode,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedLang = 'kk';
  ThemeMode _themeMode = ThemeMode.system;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.settings)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Language Selector
            Text(t.language, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButton<String>(
              value: _selectedLang,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: 'en', child: Text("English")),
                DropdownMenuItem(value: 'ru', child: Text("Русский")),
                DropdownMenuItem(value: 'kk', child: Text("Қазақша")),
              ],
              onChanged: (lang) {
                if (lang != null) {
                  setState(() {
                    _selectedLang = lang;
                  });
                  widget.setLocale(Locale(lang));
                }
              },
            ),

            const SizedBox(height: 32),

            // Theme Selector
            Text(t.theme, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            DropdownButton<ThemeMode>(
              value: _themeMode,
              isExpanded: true,
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text("System")),
                DropdownMenuItem(value: ThemeMode.light, child: Text("Light")),
                DropdownMenuItem(value: ThemeMode.dark, child: Text("Dark")),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  setState(() {
                    _themeMode = mode;
                  });
                  widget.setThemeMode(mode);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
