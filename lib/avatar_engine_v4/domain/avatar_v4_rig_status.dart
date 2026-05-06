enum AvatarV4RigStatusKind {
  available,
  missing,
  invalidContract,
}

class AvatarV4RigStatus {
  const AvatarV4RigStatus.available(this.assetPath)
      : kind = AvatarV4RigStatusKind.available,
        missingInputs = const <String>[];

  const AvatarV4RigStatus.missing(this.assetPath)
      : kind = AvatarV4RigStatusKind.missing,
        missingInputs = const <String>[];

  const AvatarV4RigStatus.invalidContract({
    required this.assetPath,
    required this.missingInputs,
  }) : kind = AvatarV4RigStatusKind.invalidContract;

  final AvatarV4RigStatusKind kind;
  final String assetPath;
  final List<String> missingInputs;

  bool get canRender => kind == AvatarV4RigStatusKind.available;
}
