import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/mappers/task_mapper.dart';
import '../../domain/tasks/task_model.dart';
import '../../domain/tasks/task_state_snapshot.dart';
import '../../domain/tasks/task_step_model.dart';
import '../../domain/sidequests/side_quest_model.dart';

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
    final taskRow = await _client
        .from('tasks')
        .insert(<String, dynamic>{
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
        })
        .select()
        .single();

    debugPrint('Task inserted successfully: ${taskRow['id']}');
    final taskId = taskRow['id'] as String;

    final primarySteps =
        (data['primarySteps'] as List<dynamic>).asMap().entries.map((entry) {
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

    final minimumSteps = (data['minimumVersionSteps'] as List<dynamic>)
        .asMap()
        .entries
        .map((entry) {
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

    final insertedPrimary =
        await _client.from('task_steps').insert(primarySteps).select();
    final insertedMinimum =
        await _client.from('task_steps').insert(minimumSteps).select();

    final sideQuestsData =
        (data['sideQuests'] as List<dynamic>? ?? []).map((dynamic q) {
      final quest = Map<String, dynamic>.from(q as Map);
      return <String, dynamic>{
        'user_id': userId,
        'task_id': taskId,
        'title': quest['title'],
        'quest_type': quest['quest_type'],
        'reward_xp': quest['reward_xp'],
        'status': 'available',
      };
    }).toList();

    final insertedSideQuests = sideQuestsData.isNotEmpty
        ? await _client.from('side_quests').insert(sideQuestsData).select()
        : [];

    return (
      task: TaskMapper.fromTaskRow(taskRow),
      steps: (insertedPrimary as List<dynamic>)
          .map((row) =>
              TaskMapper.fromStepRow(Map<String, dynamic>.from(row as Map)))
          .toList(),
      minimumVersion: (insertedMinimum as List<dynamic>)
          .map((row) =>
              TaskMapper.fromStepRow(Map<String, dynamic>.from(row as Map)))
          .toList(),
      sideQuests: (insertedSideQuests as List<dynamic>)
          .map((row) => SideQuestModel(
                id: row['id'] as String,
                title: row['title'] as String,
                questType: row['quest_type'] as String,
                rewardXp: row['reward_xp'] as int,
                status: row['status'] as String,
                taskId: row['task_id'] as String?,
              ))
          .toList(),
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

    final parent = await _client
        .from('task_steps')
        .select('task_id, depth_level')
        .eq('id', stepId)
        .single();
    final taskId = parent['task_id'] as String;
    final parentDepth = parent['depth_level'] as int;

    final substeps =
        (data['substeps'] as List<dynamic>).asMap().entries.map((entry) {
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
    return (inserted as List<dynamic>)
        .map((row) =>
            TaskMapper.fromStepRow(Map<String, dynamic>.from(row as Map)))
        .toList();
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

    // Award 10 XP for each step completed
    await _client.from('rewards').insert({
      'user_id': userId,
      'reward_type': 'xp',
      'reward_key': 'step_completed',
      'amount': 10,
      'source_type': 'step',
      'source_id': stepId,
    });
  }

  Map<String, dynamic> _localTaskFallback(
      String sourceText, TaskStateSnapshot snapshot) {
    return localTaskFallback(sourceText, snapshot);
  }

  Map<String, dynamic> _localBreakdownFallback(String stepText) {
    return localBreakdownFallback(stepText);
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
    String sourceText, TaskStateSnapshot snapshot) {
  final normalizedTitle =
      sourceText.trim().split(RegExp(r'[\.\!?]')).first.trim();
  final stepTexts = _generateActionableTaskSteps(sourceText.trim());
  final minimumVersion =
      _generateMinimumVersionSteps(sourceText.trim(), stepTexts);

  return <String, dynamic>{
    'normalizedTitle':
        normalizedTitle.isNotEmpty ? normalizedTitle : 'New task',
    'category': 'general',
    'effortBand': 'medium',
    'estimatedMinutes': 15,
    'primarySteps': stepTexts
        .map((text) => <String, dynamic>{
              'text': text,
              'isOptional': false,
            })
        .toList(),
    'minimumVersionSteps':
        minimumVersion.map((text) => <String, dynamic>{'text': text}).toList(),
    'sideQuests': <Map<String, dynamic>>[
      {
        'title': 'Take a deep breath before starting',
        'quest_type': 'mindfulness',
        'reward_xp': 20,
      }
    ],
  };
}

@visibleForTesting
Map<String, dynamic> localBreakdownFallback(String stepText) {
  final fallback = _generateActionableBreakdownSteps(stepText.trim());

  return <String, dynamic>{
    'substeps':
        fallback.map((text) => <String, dynamic>{'text': text}).toList(),
  };
}

List<String> _generateActionableTaskSteps(String text) {
  if (text.isEmpty) {
    return const ['Review and complete this task'];
  }

  final lower = text.toLowerCase();

  // Exact rich templates for common household tasks (provided by user)
    if (lower.contains('put washing away') ||
      (lower.contains('washing') && lower.contains('put'))) {
    return const <String>[
      'Collect the clean, dry laundry',
      'Put it all in one place, for example the bed or sofa',
      'Separate into piles: tops; trousers/shorts/skirts; underwear; socks; towels; bedding',
      'Fold each item neatly',
      'Pair socks together',
      'Hang clothes that need hanging',
      'Put folded clothes into the correct drawers',
      'Put towels in the bathroom cupboard or towel storage',
      'Put bedding in the airing cupboard or bedding drawer',
      'Check the area for anything you missed',
      'Put the laundry basket away',
    ];
  }

  if (lower.contains('washing up') ||
      lower.contains('wash the dishes') ||
      (lower.contains('wash') && lower.contains('dishes')) ||
      (lower.contains('dishes') && lower.contains('wash'))) {
    return const <String>[
      'Clear the sink area',
      'Scrape leftover food into the bin',
      'Stack dishes beside the sink: glasses first, then cutlery, then plates and bowls, pans last',
      'Fill the sink with hot water',
      'Add washing-up liquid',
      'Wash glasses first',
      'Wash cutlery',
      'Wash plates and bowls',
      'Wash pans and heavy items last',
      'Rinse items if needed',
      'Place clean items on the draining board',
      'Wipe the sink and taps',
      'Wipe the worktop',
      'Remove food from the plughole',
      'Dry items and put them away, or leave them to air dry',
    ];
  }

  if (lower.contains('hoover') || lower.contains('vacuum') || lower.contains('hoovering')) {
    return const <String>[
      'Pick up anything from the floor',
      'Move small items out of the way (shoes, bags, toys, boxes)',
      'Check for coins, cables, or small objects that could block the vacuum',
      'Plug in the vacuum',
      'Start at the far side of the room',
      'Vacuum slowly in straight lines',
      'Vacuum around the edges of the room',
      'Vacuum under furniture where possible',
      'Move light furniture if needed',
      'Vacuum the middle of the room',
      'Use the nozzle attachment for corners and skirting boards',
      'Check the floor for missed spots',
      'Turn off and unplug the vacuum',
      'Empty the vacuum if full',
      'Put the vacuum away',
    ];
  }

  if (lower.contains('make the bed') || lower.contains('making a bed') || lower.contains('make bed')) {
    return const <String>[
      'Clear anything off the bed',
      'Pull the fitted sheet flat',
      'Tuck in the corners if needed',
      'Shake out the duvet',
      'Lay the duvet evenly on the bed',
      'Pull the duvet up to the top',
      'Straighten both sides',
      'Plump the pillows',
      'Place the pillows at the head of the bed',
      'Add cushions or blankets if used',
      'Check the bed looks neat',
    ];
  }

  if (lower.contains('change the bed') || lower.contains('changing a bed') || lower.contains('change bedding')) {
    return const <String>[
      'Remove pillows from the bed',
      'Take off the pillowcases',
      'Remove the duvet cover',
      'Remove the fitted sheet',
      'Put dirty bedding into the laundry basket',
      'Get clean bedding: fitted sheet, duvet cover, pillowcases',
      'Put the clean fitted sheet on the mattress',
      'Make sure each corner is secure',
      'Put the duvet into the clean duvet cover',
      'Hold the top corners and shake the duvet down',
      'Fasten buttons, poppers, or the zipper',
      'Put clean pillowcases on the pillows',
      'Return pillows to the head of the bed',
      'Lay the duvet evenly',
      'Straighten everything',
      'Put dirty bedding near the washing machine or laundry area',
    ];
  }

  if (lower.contains('put on a wash') || lower.contains('putting on a wash') || (lower.contains('put') && lower.contains('wash'))) {
    return const <String>[
      'Collect the dirty laundry',
      'Separate laundry into piles: whites; colours; darks; towels; bedding; delicates',
      'Check clothing labels if unsure',
      'Check pockets for tissues, coins, keys, or paper',
      'Turn delicate or printed clothes inside out',
      'Load one wash into the washing machine',
      'Do not overfill the drum',
      'Add detergent to the correct drawer or directly into the drum',
      'Add fabric softener if used',
      'Close the washing machine door',
      'Choose the correct wash setting',
      'Select the temperature',
      'Press start',
      'When finished, remove the washing promptly',
      'Hang it up, put it in the dryer, or place it on an airer',
    ];
  }

  if (lower.contains('bin') || lower.contains('take out the bin') || lower.contains('empty bin') || lower.contains('throw out the bin')) {
    return const <String>[
      'Check whether the bin is full or needs emptying',
      'Press down the rubbish gently if needed',
      'Tie the bin bag securely',
      'Lift the bag out carefully',
      'Check for leaks',
      'If leaking, double-bag it',
      'Take the bag to the outside bin',
      'Put it in the correct outside bin: general waste, recycling, food waste, garden waste',
      'Close the outside bin lid',
      'Put a new bin bag into the indoor bin',
      'Wipe the bin lid if dirty',
      'Wash your hands',
    ];
  }

  if (_mentionsLaundryPutAway(lower)) {
    return const <String>[
      'Bring the clean washing to one place',
      'Sort the clothes into small piles',
      'Fold or hang one pile at a time',
      'Put each pile into the right drawer or wardrobe',
    ];
  }

  if (lower.contains('laundry') ||
      lower.contains('washing') ||
      lower.contains('clothes')) {
    return const <String>[
      'Collect the laundry into one place',
      'Sort items by type or where they belong',
      'Handle one small group at a time',
      'Put the finished clothes away',
    ];
  }

  if (lower.contains('clean') || lower.contains('tidy')) {
    return const <String>[
      'Get the things you need to clean',
      'Clear one small area first',
      'Clean that area',
      'Put items back neatly and bin any rubbish',
    ];
  }

  if (lower.contains('email') || lower.contains('respond')) {
    return const <String>[
      'Open your email inbox',
      'Pick the first email to deal with',
      'Write a short clear reply',
      'Send it and move to the next one',
    ];
  }

  if (lower.contains('dish') || lower.contains('washing up')) {
    return const <String>[
      'Take the dishes to the sink',
      'Wash or rinse one group at a time',
      'Dry or drain the clean dishes',
      'Put the dishes away',
    ];
  }

  if (lower.contains('bin') ||
      lower.contains('trash') ||
      lower.contains('rubbish')) {
    return const <String>[
      'Collect the rubbish into one bag',
      'Tie the bag and take it out',
      'Put a fresh bag in the bin',
    ];
  }

  final sentences = text
      .split(RegExp(r'[\.\!?]'))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();

  if (sentences.length > 1) {
    return sentences;
  }

  final words =
      text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();

  final conjunctionSegments = text
      .split(RegExp(r'\s+and\s+|,|;', caseSensitive: false))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (conjunctionSegments.length > 1 &&
      conjunctionSegments.any((part) =>
          part.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length >
          2)) {
    return conjunctionSegments;
  }

  if (words.length <= 8) {
    final actionVerbs = [
      'clean', 'wash', 'fold', 'sort', 'organize', 'check', 'review', 'prepare',
      'gather', 'collect', 'put', 'buy', 'pay', 'call', 'cook', 'email', 'respond', 'tidy'
    ];

    final foundVerb = words.firstWhere(
        (w) => actionVerbs.any((v) => w.contains(v)),
        orElse: () => '');

    final verbTemplates = <String, List<String>>{
      'put': [
        'Gather the items to put away',
        'Put away one small pile or one item at a time',
        'Store items in the right place and stop',
      ],
      'wash': [
        'Collect the laundry to wash',
        'Wash or handle one small load/item',
        'Dry/put away the washed items',
      ],
      'clean': [
        'Choose one small area to clean',
        'Clear clutter from that area',
        'Wipe/clean the area and tidy up',
      ],
      'email': [
        'Open your email inbox',
        'Pick one message and draft a short reply',
        'Send the reply and mark it done',
      ],
      'call': [
        'Find the contact details',
        'Make the call and say the key points',
        'Note any follow-ups and finish',
      ],
    };

    if (foundVerb.isNotEmpty && verbTemplates.containsKey(foundVerb)) {
      return verbTemplates[foundVerb]!;
    }

    if (foundVerb.isNotEmpty) {
      final object = words.where((w) => w != foundVerb).join(' ').trim();
      final objDisplay = object.isNotEmpty ? ' $object' : '';
      return <String>[
        'Prepare to ${foundVerb}${objDisplay}',
        'Do one small part: ${foundVerb}${objDisplay}',
        'Finish and check off: ${foundVerb}${objDisplay}',
      ];
    }

    return <String>[
      'Get ready to start: $text',
      'Do one small part of: $text',
      'Finish and check off: $text',
    ];
  }

  final midpoint = (words.length / 2).ceil();
  final firstHalf = words.sublist(0, midpoint).join(' ');
  final secondHalf = words.sublist(midpoint).join(' ');

  return <String>[
    'Start with: $firstHalf',
    'Then do: $secondHalf',
    'Check that the task is fully done',
  ];
}

List<String> _generateMinimumVersionSteps(
    String text, List<String> primarySteps) {
  final lower = text.toLowerCase();
  if (_mentionsLaundryPutAway(lower)) {
    return const <String>['Put away just one small pile of washing'];
  }
  if (lower.contains('laundry') ||
      lower.contains('washing') ||
      lower.contains('clothes')) {
    return const <String>['Put away one or two items of clothing'];
  }
  if (lower.contains('clean') || lower.contains('tidy')) {
    return const <String>['Clean just one small area'];
  }
  if (lower.contains('email') || lower.contains('respond')) {
    return const <String>['Reply to just one email'];
  }
  return primarySteps.isEmpty
      ? <String>['Do the easiest first part']
      : <String>[primarySteps.first];
}

List<String> _generateActionableBreakdownSteps(String text) {
  if (text.isEmpty) {
    return const <String>['Do one tiny part', 'Check if it is finished'];
  }

  final lower = text.toLowerCase();

  // Rich breakdowns for well-known steps/tasks
  if (lower.contains('put washing away') ||
      (lower.contains('washing') && lower.contains('put'))) {
    return const <String>[
      'Collect the clean dry washing.',
      'Put it all in one place, such as on the bed or sofa.',
      'Separate it into piles: Tops, Trousers/shorts/skirts, Underwear, Socks, Towels, Bedding',
      'Fold each item neatly.',
      'Pair socks together.',
      'Put hanging clothes on hangers.',
      'Put folded clothes into the correct drawers.',
      'Put towels in the bathroom cupboard or towel storage.',
      'Put bedding in the airing cupboard or bedding drawer.',
      'Check the area for anything missed.',
      'Put the laundry basket away.',
    ];
  }

  if (lower.contains('washing up') ||
      lower.contains('wash the dishes') ||
      (lower.contains('wash') && lower.contains('dishes'))) {
    return const <String>[
      'Clear the sink area.',
      'Scrape leftover food into the bin.',
      'Stack dishes beside the sink: Glasses first, Cutlery, Plates and bowls, Pans last',
      'Fill the sink with hot water.',
      'Add washing-up liquid.',
      'Wash glasses first.',
      'Wash cutlery.',
      'Wash plates and bowls.',
      'Wash pans and dirty cooking items last.',
      'Rinse items if needed.',
      'Put clean items on the draining board.',
      'Wipe the sink and taps.',
      'Wipe the worktop.',
      'Empty food bits from the plughole.',
      'Dry items and put them away, or leave them to air dry.',
    ];
  }

  if (_mentionsLaundryPutAway(lower) ||
      lower.contains('fold') ||
      lower.contains('hang') ||
      lower.contains('put the finished clothes away') ||
      lower.contains('put the clothes away')) {
    return const <String>[
      'Pick up one item',
      'Fold it or hang it up',
      'Put it in the right place',
      'Repeat with the next item',
    ];
  }

  if (lower.contains('clear one small area')) {
    return const <String>[
      'Choose one surface or corner',
      'Remove anything that does not belong there',
      'Put those items into a temporary pile or basket',
    ];
  }

  if (lower.contains('vacuum') || lower.contains('hoover')) {
    return const <String>[
      'Pick up small items from the floor',
      'Plug in the vacuum cleaner',
      'Vacuum one section of the room at a time',
    ];
  }

  if (lower.contains('email') || lower.contains('respond')) {
    return const <String>[
      'Open the email or message',
      'Read the key points to respond to',
      'Type a short, clear draft',
      'Check for errors and press send',
    ];
  }

  if (lower.contains('tidy') || lower.contains('clean')) {
    return const <String>[
      'Gather the tools you need (cloth, spray, etc.)',
      'Clear the space of any clutter',
      'Wipe or clean the surface',
      'Put your tools away',
    ];
  }

  final conjunctionParts = text
      .split(RegExp(r'\s+(and|or|then|after|before|while)\s+',
          caseSensitive: false))
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList();
  if (conjunctionParts.length > 1) {
    return conjunctionParts;
  }

  final words =
      text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty).toList();
  if (words.length <= 8) {
    final actionVerbs = [
      'clean', 'wash', 'fold', 'sort', 'organize', 'check', 'review', 'prepare',
      'gather', 'collect', 'put', 'buy', 'pay', 'call', 'cook', 'email', 'respond', 'tidy'
    ];

    final foundVerb = words.firstWhere(
        (w) => actionVerbs.any((v) => w.contains(v)),
        orElse: () => '');

    if (foundVerb.isNotEmpty) {
      final object = words.where((w) => w != foundVerb).join(' ').trim();
      final objDisplay = object.isNotEmpty ? ' $object' : '';
      return <String>[
        'Prepare to ${foundVerb}${objDisplay}',
        'Do one small part: ${foundVerb}${objDisplay}',
        'Check whether ${foundVerb}${objDisplay} is finished',
      ];
    }

    return <String>[
      'Get ready to do this step',
      'Do one small part of it',
      'Check whether this step is done',
    ];
  }

  final midpoint = (words.length / 2).ceil();
  return <String>[
    words.sublist(0, midpoint).join(' '),
    words.sublist(midpoint).join(' '),
    'Check whether this step is finished',
  ];
}

bool _mentionsLaundryPutAway(String lower) {
  final mentionsLaundry = lower.contains('laundry') ||
      lower.contains('washing') ||
      lower.contains('clothes');
  final mentionsPutAway = lower.contains('put away') ||
      lower.contains('put the') ||
      lower.contains('fold') ||
      lower.contains('hang');
  return mentionsLaundry && mentionsPutAway;
}
