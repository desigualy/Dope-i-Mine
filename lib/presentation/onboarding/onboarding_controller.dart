import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/branding/pronunciation_option.dart';
import '../../domain/onboarding/onboarding_state.dart';
import '../../domain/tasks/task_state_snapshot.dart';

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController();
});

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController() : super(const OnboardingState());

  void setAgeBand(AgeBand ageBand) => state = state.copyWith(ageBand: ageBand);
  void setAssistantDisplayName(String value) => state = state.copyWith(assistantDisplayName: value);
  void setPronunciation(PronunciationOption value) => state = state.copyWith(pronunciation: value);
  void setMode(SupportMode mode) => state = state.copyWith(mode: mode);
  void setReducedAnimation(bool value) => state = state.copyWith(reducedAnimation: value);
  void setLargeText(bool value) => state = state.copyWith(largeText: value);
  void setSoundEnabled(bool value) => state = state.copyWith(soundEnabled: value);
  void setVoiceEnabled(bool value) => state = state.copyWith(voiceEnabled: value);

  void setSoftColors(bool value) => state = state.copyWith(softColors: value);
  void setIconMode(bool value) => state = state.copyWith(iconMode: value);
  void setReduceSurprises(bool value) => state = state.copyWith(reduceSurprises: value);
  void setPraiseLevel(String value) => state = state.copyWith(praiseLevel: value);

  void setSpeechRate(double value) => state = state.copyWith(speechRate: value);
  void setAutoReadSteps(bool value) => state = state.copyWith(autoReadSteps: value);
  void setAutoReadSidequests(bool value) => state = state.copyWith(autoReadSidequests: value);
  void setActiveVoiceProfileId(String? value) => state = state.copyWith(activeVoiceProfileId: value);

  void setNotificationsEnabled(bool value) => state = state.copyWith(notificationsEnabled: value);
  void setMicrophoneEnabled(bool value) => state = state.copyWith(microphoneEnabled: value);
}
