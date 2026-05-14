import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

const String avatarPluginAssetManifestPath =
    'assets/avatar/catalogues/avatar_plugin_asset_manifest.json';

class AvatarPluginAssetManifest {
  const AvatarPluginAssetManifest({
    required this.schemaVersion,
    required this.rive,
    required this.glb,
    required this.traits,
    required this.checklist,
  });

  final int schemaVersion;
  final AvatarRiveAssetSpec rive;
  final AvatarGlbAssetSpec glb;
  final Map<String, AvatarTraitAssetBinding> traits;
  final List<String> checklist;

  factory AvatarPluginAssetManifest.fromJson(Map<String, dynamic> json) {
    final rawTraits = json['traits'];
    return AvatarPluginAssetManifest(
      schemaVersion:
          json['schemaVersion'] is int ? json['schemaVersion'] as int : 1,
      rive: AvatarRiveAssetSpec.fromJson(
        Map<String, dynamic>.from(
            json['rive'] as Map? ?? const <String, dynamic>{}),
      ),
      glb: AvatarGlbAssetSpec.fromJson(
        Map<String, dynamic>.from(
            json['glb'] as Map? ?? const <String, dynamic>{}),
      ),
      traits: rawTraits is Map
          ? rawTraits.map(
              (key, value) => MapEntry(
                key.toString(),
                AvatarTraitAssetBinding.fromJson(
                  Map<String, dynamic>.from(value as Map),
                ),
              ),
            )
          : const <String, AvatarTraitAssetBinding>{},
      checklist: (json['checklist'] as List? ?? const <Object?>[])
          .whereType<String>()
          .toList(growable: false),
    );
  }

  AvatarTraitAssetBinding? bindingFor(String traitId) => traits[traitId];

  List<AvatarTraitAssetBinding> bindingsFor(Iterable<String> traitIds) =>
      traitIds
          .map(bindingFor)
          .whereType<AvatarTraitAssetBinding>()
          .toList(growable: false);

  List<String> missingProductionRequirements() {
    final missing = <String>[];
    if (rive.assetPath.trim().isEmpty) {
      missing.add('Rive asset path is missing.');
    }
    if (rive.artboard.trim().isEmpty) {
      missing.add('Rive artboard is missing.');
    }
    if (rive.stateMachine.trim().isEmpty) {
      missing.add('Rive state machine is missing.');
    }
    if (traits.isEmpty) {
      missing.add('No trait-to-asset bindings are defined.');
    }
    return missing;
  }
}

class AvatarRiveAssetSpec {
  const AvatarRiveAssetSpec({
    required this.assetPath,
    required this.artboard,
    required this.stateMachine,
    required this.requiredNumberInputs,
    required this.requiredBooleanInputs,
  });

  final String assetPath;
  final String artboard;
  final String stateMachine;
  final List<String> requiredNumberInputs;
  final List<String> requiredBooleanInputs;

  factory AvatarRiveAssetSpec.fromJson(Map<String, dynamic> json) {
    return AvatarRiveAssetSpec(
      assetPath: _string(json['assetPath']),
      artboard: _string(json['artboard']),
      stateMachine: _string(json['stateMachine']),
      requiredNumberInputs: _stringList(json['requiredNumberInputs']),
      requiredBooleanInputs: _stringList(json['requiredBooleanInputs']),
    );
  }
}

class AvatarGlbAssetSpec {
  const AvatarGlbAssetSpec({
    required this.baseBodyPath,
    required this.materialSlots,
    required this.meshSlots,
  });

  final String? baseBodyPath;
  final List<String> materialSlots;
  final List<String> meshSlots;

  factory AvatarGlbAssetSpec.fromJson(Map<String, dynamic> json) {
    return AvatarGlbAssetSpec(
      baseBodyPath: _nullableString(json['baseBodyPath']),
      materialSlots: _stringList(json['materialSlots']),
      meshSlots: _stringList(json['meshSlots']),
    );
  }
}

class AvatarTraitAssetBinding {
  const AvatarTraitAssetBinding({
    required this.traitId,
    required this.category,
    this.riveInputKey,
    this.riveValue,
    this.glbAssetPath,
    this.glbMaterialSlot,
    this.glbMeshSlot,
    this.required = false,
    this.notes,
  });

  final String traitId;
  final String category;
  final String? riveInputKey;
  final double? riveValue;
  final String? glbAssetPath;
  final String? glbMaterialSlot;
  final String? glbMeshSlot;
  final bool required;
  final String? notes;

  factory AvatarTraitAssetBinding.fromJson(Map<String, dynamic> json) {
    return AvatarTraitAssetBinding(
      traitId: _string(json['traitId']),
      category: _string(json['category']),
      riveInputKey: _nullableString(json['riveInputKey']),
      riveValue: json['riveValue'] is num
          ? (json['riveValue'] as num).toDouble()
          : null,
      glbAssetPath: _nullableString(json['glbAssetPath']),
      glbMaterialSlot: _nullableString(json['glbMaterialSlot']),
      glbMeshSlot: _nullableString(json['glbMeshSlot']),
      required: json['required'] == true,
      notes: _nullableString(json['notes']),
    );
  }
}

class AvatarPluginAssetResolver {
  const AvatarPluginAssetResolver(this.manifest);

  final AvatarPluginAssetManifest manifest;

  AvatarResolvedPluginAssets resolveTraitIds(Iterable<String> traitIds) {
    final bindings = manifest.bindingsFor(traitIds);
    return AvatarResolvedPluginAssets(
      riveInputs: <String, double>{
        for (final binding in bindings)
          if (binding.riveInputKey != null && binding.riveValue != null)
            binding.riveInputKey!: binding.riveValue!,
      },
      glbAssetPaths: bindings
          .map((binding) => binding.glbAssetPath)
          .whereType<String>()
          .toList(growable: false),
      missingTraitIds: traitIds
          .where((traitId) => manifest.bindingFor(traitId) == null)
          .toList(growable: false),
    );
  }
}

class AvatarResolvedPluginAssets {
  const AvatarResolvedPluginAssets({
    required this.riveInputs,
    required this.glbAssetPaths,
    required this.missingTraitIds,
  });

  final Map<String, double> riveInputs;
  final List<String> glbAssetPaths;
  final List<String> missingTraitIds;
}

Future<AvatarPluginAssetManifest> loadAvatarPluginAssetManifest({
  String assetPath = avatarPluginAssetManifestPath,
}) async {
  final raw = await rootBundle.loadString(assetPath);
  return AvatarPluginAssetManifest.fromJson(
    jsonDecode(raw) as Map<String, dynamic>,
  );
}

String _string(Object? value) => value is String ? value : '';

String? _nullableString(Object? value) {
  if (value is String && value.trim().isNotEmpty) return value;
  return null;
}

List<String> _stringList(Object? value) => value is List
    ? value.whereType<String>().toList(growable: false)
    : const <String>[];
