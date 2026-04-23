import '../errors/app_failure.dart';

void validateRoutineTitle(String value) { if (value.trim().isEmpty) { throw const AppFailure('Please name the routine.', code: 'empty_routine_title'); } }
