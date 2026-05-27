import 'package:flutter/material.dart';
import '../../core/widgets/primary_scaffold.dart';

class IntegrationsScreen extends StatefulWidget {
  const IntegrationsScreen({super.key});

  @override
  State<IntegrationsScreen> createState() => _IntegrationsScreenState();
}

class _IntegrationsScreenState extends State<IntegrationsScreen> {
  bool _calendarSync = false;
  String _calendarProvider = 'apple';
  bool _appleHealth = false;
  bool _googleFit = false;
  bool _wearableHaptics = false;
  bool _spotifyFocus = false;

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Integrations & External Sync',
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Connect Dope-i-Mine to your favourite apps and services.',
            ),
          ),

          // Calendar Sync
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Calendar Sync',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Auto-export Routines to Calendar'),
            subtitle: const Text(
              'Automatically add your Dope-i-Mine routines to your native calendar.',
            ),
            value: _calendarSync,
            secondary: const Icon(Icons.calendar_month_rounded),
            onChanged: (val) {
              setState(() => _calendarSync = val);
            },
          ),
          if (_calendarSync) ...[
            RadioListTile<String>(
              title: const Text('Apple Calendar (iCal)'),
              value: 'apple',
              groupValue: _calendarProvider,
              secondary: const Icon(Icons.apple_rounded),
              onChanged: (val) {
                setState(() => _calendarProvider = val!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Google Calendar'),
              value: 'google',
              groupValue: _calendarProvider,
              secondary: const Icon(Icons.event_rounded),
              onChanged: (val) {
                setState(() => _calendarProvider = val!);
              },
            ),
            RadioListTile<String>(
              title: const Text('Outlook / Microsoft 365'),
              value: 'outlook',
              groupValue: _calendarProvider,
              secondary: const Icon(Icons.mail_rounded),
              onChanged: (val) {
                setState(() => _calendarProvider = val!);
              },
            ),
          ],

          const Divider(),

          // Health & Wearables
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Health & Wearables',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Apple Health'),
            subtitle: const Text(
              'Sync mindfulness minutes and activity with Apple Health.',
            ),
            value: _appleHealth,
            secondary: const Icon(Icons.monitor_heart_rounded),
            onChanged: (val) {
              setState(() => _appleHealth = val);
            },
          ),
          SwitchListTile(
            title: const Text('Google Fit'),
            subtitle: const Text(
              'Sync focus sessions and wellness data with Google Fit.',
            ),
            value: _googleFit,
            secondary: const Icon(Icons.fitness_center_rounded),
            onChanged: (val) {
              setState(() => _googleFit = val);
            },
          ),
          SwitchListTile(
            title: const Text('Wearable Haptic Alerts'),
            subtitle: const Text(
              'Vibrate your smartwatch for routine reminders and body-double nudges.',
            ),
            value: _wearableHaptics,
            secondary: const Icon(Icons.watch_rounded),
            onChanged: (val) {
              setState(() => _wearableHaptics = val);
            },
          ),

          const Divider(),

          // Focus & Productivity
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Focus & Productivity',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          SwitchListTile(
            title: const Text('Spotify Focus Playlists'),
            subtitle: const Text(
              'Auto-play curated focus playlists during task and routine sessions.',
            ),
            value: _spotifyFocus,
            secondary: const Icon(Icons.headphones_rounded),
            onChanged: (val) {
              setState(() => _spotifyFocus = val);
            },
          ),

          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Integration settings saved.')),
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
