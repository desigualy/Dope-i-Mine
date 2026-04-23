import '../../domain/tasks/task_state_snapshot.dart';

extension AgeBandLabel on AgeBand {
  String get label => name;
}

extension SupportModeLabel on SupportMode {
  String get label => name;
}
