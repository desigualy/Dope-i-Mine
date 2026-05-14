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

  factory TaskStateSnapshot.fromJson(Map<String, dynamic> json) {
    return TaskStateSnapshot(
      mode: _enumByName(
        SupportMode.values,
        json['mode'] as String?,
        SupportMode.audhd,
      ),
      energyLevel: _enumByName(
        EnergyLevel.values,
        json['energyLevel'] as String?,
        EnergyLevel.medium,
      ),
      stressLevel: _enumByName(
        StressLevel.values,
        json['stressLevel'] as String?,
        StressLevel.friction,
      ),
      timeAvailable: _timeAvailableFromJson(json['timeAvailable'] as String?),
    );
  }

  static T _enumByName<T extends Enum>(
    List<T> values,
    String? name,
    T fallback,
  ) {
    for (final value in values) {
      if (value.name == name) return value;
    }
    return fallback;
  }

  static TimeAvailable _timeAvailableFromJson(String? value) {
    return switch (value) {
      'twoMinutes' || '2m' => TimeAvailable.twoMinutes,
      'fiveMinutes' || '5m' => TimeAvailable.fiveMinutes,
      'fifteenMinutes' || '15m' => TimeAvailable.fifteenMinutes,
      'thirtyPlus' || '30m_plus' => TimeAvailable.thirtyPlus,
      _ => TimeAvailable.fifteenMinutes,
    };
  }
}
