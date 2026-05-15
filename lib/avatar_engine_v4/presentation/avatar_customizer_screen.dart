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

    return Scaffold(
      appBar: AppBar(title: const Text('Avatar')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: <Widget>[
          Center(
            child: AvatarRiveView(
              key: const ValueKey<String>('avatar-v4-customizer-rive-preview'),
              config: config,
              size: 220,
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
            text: "You can change your look anytime. There's no wrong way to be you!",
            mood: DopeiMood.happy,
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
              key: const ValueKey<String>('avatar-v4-customizer-error-message'),
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
          if (_saveMessage != null) ...<Widget>[
            const SizedBox(height: 12),
            Text(
              _saveMessage!,
              key: const ValueKey<String>('avatar-v4-customizer-save-message'),
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
              label: Text(_returnToOnboarding ? 'Continue to summary' : 'Done'),
            ),
          ),
        ],
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

  Future<void> _saveDraftConfig(String? userId) async {
    final cleanUserId = userId?.trim();
    if (cleanUserId == null || cleanUserId.isEmpty) {
      setState(() => _errorMessage = 'Sign in before saving your avatar.');
      return;
    }
    final config = (_draftConfig ?? widget.config).copyWith(
      updatedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
    await ref.read(avatarV4RepositoryProvider).saveRemoteConfig(
          cleanUserId,
          config,
        );
    if (!mounted) return;
    setState(() {
      _draftConfig = config;
      _errorMessage = null;
      _saveMessage = 'Avatar profile saved for the plugin renderer.';
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

class _AvatarTraitLibrarySection extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      key: const ValueKey<String>('avatar-v4-trait-library'),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Avatar trait library',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
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
