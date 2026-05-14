import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

const String avatarTraitCatalogueAssetPath =
    'assets/avatar/catalogues/avatar_trait_catalogue.json';

enum AvatarTraitCategory {
  heritageIdentity('heritage_identity'),
  skinTone('skin_tone'),
  skinDetail('skin_detail'),
  hairTexture('hair_texture'),
  hairStyle('hair_style'),
  hairLength('hair_length'),
  hairColour('hair_colour'),
  faceShape('face_shape'),
  eyeShape('eye_shape'),
  eyeColour('eye_colour'),
  browStyle('brow_style'),
  noseShape('nose_shape'),
  mouthShape('mouth_shape'),
  facialHair('facial_hair'),
  bodyType('body_type'),
  bodySize('body_size'),
  heightPresentation('height_presentation'),
  clothing('clothing'),
  outerwear('outerwear'),
  glasses('glasses'),
  accessibilityItem('accessibility_item'),
  culturalHeadwear('cultural_headwear'),
  religiousHeadwear('religious_headwear'),
  accessory('accessory'),
  renderBackend('render_backend'),
  previewMode('preview_mode'),
  privateMode('private_mode');

  const AvatarTraitCategory(this.id);

  final String id;

  static AvatarTraitCategory parse(Object? value) {
    final id = value is String ? value.trim() : '';
    for (final category in AvatarTraitCategory.values) {
      if (category.id == id) return category;
    }
    throw FormatException('Unknown avatar trait category: $value');
  }
}

enum AvatarTraitRenderBackend {
  riveFace('rive_face'),
  riveBust('rive_bust'),
  glbFullBody('glb_full_body'),
  hybrid('hybrid'),
  privateAbstract('private_abstract');

  const AvatarTraitRenderBackend(this.id);

  final String id;

  static AvatarTraitRenderBackend parse(Object? value) {
    final id = value is String ? value.trim() : '';
    for (final backend in AvatarTraitRenderBackend.values) {
      if (backend.id == id) return backend;
    }
    throw FormatException('Unknown avatar trait render backend: $value');
  }
}

/// Represents a single trait in the Avatar Engine V4 catalogue.
class AvatarTrait {
  final String id;
  final String label;
  final AvatarTraitCategory category;
  final String description;
  final bool free;
  final bool identityProtected;
  final bool requiresMinorSafeMode;
  final List<AvatarTraitRenderBackend> renderBackendsSupported;
  final String? riveInputKey;
  final String? glbMaterialSlot;
  final int sortOrder;

  const AvatarTrait({
    required this.id,
    required this.label,
    required this.category,
    required this.description,
    required this.free,
    required this.identityProtected,
    required this.requiresMinorSafeMode,
    required this.renderBackendsSupported,
    this.riveInputKey,
    this.glbMaterialSlot,
    required this.sortOrder,
  });

  factory AvatarTrait.fromJson(Map<String, dynamic> json) => AvatarTrait(
        id: _requiredString(json, 'id'),
        label: _requiredString(json, 'label'),
        category: AvatarTraitCategory.parse(json['category']),
        description: _requiredString(json, 'description'),
        free: json['free'] == true,
        identityProtected: json['identityProtected'] == true,
        requiresMinorSafeMode: json['requiresMinorSafeMode'] == true,
        renderBackendsSupported:
            (json['renderBackendsSupported'] as List? ?? const <Object?>[])
                .map(AvatarTraitRenderBackend.parse)
                .toList(growable: false),
        riveInputKey: _nullableString(json['riveInputKey']),
        glbMaterialSlot: _nullableString(json['glbMaterialSlot']),
        sortOrder: json['sortOrder'] is int ? json['sortOrder'] as int : 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'category': category.id,
        'description': description,
        'free': free,
        'identityProtected': identityProtected,
        'requiresMinorSafeMode': requiresMinorSafeMode,
        'renderBackendsSupported': renderBackendsSupported
            .map((backend) => backend.id)
            .toList(growable: false),
        'riveInputKey': riveInputKey,
        'glbMaterialSlot': glbMaterialSlot,
        'sortOrder': sortOrder,
      };

  static String _requiredString(Map<String, dynamic> json, String key) {
    final value = json[key];
    if (value is String && value.trim().isNotEmpty) return value;
    throw FormatException(
        'Avatar trait is missing required string field: $key');
  }

  static String? _nullableString(Object? value) {
    if (value is String && value.trim().isNotEmpty) return value;
    return null;
  }
}

class AvatarTraitCatalogue {
  const AvatarTraitCatalogue(this.traits);

  final List<AvatarTrait> traits;

  factory AvatarTraitCatalogue.fromJson(Object? json) {
    final rawTraits = json is Map<String, dynamic> ? json['traits'] : json;
    if (rawTraits is! List) {
      throw const FormatException(
        'Avatar trait catalogue must be a list or an object with a traits list.',
      );
    }
    final traits = rawTraits
        .map((item) => AvatarTrait.fromJson(item as Map<String, dynamic>))
        .toList(growable: false)
      ..sort((a, b) {
        final categoryCompare = a.category.id.compareTo(b.category.id);
        if (categoryCompare != 0) return categoryCompare;
        final orderCompare = a.sortOrder.compareTo(b.sortOrder);
        if (orderCompare != 0) return orderCompare;
        return a.id.compareTo(b.id);
      });
    return AvatarTraitCatalogue(List<AvatarTrait>.unmodifiable(traits));
  }

  List<AvatarTrait> byCategory(AvatarTraitCategory category) => traits
      .where((trait) => trait.category == category)
      .toList(growable: false);

  List<String> idsFor(AvatarTraitCategory category) =>
      byCategory(category).map((trait) => trait.id).toList(growable: false);

  Map<String, String> labelsFor(AvatarTraitCategory category) =>
      <String, String>{
        for (final trait in byCategory(category)) trait.id: trait.label,
      };

  AvatarTrait? find(String id) {
    for (final trait in traits) {
      if (trait.id == id) return trait;
    }
    return null;
  }
}

/// Riverpod provider that loads the trait catalogue from bundled JSON.
final avatarTraitCatalogueProvider = FutureProvider<AvatarTraitCatalogue>(
  (ref) async => loadAvatarTraitCatalogueFromAsset(),
);

Future<AvatarTraitCatalogue> loadAvatarTraitCatalogueFromAsset({
  String assetPath = avatarTraitCatalogueAssetPath,
}) async {
  final raw = await rootBundle.loadString(assetPath);
  return AvatarTraitCatalogue.fromJson(jsonDecode(raw));
}
