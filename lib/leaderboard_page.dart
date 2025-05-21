import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'game/grid_properties.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

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
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('users')
                          .orderBy('bestScore', descending: true)
                          .limit(50)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Center(child: Text(t.noScoresYet));
                        }

                        final currentUid = FirebaseAuth.instance.currentUser?.uid;
                        if (kDebugMode) {
                          print(currentUid);
                        }
                        final scores = snapshot.data!.docs;

                        return ListView.builder(
                          itemCount: scores.length,
                          itemBuilder: (context, index) {
                            final data = scores[index].data() as Map<String, dynamic>;
                            final isCurrentUser = scores[index].id == currentUid;

                            return _buildScoreRow(
                              name: data['name'] ?? 'Unknown',
                              score: data['bestScore'] ?? 0,
                              index: index,
                              highlight: isCurrentUser,
                            );
                          },
                        );
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

  Widget _buildScoreRow({
    required String name,
    required int score,
    required int index,
    required bool highlight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: highlight
            ? Colors.greenAccent.withOpacity(0.3)
            : numTileColor[sampleScoreColor(score)],
        borderRadius: BorderRadius.circular(10),
        border: highlight ? Border.all(color: Colors.green, width: 2) : null,
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
            child: Text(
              name,
              style: const TextStyle(fontSize: 16),
            ),
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
