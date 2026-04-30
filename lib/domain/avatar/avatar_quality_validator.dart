import 'avatar_enums.dart';
import 'user_avatar_profile.dart';

enum AvatarQualitySeverity {
  info,
  warning,
  blocker,
}

class AvatarQualityIssue {
  const AvatarQualityIssue({
    required this.code,
    required this.message,
    required this.severity,
  });

  final String code;
  final String message;
  final AvatarQualitySeverity severity;

  bool get isBlocker => severity == AvatarQualitySeverity.blocker;
}

class AvatarQualityResult {
  const AvatarQualityResult({
    required this.accepted,
    required this.issues,
  });

  final bool accepted;
  final List<AvatarQualityIssue> issues;

  bool get hasBlockers => issues.any((issue) => issue.isBlocker);
}

class AvatarQualityValidator {
  const AvatarQualityValidator._();

  static AvatarQualityResult validatePrompt({
    required UserAvatarProfile profile,
    required String prompt,
    required String negativePrompt,
  }) {
    final issues = <AvatarQualityIssue>[];
    final lowerPrompt = prompt.toLowerCase();
    final lowerNegative = negativePrompt.toLowerCase();

    void requireNegative(String phrase, String code) {
      if (!lowerNegative.contains(phrase.toLowerCase())) {
        issues.add(
          AvatarQualityIssue(
            code: code,
            message: 'Negative prompt should exclude "$phrase".',
            severity: AvatarQualitySeverity.warning,
          ),
        );
      }
    }

    requireNegative('Lego style', 'missing_negative_lego');
    requireNegative('blocky toy avatar', 'missing_negative_blocky');
    requireNegative('uncanny face', 'missing_negative_uncanny');
    requireNegative('offensive stereotype', 'missing_negative_stereotype');
    requireNegative('sexualised', 'missing_negative_sexualised');

    if (!lowerPrompt.contains('head-and-shoulders')) {
      issues.add(
        const AvatarQualityIssue(
          code: 'missing_head_shoulders',
          message: 'Prompt should specify head-and-shoulders framing.',
          severity: AvatarQualitySeverity.warning,
        ),
      );
    }

    if (!lowerPrompt.contains('natural proportions')) {
      issues.add(
        const AvatarQualityIssue(
          code: 'missing_natural_proportions',
          message: 'Prompt should request natural proportions.',
          severity: AvatarQualitySeverity.warning,
        ),
      );
    }

    if (!lowerPrompt.contains('not uncanny')) {
      issues.add(
        const AvatarQualityIssue(
          code: 'missing_uncanny_guard',
          message: 'Prompt should explicitly avoid uncanny results.',
          severity: AvatarQualitySeverity.warning,
        ),
      );
    }

    if (profile.agePresentation == AvatarAgePresentation.child ||
        profile.agePresentation == AvatarAgePresentation.preTeen ||
        profile.agePresentation == AvatarAgePresentation.teen) {
      if (!lowerNegative.contains('sexualised')) {
        issues.add(
          const AvatarQualityIssue(
            code: 'minor_missing_sexualised_negative',
            message:
                'Minor-safe prompts must explicitly exclude sexualised output.',
            severity: AvatarQualitySeverity.blocker,
          ),
        );
      }

      if (lowerPrompt.contains('glamour')) {
        issues.add(
          const AvatarQualityIssue(
            code: 'minor_glamour_language',
            message: 'Minor-safe prompts must not use glamour styling.',
            severity: AvatarQualitySeverity.blocker,
          ),
        );
      }
    }

    if (profile.mode == AvatarMode.privateAbstract &&
        lowerPrompt.contains('portrait')) {
      issues.add(
        const AvatarQualityIssue(
          code: 'private_mode_human_portrait',
          message:
              'Private abstract mode should avoid human portrait language.',
          severity: AvatarQualitySeverity.warning,
        ),
      );
    }

    return AvatarQualityResult(
      accepted: !issues.any((issue) => issue.isBlocker),
      issues: issues,
    );
  }

  static AvatarQualityResult validateGeneratedMetadata({
    required UserAvatarProfile profile,
    required Map<String, dynamic> metadata,
  }) {
    final issues = <AvatarQualityIssue>[];

    final flags = (metadata['flags'] as List?)?.cast<String>() ?? <String>[];
    for (final flag in flags) {
      issues.add(
        AvatarQualityIssue(
          code: 'provider_flag_$flag',
          message: 'Generation provider flagged: $flag.',
          severity: AvatarQualitySeverity.warning,
        ),
      );
    }

    final hasWatermark = metadata['hasWatermark'] == true;
    if (hasWatermark) {
      issues.add(
        const AvatarQualityIssue(
          code: 'watermark_detected',
          message: 'Generated avatar appears to contain a watermark.',
          severity: AvatarQualitySeverity.blocker,
        ),
      );
    }

    final detectedAgeBand = metadata['detectedAgeBand'] as String?;
    if (detectedAgeBand != null &&
        _isMinor(profile.agePresentation) &&
        detectedAgeBand == 'adult') {
      issues.add(
        const AvatarQualityIssue(
          code: 'minor_age_mismatch',
          message:
              'Generated avatar age band does not match a minor-safe profile.',
          severity: AvatarQualitySeverity.blocker,
        ),
      );
    }

    return AvatarQualityResult(
      accepted: !issues.any((issue) => issue.isBlocker),
      issues: issues,
    );
  }

  static bool _isMinor(AvatarAgePresentation value) {
    return value == AvatarAgePresentation.child ||
        value == AvatarAgePresentation.preTeen ||
        value == AvatarAgePresentation.teen;
  }
}
