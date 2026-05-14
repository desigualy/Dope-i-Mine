import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/caregiver/caregiver_models.dart';
import 'caregiver_controller.dart';

class LinkCaregiverScreen extends ConsumerStatefulWidget {
  const LinkCaregiverScreen({super.key});

  @override
  ConsumerState<LinkCaregiverScreen> createState() => _LinkCaregiverScreenState();
}

class _LinkCaregiverScreenState extends ConsumerState<LinkCaregiverScreen> {
  final _emailController = TextEditingController();
  CaregiverRole _selectedRole = CaregiverRole.caregiver;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(caregiverControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Add Support')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.people_alt_rounded, size: 64, color: Colors.blue),
          const SizedBox(height: 24),
          const Text(
            'Invite a Support Person',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enter the email address of the person you want to link to your account.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email Address',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email_outlined),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 24),
          const Text(
            'Choose a Role',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _RoleSelectionCard(
            role: CaregiverRole.monitor,
            title: 'Monitor',
            description: 'Light support. Can see summaries and send nudges.',
            selected: _selectedRole == CaregiverRole.monitor,
            onTap: () => setState(() => _selectedRole = CaregiverRole.monitor),
          ),
          _RoleSelectionCard(
            role: CaregiverRole.caregiver,
            title: 'Caregiver',
            description: 'General support. Can help manage routines and tasks.',
            selected: _selectedRole == CaregiverRole.caregiver,
            onTap: () => setState(() => _selectedRole = CaregiverRole.caregiver),
          ),
          _RoleSelectionCard(
            role: CaregiverRole.overseer,
            title: 'Overseer',
            description: 'High support. Can assign routines and view safety alerts.',
            selected: _selectedRole == CaregiverRole.overseer,
            onTap: () => setState(() => _selectedRole = CaregiverRole.overseer),
          ),
          const SizedBox(height: 32),
          if (state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                state.error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          FilledButton(
            onPressed: state.isLoading
                ? null
                : () async {
                    if (_emailController.text.trim().isEmpty) return;
                    await ref
                        .read(caregiverControllerProvider.notifier)
                        .sendRequest(_emailController.text.trim(), _selectedRole);
                    if (mounted && state.error == null) {
                      context.pop();
                    }
                  },
            child: state.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Send Invite'),
          ),
        ],
      ),
    );
  }
}

class _RoleSelectionCard extends StatelessWidget {
  final CaregiverRole role;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  const _RoleSelectionCard({
    required this.role,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: selected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: selected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Radio<CaregiverRole>(
                value: role,
                groupValue: selected ? role : null,
                onChanged: (_) => onTap(),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(description, style: TextStyle(fontSize: 12, color: Colors.grey.shade400)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
