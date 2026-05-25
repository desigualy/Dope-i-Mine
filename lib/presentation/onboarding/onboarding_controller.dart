import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/branding/pronunciation_option.dart';
import '../../domain/onboarding/onboarding_state.dart';
import '../../domain/tasks/task_state_snapshot.dart';

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  return OnboardingController();
});

class OnboardingController extends StateNotifier<OnboardingState> {
  OnboardingController() : super(const OnboardingState()) {
    unawaited(_loadPersistedState());
  }

  static const _prefsPrefix = 'phase4_onboarding.';
  bool _hasLocalMutation = false;

  Future<void> _loadPersistedState() async {
    final prefs = await SharedPreferences.getInstance();
    if (_hasLocalMutation) return;
    state = state.copyWith(
      role: _enumByName(
              OnboardingRole.values, prefs.getString('${_prefsPrefix}role')) ??
          state.role,
      voiceEnabled: prefs.getBool('${_prefsPrefix}voiceEnabled'),
      notificationsEnabled:
          prefs.getBool('${_prefsPrefix}notificationsEnabled'),
      microphoneEnabled: prefs.getBool('${_prefsPrefix}microphoneEnabled'),
      largeText: prefs.getBool('${_prefsPrefix}largeText'),
      reducedAnimation: prefs.getBool('${_prefsPrefix}reducedAnimation'),
      softColors: prefs.getBool('${_prefsPrefix}softColors'),
      soundEnabled: prefs.getBool('${_prefsPrefix}soundEnabled'),
      iconMode: prefs.getBool('${_prefsPrefix}iconMode'),
      reduceSurprises: prefs.getBool('${_prefsPrefix}reduceSurprises'),
      bodyDoubleEnabled: prefs.getBool('${_prefsPrefix}bodyDoubleEnabled'),
      sideQuestsEnabled: prefs.getBool('${_prefsPrefix}sideQuestsEnabled'),
      firstTaskChoice: prefs.getString('${_prefsPrefix}firstTaskChoice'),
    );
  }

  T? _enumByName<T extends Enum>(List<T> values, String? name) {
    if (name == null) return null;
    for (final value in values) {
      if (value.name == name) return value;
    }
    return null;
  }

  void _set(OnboardingState next) {
    _hasLocalMutation = true;
    state = next;
    unawaited(_persistState(next));
  }

  Future<void> _persistState(OnboardingState value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('${_prefsPrefix}role', value.role.name);
    await prefs.setBool('${_prefsPrefix}voiceEnabled', value.voiceEnabled);
    await prefs.setBool(
        '${_prefsPrefix}notificationsEnabled', value.notificationsEnabled);
    await prefs.setBool(
        '${_prefsPrefix}microphoneEnabled', value.microphoneEnabled);
    await prefs.setBool('${_prefsPrefix}largeText', value.largeText);
    await prefs.setBool(
        '${_prefsPrefix}reducedAnimation', value.reducedAnimation);
    await prefs.setBool('${_prefsPrefix}softColors', value.softColors);
    await prefs.setBool('${_prefsPrefix}soundEnabled', value.soundEnabled);
    await prefs.setBool('${_prefsPrefix}iconMode', value.iconMode);
    await prefs.setBool(
        '${_prefsPrefix}reduceSurprises', value.reduceSurprises);
    await prefs.setBool(
        '${_prefsPrefix}bodyDoubleEnabled', value.bodyDoubleEnabled);
    await prefs.setBool(
        '${_prefsPrefix}sideQuestsEnabled', value.sideQuestsEnabled);
    await prefs.setString(
        '${_prefsPrefix}firstTaskChoice', value.firstTaskChoice);
  }

  Future<void> flushPersistenceForTest() => _persistState(state);

  void setAgeBand(AgeBand ageBand) => _set(state.copyWith(ageBand: ageBand));
  void setSexAtBirth(SexAtBirth value) =>
      _set(state.copyWith(sexAtBirth: value));
  void setGenderIdentity(GenderIdentity value) =>
      _set(state.copyWith(genderIdentity: value));
  void setPronouns(PronounSet value) => _set(state.copyWith(pronouns: value));
  void setCustomPronouns(String value) =>
      _set(state.copyWith(customPronouns: value));
  void setAssistantDisplayName(String value) =>
      _set(state.copyWith(assistantDisplayName: value));
  void setPronunciation(PronunciationOption value) =>
      _set(state.copyWith(pronunciation: value));
  void setMode(SupportMode mode) => _set(state.copyWith(mode: mode));
  void setReducedAnimation(bool value) =>
      _set(state.copyWith(reducedAnimation: value));
  void setLargeText(bool value) => _set(state.copyWith(largeText: value));
  void setSoundEnabled(bool value) => _set(state.copyWith(soundEnabled: value));
  void setVoiceEnabled(bool value) => _set(state.copyWith(voiceEnabled: value));
  void setRole(OnboardingRole role) => _set(state.copyWith(role: role));
  void setBodyDoubleEnabled(bool value) =>
      _set(state.copyWith(bodyDoubleEnabled: value));
  void setRemindersEnabled(bool value) =>
      _set(state.copyWith(notificationsEnabled: value));
  void setReducedMotion(bool value) =>
      _set(state.copyWith(reducedAnimation: value));
  void setCalmMode(bool value) => _set(state.copyWith(softColors: value));
  void setSideQuestsEnabled(bool value) =>
      _set(state.copyWith(sideQuestsEnabled: value));
  void setFirstTaskChoice(String value) =>
      _set(state.copyWith(firstTaskChoice: value));

  void setSoftColors(bool value) => _set(state.copyWith(softColors: value));
  void setIconMode(bool value) => _set(state.copyWith(iconMode: value));
  void setReduceSurprises(bool value) =>
      _set(state.copyWith(reduceSurprises: value));
  void setPraiseLevel(String value) => _set(state.copyWith(praiseLevel: value));

  void setSpeechRate(double value) => _set(state.copyWith(speechRate: value));
  void setAutoReadSteps(bool value) =>
      _set(state.copyWith(autoReadSteps: value));
  void setAutoReadSidequests(bool value) =>
      _set(state.copyWith(autoReadSidequests: value));
  void setActiveVoiceProfileId(String? value) =>
      _set(state.copyWith(activeVoiceProfileId: value));

  void setNotificationsEnabled(bool value) =>
      _set(state.copyWith(notificationsEnabled: value));
  void setMicrophoneEnabled(bool value) =>
      _set(state.copyWith(microphoneEnabled: value));
}
