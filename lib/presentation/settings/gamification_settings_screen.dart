import 'package:flutter/material.dart';
import '../../core/widgets/primary_scaffold.dart';

class GamificationSettingsScreen extends StatefulWidget {
  const GamificationSettingsScreen({super.key});

  @override
  State<GamificationSettingsScreen> createState() => _GamificationSettingsScreenState();
}

class _GamificationSettingsScreenState extends State<GamificationSettingsScreen> {
  bool _showXp = true;
  bool _showConfetti = true;
  bool _playSounds = true;
  bool _leaderboardVisible = false;

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Gamification & Rewards',
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Customize your visual rewards and social experience.',
            ),
          ),
          SwitchListTile(
            title: const Text('Show XP & Level Progress'),
            subtitle: const Text('Display experience points and level up animations.'),
            value: _showXp,
            secondary: const Icon(Icons.star_rounded),
            onChanged: (val) {
              setState(() => _showXp = val);
            },
          ),
          SwitchListTile(
            title: const Text('Visual Celebrations'),
            subtitle: const Text('Show confetti and fireworks when completing routines.'),
            value: _showConfetti,
            secondary: const Icon(Icons.celebration_rounded),
            onChanged: (val) {
              setState(() => _showConfetti = val);
            },
          ),
          SwitchListTile(
            title: const Text('Reward Sounds'),
            subtitle: const Text('Play sound effects for achievements.'),
            value: _playSounds,
            secondary: const Icon(Icons.music_note_rounded),
            onChanged: (val) {
              setState(() => _playSounds = val);
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Public Leaderboard'),
            subtitle: const Text('Opt-in to share your streak and score on the community leaderboard.'),
            value: _leaderboardVisible,
            secondary: const Icon(Icons.leaderboard_rounded),
            onChanged: (val) {
              setState(() => _leaderboardVisible = val);
            },
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Gamification settings saved.')),
                );
              },
              child: const Text('Save Changes'),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
