import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/mappers/task_mapper.dart';
import '../../domain/sidequests/side_quest_model.dart';
import '../../domain/tasks/task_model.dart';
import '../../domain/tasks/task_state_snapshot.dart';
import '../../domain/tasks/task_step_model.dart';
import 'task_templates.dart';

class TaskRepositoryImpl {
  TaskRepositoryImpl(this._client);

  final SupabaseClient _client;

  Future<
      ({
        TaskModel task,
        List<TaskStepModel> steps,
        List<TaskStepModel> minimumVersion,
        List<SideQuestModel> sideQuests,
      })> createTask({
    required String userId,
    required String sourceText,
    required TaskStateSnapshot snapshot,
  }) async {
    final template = TaskTemplateLibrary.findTemplate(sourceText);
    Map<String, dynamic> data;
    if (template != null) {
      data = localTaskFallback(sourceText, snapshot);
    } else {
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
      } catch (error) {
        debugPrint('Supabase create-task failed, using local fallback: $error');
        data = localTaskFallback(sourceText, snapshot);
      }
    }

    final normalizedTitle =
        (data['normalizedTitle'] as String?)?.trim().isNotEmpty == true
            ? data['normalizedTitle'] as String
            : _normalisedTitle(sourceText);
    final taskRow = await _client
        .from('tasks')
        .insert(<String, dynamic>{
          'user_id': userId,
          'source_text': sourceText,
          'normalized_title': normalizedTitle,
          'category': data['category'] as String? ?? 'general',
          'status': 'active',
          'mode_used': _modeToDb(snapshot.mode),
          'energy_level': snapshot.energyLevel.name,
          'stress_level': snapshot.stressLevel.name,
          'time_available': _timeToDb(snapshot.timeAvailable),
          'effort_band': data['effortBand'] as String? ?? 'medium',
          'estimated_minutes': data['estimatedMinutes'] as int? ?? 15,
          'state_snapshot': snapshot.toJson(),
        })
        .select()
        .single();

    final taskId = taskRow['id'] as String;
    final normalisedPrimarySteps = _normalisePrimarySteps(
      data['primarySteps'] as List<dynamic>? ?? const <dynamic>[],
      normalizedTitle,
    );
    final primarySteps = template == null
        ? _ensurePrimaryStepsAreTaskRelevant(
            normalisedPrimarySteps,
            sourceText: sourceText,
            normalizedTitle: normalizedTitle,
          )
        : normalisedPrimarySteps;
    final insertedPrimary = await _insertHierarchicalSteps(
      taskId: taskId,
      sections: primarySteps,
    );
    final insertedMinimum = await _insertMinimumSteps(
      taskId: taskId,
      minimumSteps:
          data['minimumVersionSteps'] as List<dynamic>? ?? const <dynamic>[],
    );
    final sideQuests = await _insertSideQuests(
      userId: userId,
      taskId: taskId,
      rawSideQuests: data['sideQuests'] as List<dynamic>? ?? const <dynamic>[],
    );

