import 'package:bbc_client/screens/game_screen.dart';
import 'package:bbc_client/screens/lobby_screen.dart';
import 'package:bbc_client/screens/title_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: TitleScreen());
  }
}
