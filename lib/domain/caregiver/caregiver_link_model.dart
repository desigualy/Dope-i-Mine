class CaregiverLinkModel {
  const CaregiverLinkModel({
    required this.id,
    required this.primaryUserId,
    required this.caregiverUserId,
    required this.permissionLevel,
  });

  final String id;
  final String primaryUserId;
  final String caregiverUserId;
  final String permissionLevel;
}
