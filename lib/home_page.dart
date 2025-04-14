import 'package:flutter/material.dart';
import 'package:game_2048/main.dart';
import 'about_page.dart';
import 'game_page.dart';
import 'settings_page.dart';
import 'leaderboard_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  final void Function(Locale) setLocale;

  const HomePage({super.key, required this.setLocale});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {// default language

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    Locale selectedLang=Localizations.localeOf(context);
    return Scaffold(
      appBar: AppBar(title:  Text(t.homeTitle)),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 600;

            return SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // 🌐 Language Selector Dropdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text("${t.language}:"),
                            DropdownButton<String>(
                              value: selectedLang.toString(),
                              items: const [
                                DropdownMenuItem(value: 'en', child: Text("English")),
                                DropdownMenuItem(value: 'ru', child: Text("Русский")),
                                DropdownMenuItem(value: 'kk', child: Text("Қазақша")),
                              ],
                              onChanged: (lang) {
                                if (lang != null) {
                                  setState(() {
                                    selectedLang = Locale(lang);
                                    widget.setLocale(Locale(lang));
                                  });
                                }
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Game Logo
                        Image.asset('assets/images/2048.png', height: 120),

                        const SizedBox(height: 20),

                        // Score Display
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            t.bestScore(15465),
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Play Button
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: Text(t.play, style: TextStyle(fontSize: 22, color: Colors.white)),
                        ),

                        const SizedBox(height: 30),

                        // Responsive Features Grid
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isWide ? 4 : 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: isWide ? 1.1 : 1.2,
                          ),
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            List<String> labels = [t.newGame, t.leaderboard, t.settings, t.howToPlay];
                            List<IconData> icons = [Icons.play_arrow, Icons.emoji_events, Icons.settings, Icons.help];

                            return InkWell(
                              onTap: () {
                                switch (index) {
                                  case 0:
                                  // Navigate to New Game screen
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(builder: (context) => const NewGamePage()),
                                    );
                                    break;
                                  case 1:
                                  // Navigate to Leaderboard screen
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaderboardPage()));
                                    break;
                                  case 2:
                                  // Navigate to Settings screen
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
                                    break;
                                  case 3:
                                  // Navigate to About screen
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutPage()));
                                    break;
                                }
                              },
                              child: Card(
                                color: Colors.teal,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(icons[index], size: 40, color: Colors.white),
                                    const SizedBox(height: 10),
                                    Text(labels[index], style: const TextStyle(fontSize: 18, color: Colors.white,),textAlign: TextAlign.center,),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
