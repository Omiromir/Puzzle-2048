import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'game/grid_properties.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final List<Map<String, dynamic>> sampleScores = [
      {'name': 'Alice', 'score': 2048},
      {'name': 'Bob', 'score': 1720},
      {'name': 'Charlie', 'score': 1616},
      {'name': 'Diana', 'score': 1536},
      {'name': 'Ethan', 'score': 1450},
      {'name': 'Fiona', 'score': 1320},
    ];

    return Scaffold(
      backgroundColor: tan,
      appBar: AppBar(
        backgroundColor: tan,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          t.leaderboard,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.brown,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Column(
                children: [
                  const SizedBox(height: 12),
                  _buildHeaderRow(t.name, t.scoreLabel),
                  const Divider(thickness: 1.5),
                  Expanded(
                    child: ListView.builder(
                      itemCount: sampleScores.length,
                      itemBuilder: (context, index) {
                        final player = sampleScores[index];
                        return _buildScoreRow(player['name'], player['score'], index);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(String nameLabel, String scoreLabel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(
              nameLabel,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          Expanded(
            child: Text(
              scoreLabel,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreRow(String name, int score, int index) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: numTileColor[sampleScoreColor(score)],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Text(
            "#${index + 1}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Text(name, style: const TextStyle(fontSize: 16)),
          ),
          Expanded(
            child: Text(
              score.toString(),
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  /// Choose a color based on score value
  int sampleScoreColor(int score) {
    if (score >= 2048) return 2048;
    if (score >= 1024) return 1024;
    if (score >= 512) return 512;
    if (score >= 256) return 256;
    if (score >= 128) return 128;
    if (score >= 64) return 64;
    if (score >= 32) return 32;
    if (score >= 16) return 16;
    return 2;
  }
}
