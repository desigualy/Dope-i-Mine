import 'avatar_variation_strength.dart';

class AvatarGenerationCandidate {
  const AvatarGenerationCandidate({
    required this.id,
    required this.imageUrl,
    required this.qualityScore,
    required this.seed,
    required this.variationStrength,
    this.localPath,
    this.providerId,
    this.revisedPrompt,
    this.warnings = const <String>[],
    this.metadata = const <String, dynamic>{},
  });

  final String id;
  final String imageUrl;
  final String? localPath;
  final double qualityScore;
  final String seed;
  final AvatarVariationStrength variationStrength;
  final String? providerId;
  final String? revisedPrompt;
  final List<String> warnings;
  final Map<String, dynamic> metadata;

  bool get hasWarnings => warnings.isNotEmpty;
  bool get isHighQuality => qualityScore >= 0.78 && warnings.isEmpty;

  AvatarGenerationCandidate copyWith({
    String? id,
    String? imageUrl,
    String? localPath,
    double? qualityScore,
    String? seed,
    AvatarVariationStrength? variationStrength,
    String? providerId,
    String? revisedPrompt,
    List<String>? warnings,
    Map<String, dynamic>? metadata,
  }) {
    return AvatarGenerationCandidate(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      localPath: localPath ?? this.localPath,
      qualityScore: qualityScore ?? this.qualityScore,
      seed: seed ?? this.seed,
      variationStrength: variationStrength ?? this.variationStrength,
      providerId: providerId ?? this.providerId,
      revisedPrompt: revisedPrompt ?? this.revisedPrompt,
      warnings: warnings ?? this.warnings,
      metadata: metadata ?? this.metadata,
    );
  }

  factory AvatarGenerationCandidate.fromJson(Map<String, dynamic> json) {
    return AvatarGenerationCandidate(
      id: json['id'] as String,
      imageUrl: json['imageUrl'] as String,
      localPath: json['localPath'] as String?,
      qualityScore: (json['qualityScore'] as num?)?.toDouble() ?? 0.0,
      seed: json['seed'] as String? ?? '',
      variationStrength: _variationFromName(
        json['variationStrength'] as String?,
      ),
      providerId: json['providerId'] as String?,
      revisedPrompt: json['revisedPrompt'] as String?,
      warnings: (json['warnings'] as List?)?.cast<String>() ?? <String>[],
      metadata: (json['metadata'] as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{},
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'imageUrl': imageUrl,
      'localPath': localPath,
      'qualityScore': qualityScore,
      'seed': seed,
      'variationStrength': variationStrength.name,
      'providerId': providerId,
      'revisedPrompt': revisedPrompt,
      'warnings': warnings,
      'metadata': metadata,
    };
  }

  static AvatarVariationStrength _variationFromName(String? value) {
    for (final item in AvatarVariationStrength.values) {
      if (item.name == value) return item;
    }
    return AvatarVariationStrength.medium;
  }
}
