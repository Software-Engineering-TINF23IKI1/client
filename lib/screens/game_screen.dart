import 'dart:async';

import 'package:bbc_client/color_palette.dart';
import 'package:bbc_client/tcp/packets.dart';
import 'package:bbc_client/tcp/tcp_client.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbc_client/screens/game_end_screen.dart';
import 'package:bbc_client/shop_entry.dart';
import 'package:bbc_client/widgets/exit_button.dart';

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
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/game_screen/GameBP.png',
            fit: BoxFit.cover,
          ),
        ),
        Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 0, 4),
                child: Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    height: 50,
                    child: Image.asset(
                      'assets/game_screen/Shop.png',
                      fit: BoxFit.contain,
                    ),
                  ),
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
            const SizedBox(
              height: 32,
            )
          ],
        ),
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
      ignorePointer: true,
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
      ignorePointer: true,
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

class GameScreen extends StatefulWidget with RouteAware {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late StreamSubscription _packetSubscription;
  @override
  void initState() {
    super.initState();
    attachPacketListener();
  }

  void attachPacketListener() {
    final client = context.read<TCPClient>();
    _packetSubscription = client.packetStream.listen((packet) {
      if (packet is EndRoutinePacket) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => EndRoutineScreen(
                finalScore: packet.score,
                isWinner: packet.isWinner,
                scoreboard: (packet.scoreboard).cast<JsonObject>()),
          ),
        );
        _packetSubscription.cancel();
      }
    });
  }

  @override
  void dispose() {
    _packetSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox.expand(
              child: Image.asset(
                'assets/game_screen/GameBG.png',
                fit: BoxFit.cover,
              ),
            ),
            Row(
              children: [
                // Left side: Shop
                const Expanded(flex: 2, child: ShopWidget()),

                Container(
                  width: 8,
                  color: Colors.black,
                ),
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
                              style: const TextStyle(
                                  fontSize: 50, color: ColorPalette.yellow1),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        Consumer<TCPClient>(
                          builder: (context, tcpClient, child) {
                            return Text(
                              'Score: ${tcpClient.score.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 38, color: ColorPalette.light),
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
                              const Text('🍌', style: TextStyle(fontSize: 80)),
                        ),
                        const SizedBox(height: 40),
                        Consumer<TCPClient>(
                          builder: (context, tcpClient, child) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Click modifier: x${tcpClient.clickModifier}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20, color: ColorPalette.light),
                                ),
                                SizedBox(width: 20), // spacing between texts
                                Text(
                                  'Passive gain: ${tcpClient.passiveGain}',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      fontSize: 20, color: ColorPalette.light),
                                ),
                              ],
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),

                // Right side: Leaderboard

                Container(
                  width: 8,
                  color: Colors.black,
                ),

                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/game_screen/GameBT.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: FractionallySizedBox(
                          heightFactor: 2 / 3,
                          widthFactor: 0.9,
                          child: Consumer<TCPClient>(
                            builder: (BuildContext context, TCPClient tcpClient,
                                Widget? child) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Align(
                                    alignment: Alignment.center,
                                    child: SizedBox(
                                      height: 70,
                                      width: 200, // breathing room
                                      child: Image.asset(
                                        'assets/game_screen/LeaderBoard.png',
                                        fit: BoxFit.contain,
                                      ),
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
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),

            // EXIT button at bottom-right
            Positioned(
              bottom: 16,
              right: 16,
              child: ComicButton(
                onPressed: () {
                  context.read<TCPClient>().closeConnection().then((_) {
                    Navigator.of(context).pop();
                  });
                },
                label: 'Exit Game',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
