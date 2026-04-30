class TaskTemplate {
  const TaskTemplate({
    required this.id,
    required this.title,
    required this.sections,
    this.category = 'household',
    this.estimatedMinutes = 30,
    this.sideQuests = const <TaskTemplateSideQuest>[],
  });

  final String id;
  final String title;
  final String category;
  final int estimatedMinutes;
  final List<TaskTemplateSection> sections;
  final List<TaskTemplateSideQuest> sideQuests;
}

class TaskTemplateSection {
  const TaskTemplateSection({
    required this.title,
    required this.steps,
  });

  final String title;
  final List<String> steps;
}

class TaskTemplateSideQuest {
  const TaskTemplateSideQuest({
    required this.title,
    required this.rewardXp,
    this.questType = 'bonus',
  });

  final String title;
  final int rewardXp;
  final String questType;
}

class TaskTemplateLibrary {
  static const Map<String, TaskTemplate> templates = <String, TaskTemplate>{
    'put_washing_away': TaskTemplate(
      id: 'put_washing_away',
      title: 'Put washing away',
      estimatedMinutes: 25,
      sections: <TaskTemplateSection>[
        TaskTemplateSection(
          title: 'Putting the washing away',
          steps: <String>[
            'Collect the clean, dry washing',
            'Put it all in one clear place, like the bed or sofa',
            'Check whether anything is still damp and set it aside',
            'Separate items into piles: tops, bottoms, underwear, socks, towels, bedding',
            'Make a separate pile for anything that needs hanging',
            'Fold each item neatly',
            'Pair socks together',
            'Hang clothes that need hanging',
            'Put folded clothes into the correct drawers',
            'Put towels or bedding into their storage place',
            'Check the area for anything you missed',
            'Put the empty laundry basket away',
          ],
        ),
      ],
      sideQuests: <TaskTemplateSideQuest>[
        TaskTemplateSideQuest(
            title: 'Put one extra item away',
            rewardXp: 10,
            questType: 'momentum'),
        TaskTemplateSideQuest(
            title: 'Match one lonely sock if you spot one', rewardXp: 15),
      ],
    ),
    'washing_up': TaskTemplate(
      id: 'washing_up',
      title: 'Washing up',
      estimatedMinutes: 25,
      sections: <TaskTemplateSection>[
        TaskTemplateSection(
          title: 'Washing up',
          steps: <String>[
            'Clear a space on the draining board',
            'Put away anything clean that is already on the draining board',
            'Scrape leftover food into the bin',
            'Stack dishes beside the sink: glasses, cutlery, plates, bowls, pans',
            'Fill the sink with hot water',
            'Add washing-up liquid',
            'Wash glasses and mugs first',
            'Wash cutlery next',
            'Wash plates and bowls',
            'Wash serving dishes',
            'Wash pans and greasy items last',
            'Rinse items if they need it',
            'Place clean items safely on the draining board',
            'Drain the sink and remove food from the plughole',
            'Wipe the sink, taps, and nearby worktop',
            'Dry and put away items, or leave them neatly to air dry',
          ],
        ),
      ],
      sideQuests: <TaskTemplateSideQuest>[
        TaskTemplateSideQuest(
            title: 'Wipe the worktop after washing up',
            rewardXp: 15,
            questType: 'shine'),
        TaskTemplateSideQuest(title: 'Put away three dry items', rewardXp: 10),
      ],
    ),
    'hoover_room': TaskTemplate(
      id: 'hoover_room',
      title: 'Hoovering a room',
      estimatedMinutes: 20,
      sections: <TaskTemplateSection>[
        TaskTemplateSection(
          title: 'Hoovering a room',
          steps: <String>[
            'Pick up anything loose from the floor',
            'Move shoes, bags, toys, or boxes out of the way',
            'Check for coins, cables, or tiny objects that could block the hoover',
            'Move small furniture if it is safe and easy',
            'Check whether the hoover cylinder or bag is full',
            'Check that the brush bar is clear enough to turn',
            'Plug in the hoover',
            'Start at the far side of the room',
            'Hoover slowly in overlapping lines',
            'Hoover around the edges of the room',
            'Hoover under furniture where you can reach',
            'Use the nozzle for corners and skirting boards',
            'Hoover the middle of the room',
            'Check for missed spots',
            'Turn off and unplug the hoover',
            'Put the hoover away',
          ],
        ),
      ],
      sideQuests: <TaskTemplateSideQuest>[
        TaskTemplateSideQuest(
            title: 'Empty hoover if full',
            rewardXp: 20,
            questType: 'maintenance'),
      ],
    ),
    'make_bed': TaskTemplate(
      id: 'make_bed',
      title: 'Making a bed',
      estimatedMinutes: 10,
      sections: <TaskTemplateSection>[
        TaskTemplateSection(
          title: 'Making a bed',
          steps: <String>[
            'Clear anything that does not belong on the bed',
            'Pull the duvet or blanket back',
            'Smooth the bottom sheet flat',
            'Tuck in any loose sheet corners if needed',
            'Shake out the duvet so the filling spreads evenly',
            'Lay the duvet evenly over the bed',
            'Pull the duvet up to the top of the bed',
            'Straighten the left side',
            'Straighten the right side',
            'Plump the pillows',
            'Place pillows at the head of the bed',
            'Add cushions or a throw if you use them',
            'Do one final smoothing pass',
          ],
        ),
      ],
      sideQuests: <TaskTemplateSideQuest>[
        TaskTemplateSideQuest(
            title: 'Put one item from the bed where it belongs', rewardXp: 10),
      ],
    ),
    'change_bed': TaskTemplate(
      id: 'change_bed',
      title: 'Changing a bed',
      estimatedMinutes: 30,
      sections: <TaskTemplateSection>[
        TaskTemplateSection(
          title: 'Changing the bed',
          steps: <String>[
            'Remove pillows from the bed',
            'Take off the pillowcases',
            'Remove the duvet cover',
            'Remove the fitted sheet',
            'Put dirty bedding into the laundry basket',
            'Get a clean fitted sheet',
            'Get a clean duvet cover',
            'Get clean pillowcases',
            'Put the clean fitted sheet on one mattress corner',
            'Secure the other fitted sheet corners',
            'Put the duvet into the clean cover',
            'Hold the top corners and shake the duvet down',
            'Fasten the duvet cover buttons, poppers, or zipper',
            'Put clean pillowcases on pillows',
            'Return pillows to the head of the bed',
            'Lay the duvet evenly and straighten everything',
            'Move dirty bedding near the washing machine or laundry area',
          ],
        ),
      ],
      sideQuests: <TaskTemplateSideQuest>[
        TaskTemplateSideQuest(
            title: 'Start a bedding wash if there is enough energy',
            rewardXp: 20),
      ],
    ),
    'put_on_wash': TaskTemplate(
      id: 'put_on_wash',
      title: 'Putting on a wash',
      estimatedMinutes: 20,
      sections: <TaskTemplateSection>[
        TaskTemplateSection(
          title: 'Putting on a wash',
          steps: <String>[
            'Collect dirty laundry into one place',
            'Separate laundry into whites, colours, darks, towels, bedding, or delicates',
            'Choose one pile to wash now',
            'Check clothing labels if unsure',
            'Check pockets for tissues, coins, keys, or paper',
            'Turn delicate or printed clothes inside out if needed',
            'Open the washing machine door',
            'Load the chosen wash into the drum',
            'Make sure the drum is not overfilled',
            'Add detergent to the correct drawer or directly into the drum',
            'Add fabric softener if you use it',
            'Close the washing machine door firmly',
            'Choose the correct wash setting',
            'Select the temperature',
            'Press start',
            'Set a reminder to move the washing when it finishes',
          ],
        ),
      ],
      sideQuests: <TaskTemplateSideQuest>[
        TaskTemplateSideQuest(
            title: 'Set a reminder to unload the machine',
            rewardXp: 10,
            questType: 'future_you'),
      ],
    ),
    'empty_bin': TaskTemplate(
      id: 'empty_bin',
      title: 'Throwing out a bin',
      estimatedMinutes: 10,
      sections: <TaskTemplateSection>[
        TaskTemplateSection(
          title: 'Throwing out the bin',
          steps: <String>[
            'Check whether the bin needs emptying',
            'Press rubbish down gently if needed',
            'Tie the bin bag securely',
            'Lift the bag out carefully',
            'Check for leaks',
            'Double-bag it if it is leaking',
            'Carry the bag to the outside bin',
            'Put it in the correct outside bin',
            'Close the outside bin lid',
            'Put a fresh liner into the indoor bin',
            'Fold the liner edges over the rim',
            'Wipe the bin lid if it is dirty',
            'Wash your hands',
          ],
        ),
      ],
      sideQuests: <TaskTemplateSideQuest>[
        TaskTemplateSideQuest(
            title: 'Check if recycling needs going out too', rewardXp: 15),
      ],
    ),
    'clean_room': TaskTemplate(
      id: 'clean_room',
      title: 'Reset bedroom / housework',
      estimatedMinutes: 60,
      sections: <TaskTemplateSection>[
        TaskTemplateSection(
          title: 'Putting the washing away',
          steps: <String>[
            'Collect the clean, dry washing',
            'Put it all in one clear place, like the bed or sofa',
            'Check whether anything is still damp and set it aside',
            'Separate items into piles: tops, bottoms, underwear, socks, towels, bedding',
            'Make a separate pile for anything that needs hanging',
            'Fold each item neatly',
            'Pair socks together',
            'Hang clothes that need hanging',
            'Put folded clothes into the correct drawers',
            'Put towels or bedding into their storage place',
            'Check the area for anything you missed',
            'Put the empty laundry basket away',
          ],
        ),
        TaskTemplateSection(
          title: 'Making the bed',
          steps: <String>[
            'Clear anything that does not belong on the bed',
            'Pull the duvet or blanket back',
            'Smooth the bottom sheet flat',
            'Tuck in any loose sheet corners if needed',
            'Shake out the duvet so the filling spreads evenly',
            'Lay the duvet evenly over the bed',
            'Pull the duvet up to the top of the bed',
            'Straighten the left side',
            'Straighten the right side',
            'Plump the pillows',
            'Place pillows at the head of the bed',
            'Do one final smoothing pass',
          ],
        ),
        TaskTemplateSection(
          title: 'Clearing rubbish',
          steps: <String>[
            'Get a bin bag or small rubbish bag',
            'Start at the door and look for obvious rubbish',
            'Pick up wrappers, tissues, receipts, or empty packets',
            'Check the desk or bedside table for rubbish',
            'Check the floor near the bed',
            'Check for cups or plates that need to leave the room',
            'Put recycling in a separate pile if that helps',
            'Tie the rubbish bag when it is ready',
            'Take the rubbish to the correct bin',
            'Put cups or plates by the sink',
            'Come back and check for one final missed item',
          ],
        ),
        TaskTemplateSection(
          title: 'Hoovering the room',
          steps: <String>[
            'Pick up anything loose from the floor',
            'Move shoes, bags, toys, or boxes out of the way',
            'Check for coins, cables, or tiny objects that could block the hoover',
            'Move small furniture if it is safe and easy',
            'Check whether the hoover cylinder or bag is full',
            'Plug in the hoover',
            'Start at the far side of the room',
            'Hoover slowly in overlapping lines',
            'Hoover around the edges of the room',
            'Hoover under furniture where you can reach',
            'Use the nozzle for corners and skirting boards',
            'Hoover the middle of the room',
            'Check for missed spots',
            'Turn off and unplug the hoover',
            'Put the hoover away',
          ],
        ),
      ],
      sideQuests: <TaskTemplateSideQuest>[
        TaskTemplateSideQuest(
            title: 'Put one extra item away',
            rewardXp: 10,
            questType: 'momentum'),
        TaskTemplateSideQuest(
            title: 'Open a window for fresh air',
            rewardXp: 10,
            questType: 'environment'),
        TaskTemplateSideQuest(
            title: 'Empty hoover if full',
            rewardXp: 20,
            questType: 'maintenance'),
      ],
    ),
    'morning_routine': TaskTemplate(
      id: 'morning_routine',
      title: 'Morning routine',
      category: 'routine',
      estimatedMinutes: 35,
      sections: <TaskTemplateSection>[
        TaskTemplateSection(
          title: 'Waking up gently',
          steps: <String>[
            'Sit up or roll onto your side',
            'Take one slow breath',
            'Turn off or snooze the alarm',
            'Put your feet on the floor',
            'Open curtains or turn on a soft light',
            'Drink a few sips of water if it is nearby',
            'Check the time once',
            'Choose the next easiest action',
            'Stand up when ready',
            'Move toward the bathroom or getting-ready space',
          ],
        ),
        TaskTemplateSection(
          title: 'Bathroom basics',
          steps: <String>[
            'Go to the bathroom sink',
            'Use the toilet if needed',
            'Wash your hands',
            'Pick up your toothbrush',
            'Add toothpaste',
            'Brush teeth',
            'Rinse or wipe your mouth',
            'Wash or splash your face',
            'Use deodorant if you use it',
            'Put bathroom items back',
          ],
        ),
        TaskTemplateSection(
          title: 'Getting dressed and ready',
          steps: <String>[
            'Choose clean underwear and socks',
            'Choose a comfortable top',
            'Choose trousers, shorts, skirt, or leggings',
            'Put on underwear and socks',
            'Put on the main clothes',
            'Check the clothes feel okay on your body',
            'Brush or tidy hair if needed',
            'Pack the first important item you need today',
            'Pack keys, wallet, phone, or school/work items',
            'Put shoes near the door or put them on',
          ],
        ),
      ],
      sideQuests: <TaskTemplateSideQuest>[
        TaskTemplateSideQuest(
            title: 'Put your water bottle where you will see it',
            rewardXp: 10,
            questType: 'future_you'),
      ],
    ),
    'homework': TaskTemplate(
      id: 'homework',
      title: 'Homework',
      category: 'study',
      estimatedMinutes: 45,
      sections: <TaskTemplateSection>[
        TaskTemplateSection(
          title: 'Set up homework space',
          steps: <String>[
            'Choose where to work',
            'Clear just enough space for the homework',
            'Put your phone somewhere less distracting if possible',
            'Get the assignment, worksheet, book, or laptop',
            'Get a pen, pencil, charger, or other tool you need',
            'Put a drink nearby if helpful',
            'Open the correct page, document, or website',
            'Read the task title',
            'Set a short timer if timers help',
            'Take one breath before starting',
          ],
        ),
        TaskTemplateSection(
          title: 'Understand the homework',
          steps: <String>[
            'Read the instructions once',
            'Underline or note the action word',
            'Check how many questions or parts there are',
            'Find the easiest question or smallest section',
            'Look for examples or notes that match',
            'Write down what the first answer needs to include',
            'Ask for help if the instruction makes no sense',
            'Choose the first tiny piece to do',
            'Ignore the rest for a moment',
            'Start with that one piece',
          ],
        ),
        TaskTemplateSection(
          title: 'Do one focus block',
          steps: <String>[
            'Start the first question or section',
            'Write one sentence, calculation, bullet, or answer attempt',
            'Check the notes if you get stuck',
            'Do the next small part',
            'Mark anything confusing with a question mark',
            'Keep going until the timer ends or the section is done',
            'Tick off completed questions or parts',
            'Take a short reset break',
            'Decide whether to do another focus block',
            'Save your work if it is digital',
          ],
        ),
        TaskTemplateSection(
          title: 'Finish and pack away',
          steps: <String>[
            'Check the homework against the instructions',
            'Fill in any obvious missing answers',
            'Write your name if needed',
            'Save or submit digital work if required',
            'Take a photo or screenshot if you need proof',
            'Put paper homework into the right folder or bag',
            'Put books and tools away',
            'Plug in devices if needed',
            'Write down the next deadline if there is one',
            'Tell yourself the work block is finished',
          ],
        ),
      ],
      sideQuests: <TaskTemplateSideQuest>[
        TaskTemplateSideQuest(
            title: 'Do a 30-second stretch after the focus block',
            rewardXp: 10,
            questType: 'reset'),
      ],
    ),
  };

