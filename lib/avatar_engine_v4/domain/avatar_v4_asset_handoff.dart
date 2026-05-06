import 'avatar_v4_rive_contract.dart';

class AvatarV4AssetHandoff {
  const AvatarV4AssetHandoff._();

  static const String productionRigPath = AvatarV4RiveContract.baseRigAssetPath;
  static const String artistBriefPath =
      'docs/avatar_rive/AVATAR_V4_RIVE_ARTIST_BRIEF.md';
  static const String technicalContractPath =
      'docs/avatar_rive/AVATAR_V4_RIVE_TECHNICAL_CONTRACT.md';
  static const String acceptanceChecklistPath =
      'docs/avatar_rive/AVATAR_V4_STYLE_ACCEPTANCE_CHECKLIST.md';
  static const String contractChecklistJsonPath =
      'assets/avatar_rive/base_avatar_contract_checklist.json';

  static const List<String> requiredHandoffFiles = <String>[
    artistBriefPath,
    technicalContractPath,
    acceptanceChecklistPath,
    contractChecklistJsonPath,
  ];
}
