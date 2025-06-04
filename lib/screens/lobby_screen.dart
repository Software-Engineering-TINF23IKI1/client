import 'package:bbc_client/tcp/packets.dart';
import 'package:flutter/material.dart';

// 1. Model for one slot
class PlayerSlot {
  final String name;
  final bool isReady;

  PlayerSlot({required this.name, required this.isReady});
}

class PlayerSlotWidget extends StatelessWidget {
  final PlayerSlot player;

  const PlayerSlotWidget({Key? key, required this.player}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54),
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          // Avatar
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person, size: 20),
          ),

          const SizedBox(width: 8),

          // Player name
          Expanded(
            child: Text(
              player.name,
              style: const TextStyle(fontSize: 22),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Ready indicator
          Icon(
            player.isReady ? Icons.check : Icons.close,
            color: player.isReady ? Colors.green : Colors.red,
            size: 30,
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

// 3. The LobbyScreen
class LobbyScreen extends StatelessWidget {
  final String gamecode;
  final List<JsonObject> players;

  const LobbyScreen({
    Key? key,
    required this.gamecode,
    required this.players,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // dummy data
    final List<PlayerSlot> slots = players
        .map((player) => PlayerSlot(
              name: player['playername'] as String,
              isReady: player['is-ready'] as bool,
            ))
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 70),
          child: Column(
            children: [
              // Header
              Text(
                'Lobby Code: $gamecode',
                style:
                    const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 24),

              // 3×3 grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 400,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 3,
                  ),
                  itemCount: slots.length,
                  itemBuilder: (context, index) {
                    return PlayerSlotWidget(player: slots[index]);
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Ready button
              ElevatedButton(
                onPressed: () {}, // later: mark ready
                style: ElevatedButton.styleFrom(
                  side: const BorderSide(width: 2, color: Colors.green),
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                ),
                child: const Text(
                  'Ready',
                  style: TextStyle(fontSize: 30, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  handleReadyClick() {}
}
