class ReminderModel {
  const ReminderModel({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAtIso,
    required this.enabled,
  });

  final String id;
  final String title;
  final String body;
  final String scheduledAtIso;
  final bool enabled;
}
