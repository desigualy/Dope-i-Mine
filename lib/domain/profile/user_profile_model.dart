import '../tasks/task_state_snapshot.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.id,
    required this.role,
    required this.ageBand,
    required this.defaultMode,
    required this.rewardPreference,
    required this.stimulationLevel,
    required this.readingSupportLevel,
    required this.voiceEnabled,
    this.displayName,
  });

  final String id;
  final String role;
  final AgeBand ageBand;
  final SupportMode defaultMode;
  final String rewardPreference;
  final String stimulationLevel;
  final String readingSupportLevel;
  final bool voiceEnabled;
  final String? displayName;
}
