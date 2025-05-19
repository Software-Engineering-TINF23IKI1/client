import 'package:bbc_client/screens/game_screen.dart';
import 'package:bbc_client/tcp/tcp_client.dart';
import 'package:bbc_client/screens/lobby_screen.dart';
import 'package:bbc_client/screens/title_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TCPClient(),
      child: const MaterialApp(
        home: TitleScreen(),
      ),
    );
  }
}
