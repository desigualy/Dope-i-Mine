import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../domain/avatar_trait_catalogue.dart';
import '../domain/avatar_v4_config.dart';
import '../domain/avatar_v4_reference_image_upload.dart';
import '../providers/avatar_v4_providers.dart';
import 'avatar_reference_image_panel.dart';
import 'avatar_rive_view.dart';

import '../../presentation/core/widgets/dopei_guide.dart';
import '../../presentation/user_avatar/user_avatar_studio.dart';
import '../../presentation/voice/voice_input_button.dart';
import '../../presentation/voice/voice_controller.dart';

class AvatarCustomizerScreen extends ConsumerStatefulWidget {
  const AvatarCustomizerScreen({
    super.key,
    this.config = const AvatarV4Config(),
    this.returnTo,
  });

  final AvatarV4Config config;
  final String? returnTo;

  @override
  ConsumerState<AvatarCustomizerScreen> createState() =>
      _AvatarCustomizerScreenState();
}

class _AvatarCustomizerScreenState
    extends ConsumerState<AvatarCustomizerScreen> {
  AvatarV4Config? _draftConfig;
  bool _loadedEffectiveConfig = false;
  String? _saveMessage;
  String? _errorMessage;

  bool get _returnToOnboarding => widget.returnTo == 'onboarding';

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(avatarV4CurrentUserIdProvider);
    final isOnline = ref.watch(avatarV4OnlineProvider).maybeWhen(
          data: (value) => value,
          orElse: () => false,
        );
    final config = _draftConfig ?? widget.config;
    final effectiveConfig = ref.watch(avatarV4EffectiveConfigProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Avatar')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: effectiveConfig.when(
                  loading: () => const SizedBox.square(
                    key: ValueKey<String>('avatar-v4-config-loading'),
                    dimension: 220,
                    child: Center(
                      child: Text('Loading saved avatar…'),
                    ),
                  ),
                  error: (error, stackTrace) {
                    _primeDraftConfig(config);
                    return AvatarRiveView(
                      key: const ValueKey<String>(
                          'avatar-v4-customizer-rive-preview'),
                      config: config,
                      size: 220,
                    );
                  },
                  data: (loadedConfig) {
                    _primeDraftConfig(loadedConfig);
                    return AvatarRiveView(
                      key: const ValueKey<String>(
                          'avatar-v4-customizer-rive-preview'),
                      config: _draftConfig ?? loadedConfig,
                      size: 220,
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Avatar Engine V4 is ready for Rive art packs.',
                key: ValueKey<String>('avatar-v4-customizer-status'),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Your selections are saved as plugin-renderer settings. A real production .riv/.glb asset pack is required for polished output; until then the preview shows a starter placeholder.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const DopeiGuide(
                text:
                    "You can change your look anytime. There's no wrong way to be you!",
                mood: DopeiMood.happy,
              ),
              const SizedBox(height: 16),
              _AvatarVoiceCommandCard(
                config: config,
                onChanged: _updateDraftConfig,
              ),
              const SizedBox(height: 24),
              AvatarReferenceImagePanel(
                userId: userId,
                isOnline: isOnline,
                service: ref.watch(avatarV4ReferenceImageServiceProvider),
                onUploaded: _registerReferenceUpload,
              ),
              const SizedBox(height: 24),
              const UserAvatarStudioCard(),
              if (_errorMessage != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  key: const ValueKey<String>(
                      'avatar-v4-customizer-error-message'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              if (_saveMessage != null) ...<Widget>[
                const SizedBox(height: 12),
                Text(
                  _saveMessage!,
                  key: const ValueKey<String>(
                      'avatar-v4-customizer-save-message'),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24),
              _AvatarTraitLibrarySection(
                config: config,
                catalogue: ref.watch(avatarTraitCatalogueProvider).valueOrNull,
                onChanged: _updateDraftConfig,
                onSave: () => _saveDraftConfig(userId),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: ValueKey<String>(
                    _returnToOnboarding
                        ? 'avatar-v4-continue-to-summary-button'
                        : 'avatar-v4-done-button',
                  ),
                  onPressed: _finishAvatarFlow,
                  icon: const Icon(Icons.check_rounded),
                  label: Text(
                      _returnToOnboarding ? 'Continue to summary' : 'Done'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateDraftConfig(AvatarV4Config config) {
    setState(() {
      _draftConfig = config.copyWith(
        updatedAtIso: DateTime.now().toUtc().toIso8601String(),
      );
      _errorMessage = null;
      _saveMessage =
          'Avatar look updated. Save avatar profile to keep these settings.';
    });
  }

  void _primeDraftConfig(AvatarV4Config config) {
    if (_loadedEffectiveConfig) return;
    _loadedEffectiveConfig = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _draftConfig != null) return;
      setState(() => _draftConfig = config);
    });
  }

  Future<void> _saveDraftConfig(String? userId) async {
    final isOnline = ref.read(avatarV4OnlineProvider).maybeWhen(
          data: (value) => value,
          orElse: () => false,
        );
    final config = (_draftConfig ?? widget.config).copyWith(
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
    try {
      final syncService = await ref.read(avatarV4SyncServiceProvider.future);
      await syncService.saveConfigLocalFirst(
        userId: userId,
        config: config,
        isOnline: isOnline,
      );
      ref.invalidate(avatarV4EffectiveConfigProvider);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            'Avatar saved on this device, but cloud sync could not finish. Try again when your connection is stable.';
      });
      return;
    }
    if (!mounted) return;
    setState(() {
      _draftConfig = config;
      _errorMessage = null;
      _saveMessage = isOnline && userId != null && userId.trim().isNotEmpty
          ? 'Avatar profile saved and synced.'
          : 'Avatar profile saved on this device.';
    });
  }

  void _registerReferenceUpload(AvatarV4ReferenceImageUpload upload) {
    setState(() {
      _errorMessage = null;
      _saveMessage = 'Reference photo uploaded for Avatar Engine V4.';
    });
  }

  void _finishAvatarFlow() {
    if (_returnToOnboarding) {
      context.go('/onboarding/summary');
      return;
    }
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.go('/settings/companion');
  }
}

class _AvatarTraitLibrarySection extends ConsumerWidget {
  const _AvatarTraitLibrarySection({
    required this.config,
    required this.catalogue,
    required this.onChanged,
    required this.onSave,
  });

  final AvatarV4Config config;
  final AvatarTraitCatalogue? catalogue;
  final ValueChanged<AvatarV4Config> onChanged;
  final VoidCallback onSave;

  List<String> _ids(AvatarTraitCategory category, List<String> fallback) {
    final values = catalogue?.idsFor(category) ?? const <String>[];
    return values.isEmpty ? fallback : values;
  }

  Map<String, String> _labels(AvatarTraitCategory category) =>
      catalogue?.labelsFor(category) ?? const <String, String>{};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      key: const ValueKey<String>('avatar-v4-trait-library'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Avatar trait library',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                IconButton(
                  tooltip: 'Read active traits aloud',
                  icon: const Icon(Icons.volume_up_rounded),
                  onPressed: () {
                    final text =
                        "Your active traits: Skin tone is ${config.skinTone.replaceAll('_', ' ')}, "
                        "Face shape is ${config.faceShape.replaceAll('_', ' ')}, "
                        "Eye shape is ${config.eyeShape.replaceAll('_', ' ')}, "
                        "Eye colour is ${config.eyeColor.replaceAll('_', ' ')}, "
                        "Hair style is ${config.hairStyleId.replaceAll('_', ' ')}, "
                        "Hair colour is ${config.hairColor.replaceAll('_', ' ')}, "
                        "Body type is ${config.bodyPresetId.replaceAll('_', ' ')}. "
                        "Accessories include ${config.accessoryIds.isEmpty ? 'none' : config.accessoryIds.join(' and ').replaceAll('_', ' ')}.";
                    ref.read(voiceControllerProvider).speakStep(text);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Appearance traits are user-controlled and do not imply identity.',
            ),
            const SizedBox(height: 16),
            _ChoiceField(
              label: 'Skin tone',
              value: config.skinTone,
              values: _ids(AvatarTraitCategory.skinTone,
                  const <String>['fair_warm', 'tan_warm', 'medium_brown']),
              labels: _labels(AvatarTraitCategory.skinTone),
              onChanged: (value) => onChanged(config.copyWith(skinTone: value)),
            ),
            _ChoiceField(
              label: 'Face shape',
              value: config.faceShape,
              values: _ids(AvatarTraitCategory.faceShape,
                  const <String>['soft_oval', 'round', 'square']),
              labels: _labels(AvatarTraitCategory.faceShape),
              onChanged: (value) =>
                  onChanged(config.copyWith(faceShape: value)),
            ),
            _ChoiceField(
              label: 'Eye shape',
              value: config.eyeShape,
              values: _ids(AvatarTraitCategory.eyeShape,
                  const <String>['soft_almond', 'round', 'hooded']),
              labels: _labels(AvatarTraitCategory.eyeShape),
              onChanged: (value) => onChanged(config.copyWith(eyeShape: value)),
            ),
            _ChoiceField(
              label: 'Eye colour',
              value: config.eyeColor,
              values: _ids(AvatarTraitCategory.eyeColour,
                  const <String>['brown', 'green', 'blue']),
              labels: _labels(AvatarTraitCategory.eyeColour),
              onChanged: (value) => onChanged(config.copyWith(eyeColor: value)),
            ),
            _ChoiceField(
              label: 'Hair style',
              value: config.hairStyleId,
              values: _ids(AvatarTraitCategory.hairStyle,
                  const <String>['long_wavy', 'full_afro', 'locs']),
              labels: _labels(AvatarTraitCategory.hairStyle),
              onChanged: (value) =>
                  onChanged(config.copyWith(hairStyleId: value)),
            ),
            _ChoiceField(
              label: 'Hair colour',
              value: config.hairColor,
              values: _ids(AvatarTraitCategory.hairColour,
                  const <String>['black', 'dark_brown', 'copper_brown']),
              labels: _labels(AvatarTraitCategory.hairColour),
              onChanged: (value) =>
                  onChanged(config.copyWith(hairColor: value)),
            ),
            _ChoiceField(
              label: 'Body type',
              value: config.bodyPresetId,
              values: _ids(AvatarTraitCategory.bodyType,
                  const <String>['average_soft', 'broad_soft', 'seated_soft']),
              labels: _labels(AvatarTraitCategory.bodyType),
              onChanged: (value) =>
                  onChanged(config.copyWith(bodyPresetId: value)),
            ),
            _MultiTraitGroup(
              title: 'Accessories',
              values: config.accessoryIds,
              options: _ids(AvatarTraitCategory.accessory,
                  const <String>['glasses_round', 'sensory_headphones']),
              labels: _labels(AvatarTraitCategory.accessory),
              onChanged: (values) =>
                  onChanged(config.copyWith(accessoryIds: values)),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const ValueKey<String>('avatar-v4-save-profile-button'),
                onPressed: onSave,
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save avatar profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChoiceField extends StatelessWidget {
  const _ChoiceField({
    required this.label,
    required this.value,
    required this.values,
    required this.onChanged,
    this.labels = const <String, String>{},
  });

  final String label;
  final String value;
  final List<String> values;
  final Map<String, String> labels;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final safeValue = values.contains(value) ? value : values.first;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: DropdownButtonFormField<String>(
        value: safeValue,
        decoration: InputDecoration(labelText: label),
        items: values
            .map((item) => DropdownMenuItem<String>(
                  value: item,
                  child: Text(labels[item] ?? _label(item)),
                ))
            .toList(growable: false),
        onChanged: (value) {
          if (value != null) onChanged(value);
        },
      ),
    );
  }
}

class _MultiTraitGroup extends StatelessWidget {
  const _MultiTraitGroup({
    required this.title,
    required this.values,
    required this.options,
    required this.onChanged,
    this.labels = const <String, String>{},
  });

  final String title;
  final List<String> values;
  final List<String> options;
  final Map<String, String> labels;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(title),
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final selected = values.contains(option);
              return FilterChip(
                label: Text(labels[option] ?? _label(option)),
                selected: selected,
                onSelected: (value) {
                  final next = <String>{...values};
                  if (value) {
                    next.add(option);
                  } else {
                    next.remove(option);
                  }
                  onChanged(next.toList(growable: false));
                },
              );
            }).toList(growable: false),
          ),
        ),
      ],
    );
  }
}

