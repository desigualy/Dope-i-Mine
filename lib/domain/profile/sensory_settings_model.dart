class SensorySettingsModel {
  const SensorySettingsModel({
    required this.reducedAnimation,
    required this.largeText,
    required this.softColors,
    required this.soundEnabled,
    required this.praiseLevel,
    required this.iconMode,
    required this.reduceSurprises,
  });

  final bool reducedAnimation;
  final bool largeText;
  final bool softColors;
  final bool soundEnabled;
  final String praiseLevel;
  final bool iconMode;
  final bool reduceSurprises;
}
