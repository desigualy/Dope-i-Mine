import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/errors/user_facing_error_mapper.dart';
import '../../core/validators/auth_validators.dart';
import '../../domain/caregiver/caregiver_models.dart';
import '../voice/voice_input_button.dart';
import '../voice/voice_controller.dart';
import 'caregiver_controller.dart';

class LinkCaregiverScreen extends ConsumerStatefulWidget {
  const LinkCaregiverScreen({super.key});

  @override
  ConsumerState<LinkCaregiverScreen> createState() =>
      _LinkCaregiverScreenState();
}

class _LinkCaregiverScreenState extends ConsumerState<LinkCaregiverScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  CaregiverRole _selectedRole = CaregiverRole.caregiver;
  bool _obscurePassword = true;
  String? _localError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    setState(() => _localError = null);

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;
      validateEmail(email);
      validatePassword(password);
      if (password != _confirmPasswordController.text) {
        throw StateError('Passwords do not match.');
      }

      final sent =
          await ref.read(caregiverControllerProvider.notifier).sendRequest(
                email,
                _selectedRole,
                caregiverPassword: password,
              );
      if (mounted && sent) context.pop();
    } catch (error) {
      if (mounted) setState(() => _localError = mapToUserFacingError(error));
    }
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
            'Enter their email and choose the password they will use to sign in.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email Address',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.email_outlined),
              suffixIcon: VoiceInputButton(
                onTextChanged: (text) => _emailController.text = text,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Create Password',
              helperText:
                  'At least 8 characters. Share this with the caregiver securely.',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            textInputAction: TextInputAction.next,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _confirmPasswordController,
            obscureText: _obscurePassword,
            decoration: const InputDecoration(
              labelText: 'Confirm Password',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.lock_reset_outlined),
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!state.isLoading) _sendInvite();
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Choose a Role',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: 'Read roles aloud',
                icon: const Icon(Icons.volume_up_rounded, size: 20),
                onPressed: () {
                  const text = 'Choose a role: Monitor, for light support, can see summaries and send nudges. '
                      'Caregiver, for general support, can help manage routines and tasks. '
                      'Overseer, for high support, can assign routines and view safety alerts.';
                  ref.read(voiceControllerProvider).speakStep(text);
                },
              ),
            ],
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
            onTap: () =>
                setState(() => _selectedRole = CaregiverRole.caregiver),
          ),
          _RoleSelectionCard(
            role: CaregiverRole.overseer,
            title: 'Overseer',
            description:
                'High support. Can assign routines and view safety alerts.',
            selected: _selectedRole == CaregiverRole.overseer,
            onTap: () => setState(() => _selectedRole = CaregiverRole.overseer),
          ),
          const SizedBox(height: 32),
          if (_localError != null || state.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                _localError ?? state.error!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          FilledButton(
            onPressed: state.isLoading ? null : _sendInvite,
            child: state.isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
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
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(description,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade400)),
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
