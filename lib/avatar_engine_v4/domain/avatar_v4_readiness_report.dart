import 'avatar_v4_asset_handoff.dart';
import 'avatar_v4_retirement_policy.dart';
import 'avatar_v4_rive_contract.dart';

class AvatarV4ReadinessReport {
  const AvatarV4ReadinessReport._();

  static const String status = 'ready_for_real_rive_asset';

  static const List<String> completedPasses = <String>[
    '3A Rive foundation',
    '3B Home/customizer wiring',
    '3C Rive asset contract',
    '3D Supabase/local cache sync',
    '3E reference image upload flow',
    '3F real service wiring',
    '3G V3 public-surface retirement',
    '3H Rive asset handoff pack',
    '3I Rive contract validator',
    '3J Rive initialization guard',
    '3K silent validator tests',
    '3L readiness report + runbook',
  ];

  static const List<String> remainingRequiredPasses = <String>[
    '4A Real Rive rig import',
    '4B Control binding QA',
    '4C Visual QA iteration',
  ];

  static const List<String> remainingOptionalPasses = <String>[
    '4D Store/unlock packs',
    '4E Delete old V3 leftovers',
    '4F Real-device Supabase upload test',
  ];

  static const List<String> readinessDocs = <String>[
    'docs/avatar_rive/AVATAR_V4_FINAL_READINESS_REPORT.md',
    'docs/avatar_rive/AVATAR_V4_TEST_RUNBOOK_AFTER_RIVE_IMPORT.md',
    'docs/avatar_rive/AVATAR_V4_NEXT_PASSES.md',
  ];

  static String get requiredRiveAssetPath => AvatarV4RiveContract.baseRigAssetPath;

  static List<String> get requiredHandoffFiles {
    return AvatarV4AssetHandoff.requiredHandoffFiles;
  }

  static List<String> get retiredPublicEngines {
    return AvatarV4RetirementPolicy.retiredPublicEngines;
  }

  static bool get isCodeShellComplete => true;

  static bool get requiresRealRiveAsset => true;
}
