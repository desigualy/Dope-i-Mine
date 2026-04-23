
import 'package:flutter_test/flutter_test.dart';
import 'package:dope_i_mine/data/repositories/branding_repository_impl.dart';
import 'package:dope_i_mine/domain/branding/reward_phrase.dart';

void main() {
  test('reward phrase catalogue returns meaningful phrases by type', () {
    final repo = BrandingRepositoryImpl();

    final micro = repo.getRewardPhrases(RewardPhraseType.microStep);
    final recovery = repo.getRewardPhrases(RewardPhraseType.recovery);

    expect(micro.isNotEmpty, true);
    expect(recovery.isNotEmpty, true);
    expect(micro.first.contains('move') || micro.first.contains('brick'), true);
  });
}
