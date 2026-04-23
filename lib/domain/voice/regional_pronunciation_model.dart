import '../branding/pronunciation_option.dart';

class RegionalPronunciationModel {
  const RegionalPronunciationModel({
    required this.localeCode,
    required this.defaultOption,
  });

  final String localeCode;
  final PronunciationOption defaultOption;
}
