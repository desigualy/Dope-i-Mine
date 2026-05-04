import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/routines/routine_model.dart';
import '../../domain/routines/routine_step_model.dart';
import 'local_json_store.dart';

final localRoutineStoreProvider = Provider<LocalRoutineStore>((ref) {
  return LocalRoutineStore();
});

class LocalRoutineStore {
  LocalRoutineStore({LocalJsonStore? store})
      : _store = store ?? LocalJsonStore('dope_i_mine.local.routines.v1');

  final LocalJsonStore _store;
  static const String _routinesKey = 'routines';
  static const String _stepsKey = 'steps';

  Future<void> saveRoutine(RoutineModel routine, List<RoutineStepModel> steps) async {
    final routines = await _store.readList(_routinesKey);
    final allSteps = await _store.readList(_stepsKey);
    await _store.writeList(_routinesKey, <Map<String, dynamic>>[
      ...routines.where((row) => row['id'] != routine.id),
      _routineToJson(routine),
    ]);
    await _store.writeList(_stepsKey, <Map<String, dynamic>>[
      ...allSteps.where((row) => row['routineId'] != routine.id),
      ...steps.map(_stepToJson),
    ]);
  }

  Future<List<RoutineModel>> loadRoutines() async {
    final rows = await _store.readList(_routinesKey);
    return rows.map(_routineFromJson).toList();
  }

  Future<List<RoutineStepModel>> loadSteps(String routineId) async {
    final rows = await _store.readList(_stepsKey);
    return rows
        .where((row) => row['routineId'] == routineId)
        .map(_stepFromJson)
        .toList()
      ..sort((a, b) => a.sequenceNo.compareTo(b.sequenceNo));
  }

  Future<void> deleteRoutine(String routineId) async {
    final routines = await _store.readList(_routinesKey);
    final steps = await _store.readList(_stepsKey);
    await _store.writeList(
      _routinesKey,
      routines.where((row) => row['id'] != routineId).toList(),
    );
    await _store.writeList(
      _stepsKey,
      steps.where((row) => row['routineId'] != routineId).toList(),
    );
  }

  Map<String, dynamic> _routineToJson(RoutineModel routine) => <String, dynamic>{
        'id': routine.id,
        'title': routine.title,
        'ageBand': routine.ageBand,
        'category': routine.category,
        'modeTarget': routine.modeTarget,
      };

  RoutineModel _routineFromJson(Map<String, dynamic> json) => RoutineModel(
        id: json['id'] as String,
        title: json['title'] as String? ?? 'Routine',
        ageBand: json['ageBand'] as String? ?? 'adult',
        category: json['category'] as String?,
        modeTarget: json['modeTarget'] as String?,
      );

  Map<String, dynamic> _stepToJson(RoutineStepModel step) => <String, dynamic>{
        'id': step.id,
        'routineId': step.routineId,
        'stepText': step.stepText,
        'sequenceNo': step.sequenceNo,
        'depthLevel': step.depthLevel,
        'parentStepId': step.parentStepId,
      };

  RoutineStepModel _stepFromJson(Map<String, dynamic> json) => RoutineStepModel(
        id: json['id'] as String,
        routineId: json['routineId'] as String,
        stepText: json['stepText'] as String? ?? 'Step',
        sequenceNo: json['sequenceNo'] as int? ?? 0,
        depthLevel: json['depthLevel'] as int? ?? 0,
        parentStepId: json['parentStepId'] as String?,
      );
}
