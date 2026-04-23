enum PronunciationOption {
  dopeEe,
  dopy,
  dopeEye,
  custom,
}

extension PronunciationOptionLabel on PronunciationOption {
  String get label {
    switch (this) {
      case PronunciationOption.dopeEe:
        return 'Dope-ee';
      case PronunciationOption.dopy:
        return 'Dopy';
      case PronunciationOption.dopeEye:
        return 'Dope-eye';
      case PronunciationOption.custom:
        return 'Custom';
    }
  }
}
