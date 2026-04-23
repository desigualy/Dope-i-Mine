class RoutineModel {
  const RoutineModel({
    required this.id,
    required this.title,
    required this.ageBand,
    this.category,
    this.modeTarget,
  });

  final String id;
  final String title;
  final String ageBand;
  final String? category;
  final String? modeTarget;
}
