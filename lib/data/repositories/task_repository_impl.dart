import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/mappers/task_mapper.dart';
import '../../domain/tasks/task_model.dart';
import '../../domain/tasks/task_state_snapshot.dart';
import '../../domain/tasks/task_step_model.dart';

class TaskRepositoryImpl {
  TaskRepositoryImpl(this._client);

  final SupabaseClient _client;

  Future<({TaskModel task, List<TaskStepModel> steps, List<TaskStepModel> minimumVersion})> createTask({
    required String userId,
    required String sourceText,
    required TaskStateSnapshot snapshot,
  }) async {
    debugPrint('Creating task for user: $userId, text: $sourceText');
    late final Map<String, dynamic> data;

    try {
      final response = await _client.functions.invoke(
        'create-task',
        body: <String, dynamic>{
          'sourceText': sourceText,
          'mode': snapshot.mode.name,
          'energyLevel': snapshot.energyLevel.name,
          'stressLevel': snapshot.stressLevel.name,
          'timeAvailable': switch (snapshot.timeAvailable) {
            TimeAvailable.twoMinutes => '2m',
            TimeAvailable.fiveMinutes => '5m',
            TimeAvailable.fifteenMinutes => '15m',
            TimeAvailable.thirtyPlus => '30m_plus',
          },
        },
      );

      data = Map<String, dynamic>.from(response.data as Map);
      debugPrint('Supabase function succeeded: $data');
    } catch (error) {
      debugPrint('Supabase function failed, using fallback: $error');
      data = _localTaskFallback(sourceText, snapshot);
    }

    debugPrint('Inserting task into database...');
    final taskRow = await _client.from('tasks').insert(<String, dynamic>{
      'user_id': userId,
      'source_text': sourceText,
      'normalized_title': data['normalizedTitle'],
      'category': data['category'],
      'status': 'active',
      'mode_used': _modeToDb(snapshot.mode),
      'energy_level': snapshot.energyLevel.name,
      'stress_level': snapshot.stressLevel.name,
      'time_available': _timeToDb(snapshot.timeAvailable),
      'effort_band': data['effortBand'],
      'estimated_minutes': data['estimatedMinutes'],
      'state_snapshot': snapshot.toJson(),
    }).select().single();

    debugPrint('Task inserted successfully: ${taskRow['id']}');
    final taskId = taskRow['id'] as String;

    final primarySteps = (data['primarySteps'] as List<dynamic>).asMap().entries.map((entry) {
      final step = Map<String, dynamic>.from(entry.value as Map);
      return <String, dynamic>{
        'task_id': taskId,
        'parent_step_id': null,
        'depth_level': 0,
        'sequence_no': entry.key + 1,
        'step_text': step['text'],
        'is_optional': step['isOptional'] ?? false,
        'is_minimum_path': false,
        'completion_status': 'pending',
      };
    }).toList();

    final minimumSteps = (data['minimumVersionSteps'] as List<dynamic>).asMap().entries.map((entry) {
      final step = Map<String, dynamic>.from(entry.value as Map);
      return <String, dynamic>{
        'task_id': taskId,
        'parent_step_id': null,
        'depth_level': 0,
        'sequence_no': entry.key + 1,
        'step_text': step['text'],
        'is_optional': false,
        'is_minimum_path': true,
        'completion_status': 'pending',
      };
    }).toList();

    final insertedPrimary = await _client.from('task_steps').insert(primarySteps).select();
    final insertedMinimum = await _client.from('task_steps').insert(minimumSteps).select();

    return (
      task: TaskMapper.fromTaskRow(taskRow),
      steps: (insertedPrimary as List<dynamic>).map((row) => TaskMapper.fromStepRow(Map<String, dynamic>.from(row as Map))).toList(),
      minimumVersion: (insertedMinimum as List<dynamic>).map((row) => TaskMapper.fromStepRow(Map<String, dynamic>.from(row as Map))).toList(),
    );
  }

