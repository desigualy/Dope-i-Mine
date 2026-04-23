
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/data/repositories/branding_repository_impl.dart';
import 'package:dope_i_mine/domain/branding/pronunciation_option.dart';

void main() {
  test('branding repository selects expected regional defaults', () {
    final repo = BrandingRepositoryImpl();

    expect(repo.detectRegionalDefault(const Locale('en', 'GB')).defaultOption,
        PronunciationOption.dopeEe);
    expect(repo.detectRegionalDefault(const Locale('en', 'US')).defaultOption,
        PronunciationOption.dopy);
    expect(repo.detectRegionalDefault(const Locale('en', 'AU')).defaultOption,
        PronunciationOption.dopeEe);
  });
}
