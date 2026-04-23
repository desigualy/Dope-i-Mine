import '../errors/app_failure.dart';

void validateTaskText(String value) { if (value.trim().isEmpty) { throw const AppFailure('Please enter a task first.', code: 'empty_task'); } if (value.trim().length < 3) { throw const AppFailure('Task is too short to break down properly.', code: 'task_too_short'); } }
