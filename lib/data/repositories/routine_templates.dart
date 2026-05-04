class RoutineTemplate {
  const RoutineTemplate({
    required this.id,
    required this.title,
    required this.category,
    required this.ageBand,
    required this.steps,
  });

  final String id;
  final String title;
  final String category;
  final String ageBand;
  final List<String> steps;
}

class RoutineTemplateLibrary {
  const RoutineTemplateLibrary._();

  static const List<RoutineTemplate> all = <RoutineTemplate>[
    RoutineTemplate(
      id: 'morning_routine',
      title: 'Morning routine',
      category: 'daily',
      ageBand: 'all',
      steps: <String>[
        'Sit up and put both feet on the floor',
        'Drink a few sips of water',
        'Use the toilet',
        'Wash face or wipe face with a cloth',
        'Brush teeth',
        'Put on clean clothes',
        'Check bag, keys, phone, or school items',
        'Eat something small if possible',
        'Check the next thing you need to do',
      ],
    ),
    RoutineTemplate(
      id: 'bedtime_routine',
      title: 'Bedtime routine',
      category: 'daily',
      ageBand: 'all',
      steps: <String>[
        'Turn down bright lights',
        'Put devices on charge or away',
        'Use the toilet',
        'Brush teeth',
        'Put on sleep clothes',
        'Put tomorrow essentials in one place',
        'Get into bed',
        'Choose one calm thing: music, breathing, or quiet reading',
      ],
    ),
    RoutineTemplate(
      id: 'after_school_reset',
      title: 'After school reset',
      category: 'family',
      ageBand: 'child',
      steps: <String>[
        'Put bag in its usual place',
        'Take off shoes and coat',
        'Put lunchbox or bottle near the kitchen',
        'Change into comfortable clothes if needed',
        'Have a drink or snack',
        'Take five quiet minutes',
        'Check if anything needs signing or handing to a grown-up',
      ],
    ),
    RoutineTemplate(
      id: 'before_school_routine',
      title: 'Before school routine',
      category: 'family',
      ageBand: 'child',
      steps: <String>[
        'Put on school clothes',
        'Eat breakfast or pack a small snack',
        'Brush teeth',
        'Check school bag',
        'Check lunch, water bottle, and homework',
        'Put on shoes and coat',
        'Stand by the door with your bag',
      ],
    ),
    RoutineTemplate(
      id: 'room_reset_routine',
      title: 'Room reset routine',
      category: 'household',
      ageBand: 'all',
      steps: <String>[
        'Pick up obvious rubbish',
        'Put cups or plates near the kitchen',
        'Put clothes into clean, dirty, or unsure piles',
        'Clear one surface',
        'Put five items where they belong',
        'Make or straighten the bed',
        'Hoover or sweep the easiest visible area',
      ],
    ),
    RoutineTemplate(
      id: 'medication_reminder_routine',
      title: 'Medication reminder routine',
      category: 'health',
      ageBand: 'all',
      steps: <String>[
        'Check the medication label or organiser',
        'Get a drink of water',
        'Take only the dose you have been told to take',
        'Mark it as done in the app or organiser',
        'Put the medication back in its safe place',
      ],
    ),
    RoutineTemplate(
      id: 'homework_starter_routine',
      title: 'Homework starter routine',
      category: 'school',
      ageBand: 'child',
      steps: <String>[
        'Put your homework in front of you',
        'Get one pen or pencil',
        'Read the first instruction only',
        'Set a five-minute starter timer',
        'Do the easiest first part',
        'Tick or mark what you started',
        'Decide whether to continue or take a short break',
      ],
    ),
    RoutineTemplate(
      id: 'leaving_the_house_routine',
      title: 'Leaving the house routine',
      category: 'daily',
      ageBand: 'all',
      steps: <String>[
        'Check where you are going',
        'Check phone, keys, wallet, pass, or tickets',
        'Check medication, water, or sensory items if needed',
        'Put on shoes',
        'Put on coat or weather item',
        'Check doors, windows, or pets if needed',
        'Leave and lock the door',
      ],
    ),
    RoutineTemplate(
      id: 'calm_down_routine',
      title: 'Calm-down routine',
      category: 'regulation',
      ageBand: 'all',
      steps: <String>[
        'Move away from the loudest or busiest thing if possible',
        'Put both feet on the floor',
        'Name one thing you can see',
        'Take one slow breath out',
        'Relax your shoulders or unclench your hands',
        'Choose one tiny next action',
        'Ask for help if you need it',
      ],
    ),
    RoutineTemplate(
      id: 'shower_routine',
      title: 'Shower routine',
      category: 'self_care',
      ageBand: 'all',
      steps: <String>[
        'Get towel and clean clothes ready',
        'Turn on the shower and check temperature',
        'Get in safely',
        'Wet hair and body if comfortable',
        'Wash body',
        'Wash hair if today is a hair-wash day',
        'Rinse fully',
        'Turn shower off',
        'Dry yourself and get dressed',
      ],
    ),
  ];

  static RoutineTemplate? byId(String id) {
    for (final template in all) {
      if (template.id == id) return template;
    }
    return null;
  }
}
