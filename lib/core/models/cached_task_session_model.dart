class CachedTaskSessionModel {
  const CachedTaskSessionModel({
    required this.taskId,
    required this.currentStepIndex,
    required this.showOnlyCurrentStep,
    required this.showMinimumVersion,
    required this.paused,
    required this.updatedAtIso,
  });

  final String taskId;
  final int currentStepIndex;
  final bool showOnlyCurrentStep;
  final bool showMinimumVersion;
  final bool paused;
  final String updatedAtIso;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'taskId': taskId,
      'currentStepIndex': currentStepIndex,
      'showOnlyCurrentStep': showOnlyCurrentStep,
      'showMinimumVersion': showMinimumVersion,
      'paused': paused,
      'updatedAtIso': updatedAtIso,
    };
  }

  factory CachedTaskSessionModel.fromJson(Map<String, dynamic> json) {
    return CachedTaskSessionModel(
      taskId: json['taskId'] as String,
      currentStepIndex: json['currentStepIndex'] as int,
      showOnlyCurrentStep: json['showOnlyCurrentStep'] as bool,
      showMinimumVersion: json['showMinimumVersion'] as bool,
      paused: json['paused'] as bool,
      updatedAtIso: json['updatedAtIso'] as String,
    );
  }
}