    return (
      task: TaskMapper.fromTaskRow(taskRow),
      steps: insertedPrimary.map(TaskMapper.fromStepRow).toList(),
      minimumVersion: insertedMinimum.map(TaskMapper.fromStepRow).toList(),
      sideQuests: sideQuests,
    );
  }

  Future<List<TaskStepModel>> breakDownStep({
    required String stepId,
    required TaskStateSnapshot snapshot,
    required String stepText,
  }) async {
    final parent = await _client
        .from('task_steps')
        .select('task_id, depth_level')
        .eq('id', stepId)
        .single();
    final taskId = parent['task_id'] as String;
    final parentDepth = parent['depth_level'] as int;
    final taskContext = await _fetchTaskContext(taskId);

    final existing = await _client
        .from('task_steps')
        .select()
        .eq('parent_step_id', stepId)
        .order('sequence_no');
    final existingRows = (existing as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
    final existingSteps = existingRows.map(TaskMapper.fromStepRow).toList();
    if (existingSteps.isNotEmpty &&
        !_shouldRegenerateExistingBreakdown(
          rows: existingRows,
          existingSteps: existingSteps,
          stepText: stepText,
          taskContext: taskContext,
        )) {
      return existingSteps;
    }

    final data = await _breakdownData(
      snapshot: snapshot,
      stepText: stepText,
      taskContext: taskContext,
    );
    final substepTexts = _normaliseBreakdownSubstepTexts(
      data['substeps'],
      stepText: stepText,
      taskText: taskContext.sourceText,
      taskTitle: taskContext.normalizedTitle,
    );
    final rows = await _replaceExistingOrBuildNewRows(
      taskId: taskId,
      stepId: stepId,
      parentDepth: parentDepth,
      existingRows: existingRows,
      substepTexts: substepTexts,
    );

    if (rows.isEmpty) return const <TaskStepModel>[];
    final rowsToInsert = rows
        .where((row) => row['id'] == null)
        .map((row) => Map<String, dynamic>.from(row)..remove('id'))
        .toList();
    final resultRows = rows.where((row) => row['id'] != null).toList();
    if (rowsToInsert.isNotEmpty) {
      final inserted = await _client.from('task_steps').insert(rowsToInsert).select();
      resultRows.addAll(
        (inserted as List<dynamic>)
            .map((row) => Map<String, dynamic>.from(row as Map)),
      );
    }

    resultRows.sort(
      (a, b) => (a['sequence_no'] as int).compareTo(b['sequence_no'] as int),
    );
    return resultRows.map(TaskMapper.fromStepRow).toList();
  }

  Future<List<Map<String, dynamic>>> _replaceExistingOrBuildNewRows({
    required String taskId,
    required String stepId,
    required int parentDepth,
    required List<Map<String, dynamic>> existingRows,
    required List<String> substepTexts,
  }) async {
    final desiredTexts = List<String>.from(substepTexts);
    while (desiredTexts.length < existingRows.length) {
      desiredTexts.add(_continuationMicroStepFor(desiredTexts.length));
    }

    final updatedRows = <Map<String, dynamic>>[];
    for (final entry in desiredTexts.asMap().entries) {
      final rowIndex = entry.key;
      final row = rowIndex < existingRows.length ? existingRows[rowIndex] : null;
      if (row != null) {
        final updated = await _client
            .from('task_steps')
            .update(<String, dynamic>{
              'step_text': entry.value,
              'sequence_no': rowIndex + 1,
              'completion_status': 'pending',
              'updated_at': DateTime.now().toIso8601String(),
            })
            .eq('id', row['id'] as String)
            .select()
            .single();
        updatedRows.add(Map<String, dynamic>.from(updated as Map));
      } else {
        updatedRows.add(<String, dynamic>{
          'id': null,
          'task_id': taskId,
          'parent_step_id': stepId,
          'depth_level': parentDepth + 1,
          'sequence_no': rowIndex + 1,
          'step_text': entry.value,
          'is_optional': false,
          'is_minimum_path': false,
          'completion_status': 'pending',
        });
      }
    }

    if (existingRows.isEmpty) {
      return desiredTexts.asMap().entries.map((entry) {
      return <String, dynamic>{
        'task_id': taskId,
        'parent_step_id': stepId,
        'depth_level': parentDepth + 1,
        'sequence_no': entry.key + 1,
        'step_text': entry.value,
        'is_optional': false,
        'is_minimum_path': false,
        'completion_status': 'pending',
      };
    }).toList();
    }

    return updatedRows;
  }

  Future<_TaskContext> _fetchTaskContext(String taskId) async {
    try {
      final row = await _client
          .from('tasks')
          .select('source_text, normalized_title')
          .eq('id', taskId)
          .single();
      return _TaskContext(
        sourceText: row['source_text'] as String?,
        normalizedTitle: row['normalized_title'] as String?,
      );
    } catch (error) {
      debugPrint('Warning: Could not load task context for breakdown: $error');
      return const _TaskContext();
    }
  }

  Future<Map<String, dynamic>> _breakdownData({
    required TaskStateSnapshot snapshot,
    required String stepText,
    required _TaskContext taskContext,
  }) async {
    // TEMPORARY BYPASS: The remote Edge Function currently ignores step specificity
    // and returns generic parent-task steps. We bypass it to use the newly improved
    // local fallback engine until the Edge Function can be deployed.
    /*
    try {
      final response = await _client.functions.invoke(
        'breakdown-step',
        body: <String, dynamic>{
          'stepText': stepText,
          'taskText': taskContext.sourceText,
          'taskTitle': taskContext.normalizedTitle,
          'mode': snapshot.mode.name,
          'energyLevel': snapshot.energyLevel.name,
          'stressLevel': snapshot.stressLevel.name,
          'timeAvailable': _timeToDb(snapshot.timeAvailable),
        },
      );
      if (response.data is Map) {
        return Map<String, dynamic>.from(response.data as Map);
      }
    } catch (error) {
      debugPrint('Supabase breakdown-step failed, using local fallback: $error');
    }
    */

    return localBreakdownFallback(
      stepText,
      taskText: taskContext.sourceText,
      taskTitle: taskContext.normalizedTitle,
    );
  }

  Future<void> completeStep({
    required String userId,
    required String stepId,
  }) async {
    await _client.from('task_steps').update(<String, dynamic>{
      'completion_status': 'completed',
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('id', stepId);

    final row = await _client
        .from('task_steps')
        .select('task_id')
        .eq('id', stepId)
        .single();

    await _client.from('progress_logs').insert(<String, dynamic>{
      'user_id': userId,
      'task_id': row['task_id'],
      'step_id': stepId,
      'event_type': 'step_completed',
      'metadata': <String, dynamic>{},
    });

    try {
      await _client.from('rewards').insert(<String, dynamic>{
        'user_id': userId,
        'reward_type': 'xp',
        'reward_key': 'step_completed',
        'amount': 10,
        'source_type': 'step',
        'source_id': stepId,
      });
    } catch (error) {
      debugPrint('Warning: Could not award step reward: $error');
    }
  }

  Future<List<Map<String, dynamic>>> _insertHierarchicalSteps({
    required String taskId,
    required List<Map<String, dynamic>> sections,
  }) async {
    final inserted = <Map<String, dynamic>>[];
    for (final entry in sections.asMap().entries) {
      final section = entry.value;
      final insertedSection = await _client
          .from('task_steps')
          .insert(<String, dynamic>{
            'task_id': taskId,
            'parent_step_id': null,
            'depth_level': 0,
            'sequence_no': entry.key + 1,
            'step_text': section['text'],
            'is_optional': section['isOptional'] ?? false,
            'is_minimum_path': false,
            'completion_status': 'pending',
          })
          .select()
          .single();
      final sectionMap = Map<String, dynamic>.from(insertedSection as Map);
      inserted.add(sectionMap);

      final substeps =
          (section['substeps'] as List<dynamic>? ?? const <dynamic>[])
              .map((value) => Map<String, dynamic>.from(value as Map))
              .toList();
      if (substeps.isEmpty) continue;

      final rows = substeps.asMap().entries.map((subEntry) {
        final substep = subEntry.value;
        return <String, dynamic>{
          'task_id': taskId,
          'parent_step_id': sectionMap['id'],
          'depth_level': 1,
          'sequence_no': subEntry.key + 1,
          'step_text': substep['text'],
          'is_optional': substep['isOptional'] ?? false,
          'is_minimum_path': false,
          'completion_status': 'pending',
        };
      }).toList();
      final insertedSubsteps =
          await _client.from('task_steps').insert(rows).select();
      inserted.addAll(
        (insertedSubsteps as List<dynamic>)
            .map((row) => Map<String, dynamic>.from(row as Map)),
      );
    }
    return inserted;
  }

  Future<List<Map<String, dynamic>>> _insertMinimumSteps({
    required String taskId,
    required List<dynamic> minimumSteps,
  }) async {
    final rows = minimumSteps.asMap().entries.map((entry) {
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
    if (rows.isEmpty) return <Map<String, dynamic>>[];
    final inserted = await _client.from('task_steps').insert(rows).select();
    return (inserted as List<dynamic>)
        .map((row) => Map<String, dynamic>.from(row as Map))
        .toList();
  }

  Future<List<SideQuestModel>> _insertSideQuests({
    required String userId,
    required String taskId,
    required List<dynamic> rawSideQuests,
  }) async {
    final rows = rawSideQuests.asMap().entries.map((entry) {
      final quest = Map<String, dynamic>.from(entry.value as Map);
      return <String, dynamic>{
        'user_id': userId,
        'task_id': taskId,
        'title': quest['title'],
        'quest_type': quest['quest_type'] ?? quest['questType'] ?? 'bonus',
        'reward_xp': quest['reward_xp'] ?? quest['rewardXp'] ?? 10,
        'status': 'available',
      };
    }).toList();

    if (rows.isEmpty) return const <SideQuestModel>[];
    try {
      final inserted = await _client.from('side_quests').insert(rows).select();
      return (inserted as List<dynamic>)
          .map(
              (row) => _sideQuestFromRow(Map<String, dynamic>.from(row as Map)))
          .toList();
    } catch (error) {
      debugPrint('Warning: Could not insert side quests: $error');
      return rows.asMap().entries.map((entry) {
        final row = entry.value;
        return SideQuestModel(
          id: 'temp_${DateTime.now().microsecondsSinceEpoch}_${entry.key}',
          title: row['title'] as String,
          questType: row['quest_type'] as String,
          rewardXp: row['reward_xp'] as int,
          status: row['status'] as String,
          taskId: taskId,
        );
      }).toList();
    }
  }

  SideQuestModel _sideQuestFromRow(Map<String, dynamic> row) {
    return SideQuestModel(
      id: row['id'] as String,
      title: row['title'] as String,
      questType: row['quest_type'] as String,
      rewardXp: row['reward_xp'] as int,
      status: row['status'] as String,
      taskId: row['task_id'] as String?,
      routineId: row['routine_id'] as String?,
    );
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

@visibleForTesting
Map<String, dynamic> localTaskFallback(
  String sourceText,
  TaskStateSnapshot snapshot,
) {
  final template = TaskTemplateLibrary.findTemplate(sourceText);
  if (template != null) {
    final primarySteps = template.sections.length == 1
        ? template.sections.first.steps
            .map(
              (step) => <String, dynamic>{
                'text': step,
                'isOptional': false,
                'depthLevel': 0,
              },
            )
            .toList()
        : template.sections
            .map(
              (section) => <String, dynamic>{
                'text': section.title,
                'isOptional': false,
                'depthLevel': 0,
                'substeps': section.steps
                    .map(
                      (step) => <String, dynamic>{
                        'text': step,
                        'depthLevel': 1,
                      },
                    )
                    .toList(),
              },
            )
            .toList();

    return <String, dynamic>{
      'normalizedTitle': template.title,
      'category': template.category,
      'effortBand': _effortBandFor(
        template.sections
            .fold<int>(0, (total, section) => total + section.steps.length),
      ),
      'estimatedMinutes': template.estimatedMinutes,
      'primarySteps': primarySteps,
      'minimumVersionSteps': <Map<String, dynamic>>[
        <String, dynamic>{
          'text': 'Do just 5 minutes of ${template.title}',
          'depthLevel': 0,
        },
      ],
      'sideQuests': _sideQuestsForTemplate(template),
    };
  }

  final title = _normalisedTitle(sourceText);
  final genericSteps = _generateGenericBitesizeSteps(sourceText);
  return <String, dynamic>{
    'normalizedTitle': title,
    'category': 'general',
    'effortBand': _effortBandFor(genericSteps.length),
    'estimatedMinutes': (genericSteps.length * 3).clamp(10, 45),
    'primarySteps': genericSteps
        .map(
          (step) => <String, dynamic>{
            'text': step,
            'isOptional': false,
            'depthLevel': 0,
          },
        )
        .toList(),
    'minimumVersionSteps': <Map<String, dynamic>>[
      <String, dynamic>{'text': genericSteps.first, 'depthLevel': 0},
    ],
    'sideQuests': _defaultSideQuests(),
  };
}

@visibleForTesting
Map<String, dynamic> localBreakdownFallback(
  String stepText, {
  String? taskText,
  String? taskTitle,
}) {
  final section = TaskTemplateLibrary.findSection(stepText);
  final substeps = section?.steps ?? _generateMicroSteps(stepText, taskTitle: taskTitle, taskText: taskText);
  return <String, dynamic>{
    'substeps':
        substeps.map((text) => <String, dynamic>{'text': text}).toList(),
  };
}

List<String> _normaliseBreakdownSubstepTexts(
  dynamic rawSubsteps, {
  required String stepText,
  String? taskText,
  String? taskTitle,
}) {
  final mapped = (rawSubsteps as List<dynamic>? ?? const <dynamic>[])
      .map((value) {
        if (value is String) return value;
        if (value is Map) return value['text'] as String?;
        return null;
      })
      .whereType<String>()
      .map((text) => text.trim())
      .where((text) => text.isNotEmpty)
      .toList();

  final unique = <String>[];
  final seen = <String>{};
  for (final text in mapped) {
    final key = _normaliseForComparison(text);
    if (seen.add(key)) unique.add(text);
  }

  if (unique.isEmpty ||
      _hasGenericBreakdownSignature(unique) ||
      !_breakdownMentionsFocusWhenItShould(
        unique,
        stepText: stepText,
        taskText: taskText,
        taskTitle: taskTitle,
      )) {
    final fallback = localBreakdownFallback(
      stepText,
      taskText: taskText,
      taskTitle: taskTitle,
    );
    return (fallback['substeps'] as List<dynamic>)
        .map((step) => (step as Map<String, dynamic>)['text'] as String)
        .toList();
  }

  return unique;
}

bool _shouldRegenerateExistingBreakdown({
  required List<Map<String, dynamic>> rows,
  required List<TaskStepModel> existingSteps,
  required String stepText,
  required _TaskContext taskContext,
}) {
  if (rows.isEmpty || existingSteps.isEmpty) return false;
  final existingTexts = existingSteps.map((step) => step.text).toList();
  if (_hasGenericBreakdownSignature(existingTexts)) return true;
  return !_breakdownMentionsFocusWhenItShould(
    existingTexts,
    stepText: stepText,
    taskText: taskContext.sourceText,
    taskTitle: taskContext.normalizedTitle,
  );
}

List<Map<String, dynamic>> _ensurePrimaryStepsAreTaskRelevant(
  List<Map<String, dynamic>> sections, {
  required String sourceText,
  required String normalizedTitle,
}) {
  if (sections.isEmpty) return sections;

  final taskTokens = _meaningfulTokens('$sourceText $normalizedTitle');
  if (taskTokens.isEmpty) return sections;

  final allTexts = sections
      .expand((section) => <String>[
            section['text'] as String? ?? '',
            ...((section['substeps'] as List<dynamic>? ?? const <dynamic>[])
                .whereType<Map>()
                .map((step) => step['text'] as String? ?? '')),
          ])
      .where((text) => text.trim().isNotEmpty)
      .toList();
  final hasTaskAnchor = allTexts.any((text) => _containsAnyToken(text, taskTokens));
  if (hasTaskAnchor) return sections;

  return <Map<String, dynamic>>[
    <String, dynamic>{
      'text': normalizedTitle,
      'isOptional': false,
      'substeps': _generateGenericBitesizeSteps(sourceText)
          .map((step) => <String, dynamic>{'text': step})
          .toList(),
    },
  ];
}

List<Map<String, dynamic>> _normalisePrimarySteps(
  List<dynamic> rawSteps,
  String fallbackTitle,
) {
  final mapped = rawSteps
      .whereType<Map>()
      .map((step) => Map<String, dynamic>.from(step))
      .where((step) => (step['text'] as String?)?.trim().isNotEmpty == true)
      .toList();
  if (mapped.isEmpty) {
    return <Map<String, dynamic>>[
      <String, dynamic>{
        'text': fallbackTitle,
        'isOptional': false,
        'substeps': _generateGenericBitesizeSteps(fallbackTitle)
            .map((step) => <String, dynamic>{'text': step})
            .toList(),
      },
    ];
  }

  final hasHierarchy = mapped.any(
    (step) => (step['substeps'] as List<dynamic>?)?.isNotEmpty == true,
  );
  if (hasHierarchy) return mapped;

  return <Map<String, dynamic>>[
    <String, dynamic>{
      'text': fallbackTitle,
      'isOptional': false,
      'substeps': mapped
          .map((step) => <String, dynamic>{'text': step['text'] as String})
          .toList(),
    },
  ];
}

String _normalisedTitle(String sourceText) {
  final title = sourceText.trim().split(RegExp(r'[.!?]')).first.trim();
  return title.isEmpty ? 'New task' : title;
}

String _effortBandFor(int stepCount) {
  if (stepCount <= 8) return 'low';
  if (stepCount <= 24) return 'medium';
  return 'high';
}

List<Map<String, dynamic>> _sideQuestsForTemplate(TaskTemplate template) {
  final quests = template.sideQuests.isEmpty
      ? const <TaskTemplateSideQuest>[
          TaskTemplateSideQuest(
              title: 'Do one tiny helpful extra', rewardXp: 10),
        ]
      : template.sideQuests;
  return quests
      .map(
        (quest) => <String, dynamic>{
          'title': quest.title,
          'quest_type': quest.questType,
          'reward_xp': quest.rewardXp,
        },
      )
      .toList();
}

List<Map<String, dynamic>> _defaultSideQuests() {
  return const <Map<String, dynamic>>[
    <String, dynamic>{
      'title': 'Take 3 slow breaths before starting',
      'quest_type': 'sensory',
      'reward_xp': 10,
    },
    <String, dynamic>{
      'title': 'Put one extra item where it belongs',
      'quest_type': 'momentum',
      'reward_xp': 10,
    },
    <String, dynamic>{
      'title': 'Drink a sip of water',
      'quest_type': 'care',
      'reward_xp': 10,
    },
  ];
}

List<String> _generateGenericBitesizeSteps(String sourceText) {
  final text = sourceText.trim();
  if (text.isEmpty) {
    return const <String>['Notice the task', 'Do the easiest first action'];
  }

  final parts = text
      .split(RegExp(r'\s+and\s+|,|;', caseSensitive: false))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.length > 1) {
    return parts
        .expand((part) => <String>[
              'Get ready to: $part',
              'Do the first small part of: $part'
            ])
        .toList();
  }

  return <String>[
    'Look at what needs doing: $text',
    'Choose the easiest visible starting point',
    'Get only the thing you need first',
    'Do the first tiny action',
    'Pause and notice that you started',
    'Do one more small action if you can',
    'Check what is left',
    'Finish with one clear stopping point',
  ];
}

List<String> _generateMicroSteps(String stepText, {String? taskTitle, String? taskText}) {
  final stepLower = stepText.toLowerCase().trim();
  final contextLower = '${taskTitle ?? ''} ${taskText ?? ''}'.toLowerCase().trim();

  // 1. Exact Step-Level Actions (Highest Priority)
  if (stepLower.contains('pair') || stepLower.contains('match')) {
    return const <String>[
      'Find one item',
      'Look for its exact match',
      'Put them together',
      'Place them in the finished pile',
      'Look for the next item',
    ];
  }
  if (stepLower.contains('sort') || stepLower.contains('separate')) {
    return const <String>[
      'Pick one category to look for first',
      'Move matching items into one small pile',
      'Pick the next category',
      'Move those items into another pile',
      'Stop when the mixed pile is smaller',
    ];
  }
  if (stepLower.contains('stack') || stepLower.contains('pile')) {
    return const <String>[
      'Find the largest or heaviest items first',
      'Place them at the bottom',
      'Find the next size down',
      'Place them on top',
      'Repeat until everything is stacked safely',
    ];
  }
  if (stepLower.contains('clear') || stepLower.contains('wipe')) {
    return const <String>[
      'Look at the area you need to clear',
      'Remove one item that does not belong',
      'Put it where it goes',
      'Wipe the surface if needed',
      'Check if the area is clear',
    ];
  }
  if (stepLower.contains('drawer') || stepLower.contains('wardrobe') || stepLower.contains('hang')) {
    return const <String>[
      'Pick up the item',
      'Walk to the storage space',
      'Open the door or drawer',
      'Place or hang the item inside',
      'Close the door or drawer',
    ];
  }
  if (stepLower.contains('plug in') || stepLower.contains('turn on')) {
    return const <String>[
      'Find the cable or switch',
      'Check it is safe to use',
      'Plug it in or press the button',
      'Wait for it to turn on',
      'Move to the next step',
    ];
  }
  if (stepLower.contains('pocket')) {
    return const <String>[
      'Pick up one clothing item',
      'Put your hand in the first pocket',
      'Remove anything inside',
      'Check the other pockets',
      'Put the item into the wash pile',
    ];
  }
  if (stepLower.contains('scrape') || stepLower.contains('leftover')) {
    return const <String>[
      'Pick up one item with food on it',
      'Hold it over the bin',
      'Use a fork or scraper to remove the food',
      'Put the scraped item by the sink',
      'Repeat for the next item',
    ];
  }

  // 2. Task-Level Core Actions (Medium Priority)
  if (stepLower.contains('fold')) {
    return const <String>[
      'Pick up one item to fold',
      'Lay it flat or hold it',
      'Smooth it with your hands',
      'Fold it or place it on a hanger',
      'Place it in the finished pile',
    ];
  }
  if (stepLower.contains('wash') || stepLower.contains('rinse')) {
    return const <String>[
      'Pick up one item',
      'Wet or rinse it',
      'Add soap or use the soapy water',
      'Scrub the easiest visible area',
      'Rinse or place it to drain',
    ];
  }
  if (stepLower.contains('hoover') || stepLower.contains('vacuum')) {
    return const <String>[
      'Hold the hoover handle',
      'Place the head flat on the floor',
      'Push it forward slowly',
      'Pull it back over the same strip',
      'Move sideways and repeat',
    ];
  }
  if (stepLower.contains('bin') || stepLower.contains('rubbish') || stepLower.contains('trash')) {
    return const <String>[
      'Pick up the nearest rubbish item',
      'Check it is definitely rubbish',
      'Put it in the bag or bin',
      'Pick up one more rubbish item',
      'Pause and check the area',
    ];
  }

  // 3. Contextual Fallback (Low Priority)
  if (contextLower.contains('washing up') || contextLower.contains('dishes')) {
    return const <String>[
      'Look only at this item',
      'Move it closer to the sink',
      'Do the first small part of washing it',
      'Do the next small part',
      'Check if it is clean enough',
    ];
  }
  if (contextLower.contains('washing away') || contextLower.contains('laundry') || contextLower.contains('clothes') || contextLower.contains('fold')) {
    return const <String>[
      'Look only at the clothes for this step',
      'Pick up the first item',
      'Do the first small movement',
      'Place it where it belongs',
      'Check whether this pile is done',
    ];
  }
  if (contextLower.contains('clean') || contextLower.contains('hoover') || contextLower.contains('tidy')) {
    return const <String>[
      'Look only at this small area',
      'Get the tool you need',
      'Do the first small cleaning movement',
      'Do one more movement',
      'Check if this patch is done',
    ];
  }

  // 4. Absolute Generic Fallback
  return const <String>[
    'Look only at this step',
    'Get anything you need for it',
    'Do the first small movement',
    'Do one more small movement',
    'Check whether this step is done enough',
  ];
}

class _TaskContext {
  const _TaskContext({this.sourceText, this.normalizedTitle});
  final String? sourceText;
  final String? normalizedTitle;
}

String _resolveBreakdownFocus({
  required String stepText,
  String? taskText,
  String? taskTitle,
}) {
  return '$stepText ${taskTitle ?? ''} ${taskText ?? ''}'.trim();
}

String _continuationMicroStepFor(int index) {
  return 'Continue with the next small part';
}

String _normaliseForComparison(String text) {
  return text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '').trim();
}

bool _hasGenericBreakdownSignature(List<String> texts) {
  if (texts.isEmpty) return true;
  final combined = texts.join(' ').toLowerCase();
  if (combined.contains('do the first small movement') ||
      combined.contains('look only at this step') ||
      combined.contains('do one more small movement')) {
    return true;
  }
  return false;
}

bool _breakdownMentionsFocusWhenItShould(
  List<String> texts, {
  required String stepText,
  String? taskText,
  String? taskTitle,
}) {
  return true; 
}

List<String> _meaningfulTokens(String text) {
  return text.toLowerCase().split(RegExp(r'\s+')).where((t) => t.length > 3).toList();
}

bool _containsAnyToken(String text, List<String> tokens) {
  final lower = text.toLowerCase();
  return tokens.any((t) => lower.contains(t));
}

