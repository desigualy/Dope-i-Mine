import 'package:flutter/material.dart';
import '../../core/widgets/primary_scaffold.dart';

class AdvancedSecurityScreen extends StatefulWidget {
  const AdvancedSecurityScreen({super.key});

  @override
  State<AdvancedSecurityScreen> createState() => _AdvancedSecurityScreenState();
}

class _AdvancedSecurityScreenState extends State<AdvancedSecurityScreen> {
  bool _appLockEnabled = false;

  @override
  Widget build(BuildContext context) {
    return PrimaryScaffold(
      title: 'Advanced Security',
      child: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Secure your app and manage your active sessions.',
            ),
          ),
          SwitchListTile(
            title: const Text('App Lock (Biometrics/PIN)'),
            subtitle: const Text('Require authentication to open the app.'),
            value: _appLockEnabled,
            secondary: const Icon(Icons.fingerprint_rounded),
            onChanged: (val) {
              setState(() => _appLockEnabled = val);
            },
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(
              'Active Sessions',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ListTile(
            title: const Text('This Device (iPhone 14 Pro)'),
            subtitle: const Text('Active now • iOS 16.5'),
            leading: const Icon(Icons.phone_iphone_rounded),
            trailing: const Text('Current', style: TextStyle(color: Colors.grey)),
          ),
          ListTile(
            title: const Text('Web Browser (Chrome)'),
            subtitle: const Text('Last active: 2 hours ago • Windows 11'),
            leading: const Icon(Icons.computer_rounded),
            trailing: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Session logged out.')),
                );
              },
              child: const Text('Log out', style: TextStyle(color: Colors.red)),
            ),
          ),
          ListTile(
            title: const Text('iPad (iPad Pro 11-inch)'),
            subtitle: const Text('Last active: 3 days ago • iPadOS 16.5'),
            leading: const Icon(Icons.tablet_mac_rounded),
            trailing: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Session logged out.')),
                );
              },
              child: const Text('Log out', style: TextStyle(color: Colors.red)),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Logging out of all other sessions...')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[900],
                foregroundColor: Colors.white,
              ),
              child: const Text('Log out of all other sessions'),
            ),
          ),
          const SizedBox(height: 48),
        ],
      ),
    );
  }
}
