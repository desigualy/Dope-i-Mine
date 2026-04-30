enum AvatarVariationStrength {
  low,
  medium,
  high,
}

extension AvatarVariationStrengthValue on AvatarVariationStrength {
  double get value {
    switch (this) {
      case AvatarVariationStrength.low:
        return 0.18;
      case AvatarVariationStrength.medium:
        return 0.35;
      case AvatarVariationStrength.high:
        return 0.62;
    }
  }

  String get label {
    switch (this) {
      case AvatarVariationStrength.low:
        return 'Keep similar';
      case AvatarVariationStrength.medium:
        return 'Balanced variation';
      case AvatarVariationStrength.high:
        return 'Explore different looks';
    }
  }
}
