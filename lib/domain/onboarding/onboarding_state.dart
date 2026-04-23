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
    this.soundEnabled = true,
    this.voiceEnabled = true,
  });

  final AgeBand ageBand;
  final String assistantDisplayName;
  final PronunciationOption pronunciation;
  final SupportMode mode;
  final bool reducedAnimation;
  final bool largeText;
  final bool soundEnabled;
  final bool voiceEnabled;

  OnboardingState copyWith({
    AgeBand? ageBand,
    String? assistantDisplayName,
    PronunciationOption? pronunciation,
    SupportMode? mode,
    bool? reducedAnimation,
    bool? largeText,
    bool? soundEnabled,
    bool? voiceEnabled,
  }) {
    return OnboardingState(
      ageBand: ageBand ?? this.ageBand,
      assistantDisplayName: assistantDisplayName ?? this.assistantDisplayName,
      pronunciation: pronunciation ?? this.pronunciation,
      mode: mode ?? this.mode,
      reducedAnimation: reducedAnimation ?? this.reducedAnimation,
      largeText: largeText ?? this.largeText,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      voiceEnabled: voiceEnabled ?? this.voiceEnabled,
    );
  }
}
