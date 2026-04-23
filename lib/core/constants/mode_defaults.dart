import '../../domain/tasks/task_state_snapshot.dart';

class ModeDefaults {
  static bool rewardsEnabled(SupportMode mode) {
    switch (mode) {
      case SupportMode.burnout:
        return false;
      default:
        return true;
    }
  }
}
