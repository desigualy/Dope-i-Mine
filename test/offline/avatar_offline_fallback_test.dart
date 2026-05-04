import 'package:dope_i_mine/data/local/local_avatar_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('offline avatar fallback returns stable candidates', () async {
    final store = LocalAvatarStore();
    final candidates = await store.fallbackCandidates();

    expect(candidates.length, greaterThanOrEqualTo(4));
    expect(candidates.first.providerId, 'offline_fallback');
    expect(candidates.first.imageUrl, startsWith('data:image/svg+xml'));
  });
}
