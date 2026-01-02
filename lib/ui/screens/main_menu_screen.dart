import 'package:flutter/material.dart';
import '../../domain/models/player.dart';
import '../widgets/app_background.dart';
import '../widgets/menu_button.dart';
import 'leaderboard_screen.dart';
import 'level_select_screen.dart';
import 'name_entry_screen.dart';

class MainMenuScreen extends StatelessWidget {
  final Player player;

  const MainMenuScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome back, Ranger',
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              player.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.white.withValues(alpha: 0.15),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Row(
                  children: [
                    _StatChip(
                      icon: Icons.scoreboard_rounded,
                      label: 'Total score',
                      value: player.totalScore.toString(),
                    ),
                    const SizedBox(width: 16),
                    _StatChip(
                      icon: Icons.flag_rounded,
                      label: 'Highest level',
                      value: player.highestLevel.toString(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MenuButton(
                      icon: Icons.play_arrow_rounded,
                      label: 'Explore habitats',
                      subtitle: 'Rescue pairs of critters level by level',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => LevelSelectScreen(
                              playerName: player.name,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    MenuButton(
                      icon: Icons.leaderboard_rounded,
                      label: 'Caretaker board',
                      subtitle: 'See who saved the most animals',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const LeaderboardScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    MenuButton(
                      icon: Icons.person_2_rounded,
                      label: 'Switch ranger',
                      subtitle: 'Play with another caretaker profile',
                      onTap: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => const NameEntryScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Text(
              'Tip: Chain perfect matches to become top caretaker!',
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white.withValues(alpha: 0.08),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon == Icons.scoreboard_rounded ? Icons.pets_rounded : icon,
                color: Colors.white),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
