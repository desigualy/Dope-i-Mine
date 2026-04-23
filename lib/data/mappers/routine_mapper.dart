import '../../domain/routines/routine_model.dart';
import '../../domain/routines/routine_step_model.dart';

class RoutineMapper {
  static RoutineModel fromRoutineRow(Map<String, dynamic> row) {
    return RoutineModel(
      id: row['id'] as String,
      title: row['title'] as String,
      ageBand: row['age_band'] as String,
      category: row['category'] as String?,
      modeTarget: row['mode_target'] as String?,
    );
  }

  static RoutineStepModel fromRoutineStepRow(Map<String, dynamic> row) {
    return RoutineStepModel(
      id: row['id'] as String,
      routineId: row['routine_id'] as String,
      stepText: row['step_text'] as String,
      sequenceNo: row['sequence_no'] as int,
      depthLevel: row['depth_level'] as int,
      parentStepId: row['parent_step_id'] as String?,
    );
  }
}
