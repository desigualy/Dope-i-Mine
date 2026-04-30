import 'package:flutter/material.dart';

import '../../data/avatar/realistic_avatar_generator.dart';
import '../../domain/avatar/avatar_enums.dart';
import '../../domain/avatar/realistic_avatar_prompt_builder.dart';
import '../../domain/avatar/user_avatar_profile.dart';
import 'realistic_avatar_controller.dart';
import 'unified_user_avatar.dart';

class RealisticAvatarGenerationScreen extends StatefulWidget {
  const RealisticAvatarGenerationScreen({
    super.key,
    required this.generator,
    this.initialProfile = UserAvatarProfile.defaultAdult,
  });

  final RealisticAvatarGenerator generator;
  final UserAvatarProfile initialProfile;

  @override
  State<RealisticAvatarGenerationScreen> createState() =>
      _RealisticAvatarGenerationScreenState();
}

class _RealisticAvatarGenerationScreenState
    extends State<RealisticAvatarGenerationScreen> {
  late final RealisticAvatarController controller;

  @override
  void initState() {
    super.initState();
    controller = RealisticAvatarController(
      generator: widget.generator,
      initialProfile: widget.initialProfile,
    );
    controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final state = controller.state;
    final prompt = RealisticAvatarPromptBuilder.build(state.profile);

    return Scaffold(
      appBar: AppBar(title: const Text('Realistic avatar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Center(
            child: UnifiedUserAvatar(
              profile: state.profile,
              mood: DopeiMood.calm,
              size: 190,
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: Text(
                'No real photo is required. This avatar is generated from your '
                'choices, not from face recognition. You can delete it any time.',
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Generation prompt',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          SelectableText(prompt, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 16),
          if (state.errorMessage != null)
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(state.errorMessage!),
              ),
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed:
                state.loading ? null : controller.generateRealisticAvatar,
            icon: state.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(
              state.loading ? 'Creating avatar...' : 'Create realistic avatar',
            ),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            onPressed: state.loading ? null : controller.clearGeneratedAvatar,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete generated avatar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.removeListener(_onControllerChanged);
    controller.dispose();
    super.dispose();
  }
}
