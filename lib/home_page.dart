import 'package:flutter/material.dart';
import 'about_page.dart';
import 'game_page.dart';
import 'settings_page.dart';
import 'leaderboard_page.dart';

class HomePage extends StatefulWidget {
  final void Function(Locale) setLocale;

  const HomePage({super.key, required this.setLocale});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedLang = 'kk'; // default language

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
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
                            const Text("Language: "),
                            DropdownButton<String>(
                              value: _selectedLang,
                              items: const [
                                DropdownMenuItem(value: 'en', child: Text("English")),
                                DropdownMenuItem(value: 'ru', child: Text("Русский")),
                                DropdownMenuItem(value: 'kk', child: Text("Қазақша")),
                              ],
                              onChanged: (lang) {
                                if (lang != null) {
                                  setState(() {
                                    _selectedLang = lang;
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
                          child: const Text(
                            "Best Score: 20480",
                            style: TextStyle(color: Colors.white, fontSize: 18),
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
                          child: const Text("Play", style: TextStyle(fontSize: 22, color: Colors.white)),
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
                            List<String> labels = ["New Game", "Leaderboard", "Settings", "How to Play"];
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
                                    Text(labels[index], style: const TextStyle(fontSize: 18, color: Colors.white)),
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
