class RoutineStepModel {
  const RoutineStepModel({
    required this.id,
    required this.routineId,
    required this.stepText,
    required this.sequenceNo,
    required this.depthLevel,
    this.parentStepId,
  });

  final String id;
  final String routineId;
  final String stepText;
  final int sequenceNo;
  final int depthLevel;
  final String? parentStepId;
}
