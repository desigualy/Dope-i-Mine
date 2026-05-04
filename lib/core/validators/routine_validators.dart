import '../errors/app_failure.dart';

void validateRoutineTitle(String value) {
  if (value.trim().isEmpty) {
    throw const AppFailure(
      'Please name the routine.',
      code: 'empty_routine_title',
    );
  }
}

void validateRoutineSteps(List<String> steps) {
  final cleanSteps = steps.where((step) => step.trim().isNotEmpty).toList();
  if (cleanSteps.isEmpty) {
    throw const AppFailure(
      'Add at least one routine step.',
      code: 'empty_routine_steps',
    );
  }
}
