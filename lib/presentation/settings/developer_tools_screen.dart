import 'package:flutter/material.dart';
import '../../core/widgets/primary_scaffold.dart';

class DeveloperToolsScreen extends StatelessWidget {
  const DeveloperToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Developer Tools',
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Advanced diagnostic and troubleshooting tools.',
            ),
          ),
          ListTile(
            title: const Text('Export Debug Logs'),
            subtitle: const Text('Zip and share the current session logs for support.'),
            leading: const Icon(Icons.bug_report_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Preparing logs for export...')),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Verbose Sync State'),
            subtitle: const Text('Show detailed sync status on the home screen.'),
            value: false,
            secondary: const Icon(Icons.sync_rounded),
            onChanged: (val) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Setting saved.')),
              );
            },
          ),
          ListTile(
            title: const Text('Clear API Cache'),
            subtitle: const Text('Force the app to fetch fresh data on next launch.'),
            leading: const Icon(Icons.delete_sweep_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('API Cache cleared.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