  Future<List<TaskStepModel>> breakDownStep({
    required String stepId,
    required TaskStateSnapshot snapshot,
    required String stepText,
  }) async {
    late final Map<String, dynamic> data;

    try {
      final response = await _client.functions.invoke(
        'breakdown-step',
        body: <String, dynamic>{
          'stepText': stepText,
          'mode': snapshot.mode.name,
          'energyLevel': snapshot.energyLevel.name,
          'stressLevel': snapshot.stressLevel.name,
        },
      );
      data = Map<String, dynamic>.from(response.data as Map);
    } catch (error) {
      data = _localBreakdownFallback(stepText);
    }

    final parent = await _client.from('task_steps').select('task_id, depth_level').eq('id', stepId).single();
    final taskId = parent['task_id'] as String;
    final parentDepth = parent['depth_level'] as int;

    final substeps = (data['substeps'] as List<dynamic>).asMap().entries.map((entry) {
      final step = Map<String, dynamic>.from(entry.value as Map);
      return <String, dynamic>{
        'task_id': taskId,
        'parent_step_id': stepId,
        'depth_level': parentDepth + 1,
        'sequence_no': entry.key + 1,
        'step_text': step['text'],
        'is_optional': false,
        'is_minimum_path': false,
        'completion_status': 'pending',
      };
    }).toList();

    final inserted = await _client.from('task_steps').insert(substeps).select();
    return (inserted as List<dynamic>).map((row) => TaskMapper.fromStepRow(Map<String, dynamic>.from(row as Map))).toList();
  }

  Future<void> completeStep({
    required String userId,
    required String stepId,
  }) async {
    await _client.from('task_steps').update(<String, dynamic>{
      'completion_status': 'completed',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', stepId);

    final row = await _client.from('task_steps').select('task_id').eq('id', stepId).single();

    await _client.from('progress_logs').insert(<String, dynamic>{
      'user_id': userId,
      'task_id': row['task_id'],
      'step_id': stepId,
      'event_type': 'step_completed',
      'metadata': <String, dynamic>{},
    });
  }

  Map<String, dynamic> _localTaskFallback(String sourceText, TaskStateSnapshot snapshot) {
    final normalizedTitle = sourceText.trim().split(RegExp(r'[\.!?]')).first.trim();
    return <String, dynamic>{
      'normalizedTitle': normalizedTitle.isNotEmpty ? normalizedTitle : 'New task',
      'category': 'general',
      'effortBand': 'medium',
      'estimatedMinutes': 15,
      'primarySteps': <Map<String, dynamic>>[
        {
          'text': sourceText.trim().isEmpty ? 'Review and complete this task' : sourceText.trim(),
          'isOptional': false,
        }
      ],
      'minimumVersionSteps': <Map<String, dynamic>>[],
    };
  }

  Map<String, dynamic> _localBreakdownFallback(String stepText) {
    final normalized = stepText.trim();
    final splitSteps = normalized.split(RegExp(r'[\.!?]')).where((part) => part.trim().isNotEmpty).map((part) => part.trim()).take(3).toList();
    final fallbackSteps = splitSteps.length > 1
        ? splitSteps
        : normalized.split(' ').length > 6
            ? [normalized.split(' ').take((normalized.split(' ').length / 2).ceil()).join(' '), normalized.split(' ').skip((normalized.split(' ').length / 2).ceil()).join(' ')]
            : [normalized];

    return <String, dynamic>{
      'substeps': fallbackSteps
          .where((text) => text.isNotEmpty)
          .map((text) => <String, dynamic>{'text': text})
          .toList(),
    };
  }

  String _modeToDb(SupportMode mode) {
    return switch (mode) {
      SupportMode.adhd => 'adhd',
      SupportMode.autism => 'autism',
      SupportMode.audhd => 'audhd',
      SupportMode.executiveDysfunction => 'executive_dysfunction',
      SupportMode.burnout => 'burnout',
    };
  }

  String _timeToDb(TimeAvailable time) {
    return switch (time) {
      TimeAvailable.twoMinutes => '2m',
      TimeAvailable.fiveMinutes => '5m',
      TimeAvailable.fifteenMinutes => '15m',
      TimeAvailable.thirtyPlus => '30m_plus',
    };
  }
}
