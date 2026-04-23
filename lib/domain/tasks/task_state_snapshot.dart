enum AgeBand { child, preteen, teen, adult }

enum SupportMode {
  adhd,
  autism,
  audhd,
  executiveDysfunction,
  burnout,
}

enum EnergyLevel { high, medium, low, empty }

enum StressLevel { calm, friction, overwhelmed, shutdown }

enum TimeAvailable { twoMinutes, fiveMinutes, fifteenMinutes, thirtyPlus }

class TaskStateSnapshot {
  const TaskStateSnapshot({
    required this.mode,
    required this.energyLevel,
    required this.stressLevel,
    required this.timeAvailable,
  });

  final SupportMode mode;
  final EnergyLevel energyLevel;
  final StressLevel stressLevel;
  final TimeAvailable timeAvailable;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'mode': mode.name,
      'energyLevel': energyLevel.name,
      'stressLevel': stressLevel.name,
      'timeAvailable': switch (timeAvailable) {
        TimeAvailable.twoMinutes => '2m',
        TimeAvailable.fiveMinutes => '5m',
        TimeAvailable.fifteenMinutes => '15m',
        TimeAvailable.thirtyPlus => '30m_plus',
      },
    };
  }
}