  static TaskTemplate? findTemplate(String text) {
    final lower = text.toLowerCase();
    if (_hasAny(lower, <String>[
      'household reset',
      'housework',
      'reset bedroom',
      'bedroom reset',
      'reset my room',
      'clean my room',
      'clean room',
      'tidy my room',
      'tidy room',
    ])) {
      return templates['clean_room'];
    }
    if (_hasAny(
        lower, <String>['morning routine', 'get ready in the morning'])) {
      return templates['morning_routine'];
    }
    if (_hasAny(lower,
        <String>['homework', 'study focus', 'assignment', 'coursework'])) {
      return templates['homework'];
    }
    if (_hasAny(lower, <String>[
      'change bed',
      'change the bed',
      'change bedding',
      'changing a bed'
    ])) {
      return templates['change_bed'];
    }
    if (_hasAny(lower, <String>['make bed', 'make the bed', 'making a bed'])) {
      return templates['make_bed'];
    }
    if (_hasAny(lower, <String>[
      'put washing away',
      'put the washing away',
      'put laundry away',
      'put clothes away',
      'washing away',
      'laundry away',
      'fold laundry',
      'fold washing',
    ])) {
      return templates['put_washing_away'];
    }
    if (_hasAny(lower, <String>[
      'washing up',
      'wash up',
      'wash the dishes',
      'do the dishes',
      'dishes'
    ])) {
      return templates['washing_up'];
    }
    if (_hasAny(lower, <String>['hoover', 'vacuum'])) {
      return templates['hoover_room'];
    }
    if (_hasAny(lower, <String>[
      'put on a wash',
      'putting on a wash',
      'load washing machine',
      'start washing machine'
    ])) {
      return templates['put_on_wash'];
    }
    if (_hasAny(lower, <String>[
      'empty bin',
      'take out the bin',
      'throw out bin',
      'throwing out a bin',
      'trash',
      'rubbish'
    ])) {
      return templates['empty_bin'];
    }
    return null;
  }

  static TaskTemplateSection? findSection(String text) {
    final lower = text.toLowerCase();
    for (final template in templates.values) {
      for (final section in template.sections) {
        final sectionLower = section.title.toLowerCase();
        if (lower == sectionLower ||
            lower.contains(sectionLower) ||
            sectionLower.contains(lower)) {
          return section;
        }
      }
    }

    final matchedTemplate = findTemplate(text);
    if (matchedTemplate != null && matchedTemplate.sections.length == 1) {
      return matchedTemplate.sections.first;
    }
    return null;
  }

  static bool _hasAny(String lower, List<String> needles) {
    return needles.any(lower.contains);
  }
}
