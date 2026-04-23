class AvatarConfigModel {
  const AvatarConfigModel({
    required this.avatarStyle,
    required this.avatarPalette,
    required this.accessoryConfig,
  });

  final String avatarStyle;
  final String avatarPalette;
  final Map<String, dynamic> accessoryConfig;
}
