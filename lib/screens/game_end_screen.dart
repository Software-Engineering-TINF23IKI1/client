// lib/screens/end_routine_screen.dart
import 'package:flutter/material.dart';
import 'package:bbc_client/tcp/packets.dart';

class EndRoutineScreen extends StatelessWidget with RouteAware {
  const EndRoutineScreen({
    super.key,
    required this.finalScore,
    required this.isWinner,
    required this.scoreboard,
  });

  final double finalScore;
  final bool isWinner;
  final List<JsonObject> scoreboard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isWinner ? '🎉 Winner Winner Banana Dinner!' : 'Game Over',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your score: ${finalScore.toStringAsFixed(1)}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 32),
              const Text(
                'Scoreboard',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.separated(
                  itemCount: scoreboard.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (_, index) {
                    final entry = scoreboard[index];
                    return ListTile(
                      leading: CircleAvatar(child: Text('${index + 1}')),
                      title: Text(entry['playername'] ?? '—'),
                      trailing: Text((entry['score'] as num).toStringAsFixed(1),
                          style: const TextStyle(fontSize: 18)),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Back to title',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const TestApp());
}

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    // fake payload copied from your example
    final dummyScoreboard = [
      {'playername': 'p5', 'score': 7979.6},
      {'playername': 'p1', 'score': 6000.6},
      {'playername': 'p2', 'score': 5037.0},
      {'playername': 'player N', 'score': 1000.0},
    ];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: EndRoutineScreen(
        finalScore: 709.2,
        isWinner: false,
        scoreboard: dummyScoreboard,
      ),
    );
  }
}
