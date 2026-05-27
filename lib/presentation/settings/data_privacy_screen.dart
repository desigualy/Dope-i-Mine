import 'package:flutter/material.dart';
import '../../core/widgets/primary_scaffold.dart';

class DataPrivacyScreen extends StatelessWidget {
  const DataPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Data & Privacy',
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Manage your data footprint and privacy settings here.',
            ),
          ),
          ListTile(
            title: const Text('Clear Local Cache'),
            subtitle: const Text('Free up space by deleting cached images and voice models. You will need to redownload them later.'),
            leading: const Icon(Icons.cleaning_services_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully.')),
              );
            },
          ),
          ListTile(
            title: const Text('Export My Data'),
            subtitle: const Text('Download a JSON archive of all your routines, tasks, and settings.'),
            leading: const Icon(Icons.download_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data export started. We will notify you when it is ready.')),
              );
            },
          ),
          const Divider(),
          ListTile(
            title: const Text(
              'Delete Account',
              style: TextStyle(color: Colors.red),
            ),
            subtitle: const Text('Permanently delete your account and wipe your data from the servers.'),
            leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Account?'),
                  content: const Text('This action cannot be undone. Are you absolutely sure?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Account deletion process initiated.')),
                        );
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
