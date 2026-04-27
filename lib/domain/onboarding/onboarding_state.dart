import '../branding/pronunciation_option.dart';
import '../tasks/task_state_snapshot.dart';

class OnboardingState {
  const OnboardingState({
    this.ageBand = AgeBand.adult,
    this.assistantDisplayName = 'Dope-i',
    this.pronunciation = PronunciationOption.dopeEe,
    this.mode = SupportMode.audhd,
    this.reducedAnimation = false,
    this.largeText = false,
    this.softColors = true,
    this.soundEnabled = true,
    this.iconMode = false,
    this.reduceSurprises = true,
    this.praiseLevel = 'medium',
    this.voiceEnabled = true,
    this.speechRate = 0.45,
    this.autoReadSteps = false,
    this.autoReadSidequests = false,
    this.activeVoiceProfileId,
    this.notificationsEnabled = false,
    this.microphoneEnabled = false,
  });

  final AgeBand ageBand;
  final String assistantDisplayName;
  final PronunciationOption pronunciation;
  final SupportMode mode;
  final bool reducedAnimation;
  final bool largeText;
  final bool softColors;
  final bool soundEnabled;
  final bool iconMode;
  final bool reduceSurprises;
  final String praiseLevel;
  final bool voiceEnabled;

  // Voice setup
  final double speechRate;
  final bool autoReadSteps;
  final bool autoReadSidequests;
  final String? activeVoiceProfileId;

  // Permissions preferences (best-effort; platform may override)
  final bool notificationsEnabled;
  final bool microphoneEnabled;

  OnboardingState copyWith({
    AgeBand? ageBand,
    String? assistantDisplayName,
    PronunciationOption? pronunciation,
    SupportMode? mode,
    bool? reducedAnimation,
    bool? largeText,
    bool? softColors,
    bool? soundEnabled,
    bool? iconMode,
    bool? reduceSurprises,
    String? praiseLevel,
    bool? voiceEnabled,
    double? speechRate,
    bool? autoReadSteps,
    bool? autoReadSidequests,
    String? activeVoiceProfileId,
    bool? notificationsEnabled,
    bool? microphoneEnabled,
  }) {
    return OnboardingState(
      ageBand: ageBand ?? this.ageBand,
      assistantDisplayName: assistantDisplayName ?? this.assistantDisplayName,
      pronunciation: pronunciation ?? this.pronunciation,
      mode: mode ?? this.mode,
      reducedAnimation: reducedAnimation ?? this.reducedAnimation,
      largeText: largeText ?? this.largeText,
      softColors: softColors ?? this.softColors,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      iconMode: iconMode ?? this.iconMode,
      reduceSurprises: reduceSurprises ?? this.reduceSurprises,
      praiseLevel: praiseLevel ?? this.praiseLevel,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
      speechRate: speechRate ?? this.speechRate,
      autoReadSteps: autoReadSteps ?? this.autoReadSteps,
      autoReadSidequests: autoReadSidequests ?? this.autoReadSidequests,
      activeVoiceProfileId: activeVoiceProfileId ?? this.activeVoiceProfileId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      microphoneEnabled: microphoneEnabled ?? this.microphoneEnabled,
    );
  }
}
