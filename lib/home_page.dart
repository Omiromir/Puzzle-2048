import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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

                // Features Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    List<String> labels = ["New Game", "Leaderboard", "Settings", "How to Play"];
                    List<IconData> icons = [Icons.play_arrow, Icons.emoji_events, Icons.settings, Icons.help];

                    return Card(
                      color: Colors.teal,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icons[index], size: 40, color: Colors.white),
                          const SizedBox(height: 10),
                          Text(labels[index], style: const TextStyle(fontSize: 18, color: Colors.white)),
                        ],
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
  }
}
