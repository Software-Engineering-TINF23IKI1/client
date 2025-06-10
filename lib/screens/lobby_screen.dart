import 'dart:async';

import 'package:bbc_client/color_palette.dart';
import 'package:bbc_client/screens/game_screen.dart';
import 'package:bbc_client/tcp/packets.dart';
import 'package:bbc_client/tcp/tcp_client.dart';
import 'package:bbc_client/widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbc_client/widgets/exit_button.dart';

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
          border: Border.all(color: Colors.black54, width: 2),
          borderRadius: BorderRadius.circular(4),
          color: ColorPalette.light),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          const SizedBox(
            width: 8,
          ), // breathing room
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
              style: const TextStyle(fontSize: 26),
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Ready indicator
          Icon(
            player.isReady ? Icons.check : Icons.close,
            color: player.isReady ? Colors.green : Colors.red,
            size: 40,
          ),
          const SizedBox(width: 16),
        ],
      ),
    );
  }
}

// 3. The LobbyScreen
class LobbyScreen extends StatefulWidget {
  const LobbyScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> with RouteAware {
  late StreamSubscription _packetSubscription;
  @override
  void initState() {
    super.initState();
    attachPacketListener();
  }

  void attachPacketListener() {
    final client = context.read<TCPClient>();
    _packetSubscription = client.packetStream.listen((packet) {
      if (packet is GameStartPacket) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const GameScreen(),
          ),
        );
        _packetSubscription.cancel();
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    precacheImage(AssetImage('assets/lobby_screen/lobby.png'), context);
  }

  @override
  void dispose() {
    _packetSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SizedBox.expand(
            child: Image.asset(
              'assets/lobby_screen/lobby.png',
              fit: BoxFit.cover,
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent, // make Scaffold transparent
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(
                  right: 12, bottom: 12), // breathing room
              child: ComicButton(
                onPressed: () {
                  context.read<TCPClient>().closeConnection().then((_) {
                    Navigator.of(context).pop();
                  });
                }, // exit lobby

                label: 'Exit Lobby',
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 100, vertical: 70),
                child: Column(
                  children: [
                    // Header
                    Row(
                      children: [
                        SizedBox.fromSize(
                          size: const Size(200, 80), // breathing room
                          child: Image.asset(
                            'assets/lobby_screen/players.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        const Spacer(), // breathing room
                        Align(
                          alignment: Alignment.topRight,
                          child: Consumer<TCPClient>(
                            builder: (context, tcpClient, child) {
                              return Text('Lobby Code: ${tcpClient.gamecode}',
                                  style: const TextStyle(
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                      color: ColorPalette.light));
                            },
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // 3×3 grid
                    Expanded(
                      child: Consumer<TCPClient>(
                        builder: (context, tcpClient, child) {
                          final List<PlayerSlot> slots = tcpClient.players
                              .map((player) => PlayerSlot(
                                    name: player['playername'] as String,
                                    isReady: player['is-ready'] as bool,
                                  ))
                              .toList();

                          return GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 400,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 3,
                            ),
                            itemCount: slots.length,
                            itemBuilder: (context, index) {
                              return PlayerSlotWidget(player: slots[index]);
                            },
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Ready button
                    Consumer<TCPClient>(
                      builder: (context, tcpClient, child) {
                        return ElevatedButton(
                          onPressed: () =>
                              handleReadyClick(tcpClient), // later: mark ready
                          style: titleScreenButtonStyle.copyWith(
                            backgroundColor:
                                WidgetStatePropertyAll(ColorPalette.yellow1),
                            side: WidgetStatePropertyAll(
                              BorderSide(
                                width: 4,
                                color: tcpClient.isReady
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 40),
                            ),
                          ),
                          child: const Text(
                            'Ready',
                            style:
                                TextStyle(fontSize: 30, color: Colors.black87),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void handleReadyClick(TCPClient tcpClient) {
    tcpClient.togglePlayStatus();
  }
}
