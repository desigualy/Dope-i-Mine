enum StepStatus { pending, active, completed, skipped, paused }

class TaskStepModel {
  const TaskStepModel({
    required this.id,
    required this.taskId,
    required this.text,
    required this.sequenceNo,
    required this.depthLevel,
    this.parentStepId,
    this.isOptional = false,
    this.isMinimumPath = false,
    this.status = StepStatus.pending,
  });

  final String id;
  final String taskId;
  final String text;
  final int sequenceNo;
  final int depthLevel;
  final String? parentStepId;
  final bool isOptional;
  final bool isMinimumPath;
  final StepStatus status;

  TaskStepModel copyWith({
    String? id,
    String? taskId,
    String? text,
    int? sequenceNo,
    int? depthLevel,
    String? parentStepId,
    bool? isOptional,
    bool? isMinimumPath,
    StepStatus? status,
  }) {
    return TaskStepModel(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      text: text ?? this.text,
      sequenceNo: sequenceNo ?? this.sequenceNo,
      depthLevel: depthLevel ?? this.depthLevel,
      parentStepId: parentStepId ?? this.parentStepId,
      isOptional: isOptional ?? this.isOptional,
      isMinimumPath: isMinimumPath ?? this.isMinimumPath,
      status: status ?? this.status,
    );
  }
}
