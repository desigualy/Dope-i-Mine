import 'avatar_v4_rive_contract.dart';

enum AvatarV4RiveContractIssueCode {
  missingAsset,
  unreadableAsset,
  missingArtboard,
  missingStateMachine,
  missingNumberInput,
  missingBooleanInput,
}

class AvatarV4RiveContractIssue {
  const AvatarV4RiveContractIssue({
    required this.code,
    required this.message,
    this.name,
  });

  final AvatarV4RiveContractIssueCode code;
  final String message;
  final String? name;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'code': code.name,
      'message': message,
      if (name != null) 'name': name,
    };
  }
}

class AvatarV4RiveContractValidation {
  const AvatarV4RiveContractValidation({
    required this.assetPath,
    required this.artboardName,
    required this.stateMachineName,
    required this.issues,
  });

  factory AvatarV4RiveContractValidation.valid({
    String assetPath = AvatarV4RiveContract.baseRigAssetPath,
    String artboardName = AvatarV4RiveContract.artboardName,
    String stateMachineName = AvatarV4RiveContract.stateMachineName,
  }) {
    return AvatarV4RiveContractValidation(
      assetPath: assetPath,
      artboardName: artboardName,
      stateMachineName: stateMachineName,
      issues: const <AvatarV4RiveContractIssue>[],
    );
  }

  factory AvatarV4RiveContractValidation.missingAsset({
    String assetPath = AvatarV4RiveContract.baseRigAssetPath,
  }) {
    return AvatarV4RiveContractValidation(
      assetPath: assetPath,
      artboardName: AvatarV4RiveContract.artboardName,
      stateMachineName: AvatarV4RiveContract.stateMachineName,
      issues: <AvatarV4RiveContractIssue>[
        AvatarV4RiveContractIssue(
          code: AvatarV4RiveContractIssueCode.missingAsset,
          name: assetPath,
          message: 'Missing Rive asset: $assetPath',
        ),
      ],
    );
  }

  final String assetPath;
  final String artboardName;
  final String stateMachineName;
  final List<AvatarV4RiveContractIssue> issues;

  bool get isValid => issues.isEmpty;

  bool get canAttemptRender {
    return !issues.any(
      (issue) =>
          issue.code == AvatarV4RiveContractIssueCode.missingAsset ||
          issue.code == AvatarV4RiveContractIssueCode.unreadableAsset ||
          issue.code == AvatarV4RiveContractIssueCode.missingArtboard ||
          issue.code == AvatarV4RiveContractIssueCode.missingStateMachine,
    );
  }

  String get summary {
    if (isValid) return 'Avatar Rive contract valid';
    return issues.map((issue) => issue.message).join('\n');
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'assetPath': assetPath,
      'artboardName': artboardName,
      'stateMachineName': stateMachineName,
      'isValid': isValid,
      'issues': issues.map((issue) => issue.toJson()).toList(growable: false),
    };
  }
}
