import 'package:bbc_client/screens/game_screen.dart';
import 'package:bbc_client/tcp/tcp_client.dart';
import 'package:flutter/material.dart';

void main() {
  init();
  runApp(const MainApp());
}

void init() async {
  await createConnection();
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
