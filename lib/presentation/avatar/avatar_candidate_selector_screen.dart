import 'package:flutter/material.dart';

import '../../data/avatar/avatar_batch_generator.dart';
import '../../domain/avatar/avatar_style_preset.dart';
import '../../domain/avatar/avatar_variation_strength.dart';
import '../../domain/avatar/user_avatar_profile.dart';
import 'avatar_candidate_controller.dart';
import 'avatar_candidate_grid.dart';

class AvatarCandidateSelectorScreen extends StatefulWidget {
  const AvatarCandidateSelectorScreen({
    super.key,
    required this.generator,
    this.initialProfile = UserAvatarProfile.defaultAdult,
  });

  final AvatarBatchGenerator generator;
  final UserAvatarProfile initialProfile;

  @override
  State<AvatarCandidateSelectorScreen> createState() =>
      _AvatarCandidateSelectorScreenState();
}

class _AvatarCandidateSelectorScreenState
    extends State<AvatarCandidateSelectorScreen> {
  late final AvatarCandidateController controller;

  @override
  void initState() {
    super.initState();
    controller = AvatarCandidateController(
      generator: widget.generator,
      initialProfile: widget.initialProfile,
    );
    controller.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final state = controller.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose your avatar'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          _section('Style'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AvatarStylePreset.values.map((preset) {
              return ChoiceChip(
                selected: state.stylePreset == preset,
                label: Text(preset.label),
                onSelected: (_) => controller.updateStylePreset(preset),
              );
            }).toList(),
          ),
          _section('Variation'),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AvatarVariationStrength.values.map((strength) {
              return ChoiceChip(
                selected: state.variationStrength == strength,
                label: Text(strength.label),
                onSelected: (_) => controller.updateVariationStrength(strength),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed:
                state.loading ? null : () => controller.generateCandidates(),
            icon: state.loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.auto_awesome),
            label: Text(state.loading ? 'Generating...' : 'Generate 4 options'),
          ),
          const SizedBox(height: 10),
          if (state.result != null)
            OutlinedButton.icon(
              onPressed: state.loading
                  ? null
                  : () => controller.regenerateVariation(
                        strength: state.variationStrength,
                      ),
              icon: const Icon(Icons.refresh),
              label: const Text('Regenerate options'),
            ),
          if (state.errorMessage != null) ...<Widget>[
            const SizedBox(height: 12),
            Card(
              color: Theme.of(context).colorScheme.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(state.errorMessage!),
              ),
            ),
          ],
          if (state.result != null) ...<Widget>[
            const SizedBox(height: 20),
            AvatarCandidateGrid(
              candidates: state.result!.candidates,
              selectedCandidate: state.selectedCandidate,
              onSelected: controller.selectCandidate,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: state.selectedCandidate == null
                  ? null
                  : () {
                      final profile = controller.acceptSelectedCandidate();
                      Navigator.of(context).pop(profile);
                    },
              child: const Text('Use selected avatar'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
      ),
    );
  }

  @override
  void dispose() {
    controller.removeListener(_onChanged);
    controller.dispose();
    super.dispose();
  }
}
