import 'package:bbc_client/screens/game_screen.dart';
import 'package:bbc_client/tcp/tcp_client.dart';
import 'package:flutter/material.dart';

void main() async {
  TCPClient client = TCPClient('127.0.0.1', 65432);
  await client.createConnection();
  client.startGame();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: GameScreen(),
    );
  }
}
