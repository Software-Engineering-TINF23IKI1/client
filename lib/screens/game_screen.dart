import 'package:flutter/material.dart';
import 'package:bbc_client/tcp/tcp_client.dart';

// 1. Define a simple data model for one leaderboard entry.
//    You can replace this with your real model from AppContext.
class LeaderboardEntry {
  final String playerName;
  final int score;

  LeaderboardEntry({required this.playerName, required this.score});
}

// 2. The standalone LeaderboardWidget.
//    Later you’ll grab your list via Provider/AppContext inside here.
class LeaderboardWidget extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const LeaderboardWidget({
    Key? key,
    required this.entries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return ListTile(
          leading: CircleAvatar(child: Text('${index + 1}')),
          title: Text(entry.playerName),
          trailing: Text('${entry.score} pts'),
        );
      },
    );
  }
}

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = List.generate(
      40,
      (i) => LeaderboardEntry(
        playerName: 'Player ${i + 1}',
        score: (10 - i) * 1000,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Row(
              children: [
                // LEFT SIDE: flex of 3 (three-quarters if right is 1)
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      // shrink to fit its children (so the button doesn't get pushed off)
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Bananas: 12345',
                          style: TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Currency: 99',
                          style: TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            startGame();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40,
                              vertical: 20,
                            ),
                            textStyle: const TextStyle(fontSize: 24),
                          ),
                          child:
                              const Text('🍌', style: TextStyle(fontSize: 70)),
                        ),
                      ],
                    ),
                  ),
                ),

                // RIGHT SIDE: flex of 1 (one-quarter of the width)
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: FractionallySizedBox(
                        heightFactor: 2 / 3,
                        child: LeaderboardWidget(entries: entries),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // EXIT button at bottom-right
            Positioned(
              bottom: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: () {/* … */},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Exit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
