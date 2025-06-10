import 'dart:async';

import 'package:bbc_client/constants.dart';
import 'package:bbc_client/tcp/tcp_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbc_client/shop_entry.dart';

class LeaderboardEntry {
  final String playerName;
  final int score;

  LeaderboardEntry({required this.playerName, required this.score});
}

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

class ShopWidget extends StatelessWidget {
  const ShopWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 0, 4),
            child: Text(
              'Shop',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Expanded(
          child: Consumer<TCPClient>(
            builder: (context, tcp, _) {
              final entries = tcp.shopEntries;
              if (entries.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 100),
                itemCount: entries.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return switch (entry) {
                    SingleEntry e => _SingleCard(entry: e, tcp: tcp),
                    TieredEntry e => _TieredCard(entry: e, tcp: tcp),
                  };
                },
              );
            },
          ),
        ),
        SizedBox(
          height: 32,
        )
      ],
    );
  }
}

class _SingleCard extends StatelessWidget {
  const _SingleCard({required this.entry, required this.tcp});

  final SingleEntry entry;
  final TCPClient tcp;

  @override
  Widget build(BuildContext context) {
    final pending = tcp.isPurchasePending(entry.name, 0);
    final owned = entry.bought;

    // entry.descript with a linebreak every 100 characters
    final tooltipText = entry.description.replaceAllMapped(
      RegExp(r'.{1,60}'),
      (match) => '${match.group(0)}\n',
    );

    return Tooltip(
      message: tooltipText,
      child: Card(
        child: ListTile(
          title: Text(entry.name),
          subtitle: Text(entry.description),
          trailing: ElevatedButton(
            onPressed: (owned || pending || entry.price > tcp.currency)
                ? null
                : () => tcp.buyShopEntry(entry),
            child: Text(
              owned
                  ? 'Owned'
                  : pending
                      ? '⏳'
                      : '${entry.price} 🍌',
            ),
          ),
        ),
      ),
    );
  }
}

class _TieredCard extends StatelessWidget {
  const _TieredCard({required this.entry, required this.tcp});

  final TieredEntry entry;
  final TCPClient tcp;

  @override
  Widget build(BuildContext context) {
    final nextTier = entry.nextTier; // null when maxed
    final maxed = entry.maxed;
    final pendingKey = maxed ? null : entry.name; // key = name#tier
    final pending = pendingKey == null
        ? false
        : tcp.isPurchasePending(entry.name, entry.currentLevel);

    String buttonLabel;
    if (maxed) {
      buttonLabel = 'Maxed';
    } else if (pending) {
      buttonLabel = '⏳';
    } else {
      buttonLabel = '${nextTier!.price} 🍌';
    }

    // entry.descript with a linebreak every 100 characters
    final tooltipText = entry.description.replaceAllMapped(
      RegExp(r'.{1,60}'),
      (match) => '${match.group(0)}\n',
    );

    return Tooltip(
      message: tooltipText,
      child: Card(
        child: ListTile(
          title: Text(entry.name),
          subtitle: Text(
            maxed
                ? 'All tiers purchased'
                : (nextTier!.description.isNotEmpty
                    ? nextTier.description
                    : 'Tier ${entry.currentLevel + 1} of ${entry.tiers.length}'),
          ),
          trailing: ElevatedButton(
            onPressed: (maxed || pending || nextTier!.price > tcp.currency)
                ? null
                : () => tcp.buyShopEntry(entry),
            child: Text(buttonLabel),
          ),
        ),
      ),
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
                // Left side: Shop
                const Expanded(flex: 2, child: ShopWidget()),

                // Center: Game area with score and button
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
                              'Bananas: ${(tcpClient.currency).toStringAsFixed(2)}',
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
                            context.read<TCPClient>().increaseClickBuffer(1);
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

                // Right side: Leaderboard
                Expanded(
                  flex: 2,
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