String _label(String value) => value
    .replaceAll('_', ' ')
    .split(' ')
    .where((part) => part.isNotEmpty)
    .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
    .join(' ');

class _AvatarVoiceCommandCard extends ConsumerWidget {
  const _AvatarVoiceCommandCard({
    required this.config,
    required this.onChanged,
  });

  final AvatarV4Config config;
  final ValueChanged<AvatarV4Config> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: scheme.surfaceVariant.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: scheme.outline.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: scheme.primary.withOpacity(0.12),
                  foregroundColor: scheme.primary,
                  child: const Icon(Icons.mic_rounded),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Voice Customizer',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w900,
                                ),
                      ),
                      Text(
                        'Speak traits (e.g. tan, afro, glasses, headphones)',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: scheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: scheme.outline.withOpacity(0.2)),
                    ),
                    child: Text(
                      'Tap the mic and say: "Locs" or "Add sensory headphones" or "fair skin".',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 13,
                        color: scheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                VoiceInputButton(
                  onTextChanged: (text) =>
                      _handleVoiceCommand(context, ref, text),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleVoiceCommand(BuildContext context, WidgetRef ref, String text) {
    var next = config;
    final lower = text.toLowerCase();
    bool updated = false;
    String feedback = '';

    if (lower.contains('tan')) {
      next = next.copyWith(skinTone: 'tan_warm');
      feedback += 'Skin tone set to tan. ';
      updated = true;
    } else if (lower.contains('fair')) {
      next = next.copyWith(skinTone: 'fair_warm');
      feedback += 'Skin tone set to fair. ';
      updated = true;
    } else if (lower.contains('brown') || lower.contains('medium')) {
      next = next.copyWith(skinTone: 'medium_brown');
      feedback += 'Skin tone set to medium brown. ';
      updated = true;
    }

    if (lower.contains('oval')) {
      next = next.copyWith(faceShape: 'soft_oval');
      feedback += 'Face shape set to soft oval. ';
      updated = true;
    } else if (lower.contains('round')) {
      next = next.copyWith(faceShape: 'round');
      feedback += 'Face shape set to round. ';
      updated = true;
    } else if (lower.contains('square')) {
      next = next.copyWith(faceShape: 'square');
      feedback += 'Face shape set to square. ';
      updated = true;
    }

    if (lower.contains('afro')) {
      next = next.copyWith(hairStyleId: 'full_afro');
      feedback += 'Hair style set to full afro. ';
      updated = true;
    } else if (lower.contains('locs') || lower.contains('lock')) {
      next = next.copyWith(hairStyleId: 'locs');
      feedback += 'Hair style set to locs. ';
      updated = true;
    } else if (lower.contains('long') || lower.contains('wavy')) {
      next = next.copyWith(hairStyleId: 'long_wavy');
      feedback += 'Hair style set to long wavy. ';
      updated = true;
    }

    if (lower.contains('glass')) {
      final list = {...next.accessoryIds};
      if (list.contains('glasses_round')) {
        list.remove('glasses_round');
        feedback += 'Removed glasses. ';
      } else {
        list.add('glasses_round');
        feedback += 'Added glasses. ';
      }
      next = next.copyWith(accessoryIds: list.toList());
      updated = true;
    }

    if (lower.contains('headphone') ||
        lower.contains('headset') ||
        lower.contains('sensory')) {
      final list = {...next.accessoryIds};
      if (list.contains('sensory_headphones')) {
        list.remove('sensory_headphones');
        feedback += 'Removed headphones. ';
      } else {
        list.add('sensory_headphones');
        feedback += 'Added sensory headphones. ';
      }
      next = next.copyWith(accessoryIds: list.toList());
      updated = true;
    }

    if (updated) {
      onChanged(next);
      ref.read(voiceControllerProvider).speakStep('$feedback Done!');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Voice applied: $feedback')),
      );
    } else {
      ref.read(voiceControllerProvider).speakStep(
          "I heard: $text. I didn't recognize any trait keyword. Try saying: tan skin, afro hair, long hair, glasses, or sensory headphones.");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Heard: "$text". Say: tan, fair, afro, locs, glasses, headphones.')),
      );
    }
  }
}
