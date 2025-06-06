import 'package:bbc_client/tcp/tcp_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// 1. Define a simple data model for one leaderboard entry.
//    You can replace this with your real model from AppContext.
class LeaderboardEntry {
  final String playerName;
  final int score;

  LeaderboardEntry({required this.playerName, required this.score});
}

// 2. The standalone LeaderboardWidget.
//    Later you’ll grab your list via Provider/AppContext inside here.
class LeaderboardWidget extends StatefulWidget {
  final List<LeaderboardEntry> entries;

  const LeaderboardWidget({
    Key? key,
    required this.entries,
  }) : super(key: key);

  @override
  State<LeaderboardWidget> createState() => _LeaderboardWidgetState();
}

class _LeaderboardWidgetState extends State<LeaderboardWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      itemCount: widget.entries.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, index) {
        final entry = widget.entries[index];
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
                        Consumer<TCPClient>(
                          builder: (context, tcpClient, child) {
                            return Text(
                              'Bananas: ${tcpClient.currency.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 32),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Consumer<TCPClient>(
                          builder: (context, tcpClient, child) {
                            return Text(
                              'Score: ${tcpClient.score.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 32),
                            );
                          },
                        ),
                        const SizedBox(height: 40),
                        ElevatedButton(
                          onPressed: () {
                            //startGame();
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
                        child: Consumer<TCPClient>(
                            builder: (BuildContext context, TCPClient tcpClient,
                                Widget? child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Leaderboard',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  // Use the LeaderboardWidget with dummy data
                                  Expanded(
                                    child: LeaderboardWidget(
                                      entries: tcpClient.topPlayers
                                          .map((player) => LeaderboardEntry(
                                                playerName:
                                                    player['playername'] ??
                                                        'Unknown',
                                                score: player['score'] ?? 0,
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ],
                              );
                            },
                            child: LeaderboardWidget(entries: entries)),
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
                onPressed: () {
                  context.read<TCPClient>().closeConnection().then((_) {
                    Navigator.of(context).pop();
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text(
                  'Exit',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
