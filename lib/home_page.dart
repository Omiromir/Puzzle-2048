import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'game_page.dart';
import 'leaderboard_page.dart';
class HomePage extends StatefulWidget {
  final void Function(Locale) setLocale;

  const HomePage({super.key, required this.setLocale});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int? bestScore;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBestScore();
  }

  Future<void> fetchBestScore() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (!mounted) return;
    if (uid == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (!mounted) return;
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        bestScore = data['bestScore'] ?? 0;
        isLoading = false;
      });
    } else {
      setState(() {
        bestScore = 0;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(t.homeTitle)),
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
                          child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                            t.bestScore(bestScore ?? 0),
                            style: const TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Play Button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (_) => const GamePage()));
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                            backgroundColor: Colors.deepPurple,
                          ),
                          child: Text(t.play,
                              style: const TextStyle(fontSize: 22, color: Colors.white)),
                        ),

                        const SizedBox(height: 30),

                        // Grid: New Game & Leaderboard only
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: isWide ? 1.1 : 1.2,
                          ),
                          itemCount: 2,
                          itemBuilder: (context, index) {
                            List<String> labels = [t.newGame, t.leaderboard];
                            List<IconData> icons = [Icons.play_arrow, Icons.emoji_events];
                            List<VoidCallback> actions = [
                                  () => Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(builder: (_) => const GamePage()),
                              ),
                                  () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LeaderboardPage()),
                              ),
                            ];

                            return InkWell(
                              onTap: actions[index],
                              child: Card(
                                color: Colors.teal,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(icons[index], size: 40, color: Colors.white),
                                    const SizedBox(height: 10),
                                    Text(
                                      labels[index],
                                      style: const TextStyle(fontSize: 18, color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
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
