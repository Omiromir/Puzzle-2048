import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';  // Import localization file

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    var queryData = MediaQuery.of(context);
    final t = AppLocalizations.of(context)!;  // Access localized strings

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(t.aboutTitle),  // Localized title for About page
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 40),

                // Game Logo
                Image.asset('assets/images/2048.png', height: 100),

                const SizedBox(height: 25),

                // Game Instructions
                SizedBox(
                  width: queryData.size.width * 0.95,
                  child: Text(
                    t.aboutText,  // Localized about text
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 30),

                // Developer Credits
                SizedBox(
                  width: queryData.size.width * 0.95,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Text(
                      t.credits,  // Localized credits text
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
