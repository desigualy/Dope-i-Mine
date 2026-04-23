
class SkinPackModel {
  const SkinPackModel({
    required this.id,
    required this.skinKey,
    required this.title,
    required this.tier,
    required this.isActive,
    required this.description,
    this.previewAssetPath,
    this.isOwned = false,
  });

  final String id;
  final String skinKey;
  final String title;
  final String tier;
  final bool isActive;
  final String description;
  final String? previewAssetPath;
  final bool isOwned;

  bool get isPremium => tier == 'premium' || tier == 'seasonal';

  SkinPackModel copyWith({
    String? id,
    String? skinKey,
    String? title,
    String? tier,
    bool? isActive,
    String? description,
    String? previewAssetPath,
    bool? isOwned,
  }) {
    return SkinPackModel(
      id: id ?? this.id,
      skinKey: skinKey ?? this.skinKey,
      title: title ?? this.title,
      tier: tier ?? this.tier,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      previewAssetPath: previewAssetPath ?? this.previewAssetPath,
      isOwned: isOwned ?? this.isOwned,
    );
  }
}
