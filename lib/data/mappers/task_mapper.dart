import '../../domain/tasks/task_model.dart';
import '../../domain/tasks/task_step_model.dart';

class TaskMapper {
  static TaskModel fromTaskRow(Map<String, dynamic> row) {
    return TaskModel(
      id: row['id'] as String,
      normalizedTitle: row['normalized_title'] as String,
      effortBand: row['effort_band'] as String? ?? 'medium',
      estimatedMinutes: row['estimated_minutes'] as int? ?? 10,
      category: row['category'] as String?,
    );
  }

  static TaskStepModel fromStepRow(Map<String, dynamic> row) {
    return TaskStepModel(
      id: row['id'] as String,
      taskId: row['task_id'] as String,
      text: row['step_text'] as String,
      sequenceNo: row['sequence_no'] as int,
      depthLevel: row['depth_level'] as int,
      parentStepId: row['parent_step_id'] as String?,
      isOptional: row['is_optional'] as bool? ?? false,
      isMinimumPath: row['is_minimum_path'] as bool? ?? false,
      status: _statusFromDb(row['completion_status'] as String? ?? 'pending'),
    );
  }

  static StepStatus _statusFromDb(String value) {
    switch (value) {
      case 'active':
        return StepStatus.active;
      case 'completed':
        return StepStatus.completed;
      case 'skipped':
        return StepStatus.skipped;
      case 'paused':
        return StepStatus.paused;
      default:
        return StepStatus.pending;
    }
  }
}
