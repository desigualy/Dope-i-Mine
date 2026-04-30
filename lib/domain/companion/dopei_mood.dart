enum DopeiMood {
  neutral,
  focused,
  happy,
  celebration,
  overwhelmed,
  calm,
  encouraging,
  proud,
}

extension DopeiMoodLabel on DopeiMood {
  String get label {
    switch (this) {
      case DopeiMood.neutral:
        return 'Neutral';
      case DopeiMood.focused:
        return 'Focused';
      case DopeiMood.happy:
        return 'Happy';
      case DopeiMood.celebration:
        return 'Celebration';
      case DopeiMood.overwhelmed:
        return 'Overwhelmed';
      case DopeiMood.calm:
        return 'Calm';
      case DopeiMood.encouraging:
        return 'Encouraging';
      case DopeiMood.proud:
        return 'Proud';
    }
  }

  String get assetFileName => '$name.png';

  String get assetPath => 'assets/avatar/dopey/$assetFileName';
}
