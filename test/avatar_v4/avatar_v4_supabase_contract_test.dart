import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  test('Supabase table names are locked for Avatar Engine V4', () {
    expect(AvatarV4SupabaseTables.profiles, 'avatar_profiles');
    expect(AvatarV4SupabaseTables.inventory, 'avatar_inventory');
    expect(AvatarV4SupabaseTables.purchases, 'avatar_purchases');
    expect(AvatarV4SupabaseTables.uploads, 'avatar_uploads');
  });

  test('offline update failure has stable code', () {
    const failure = AvatarV4OfflineUpdateFailure();

    expect(failure.code, 'avatar_update_requires_online');
    expect(failure.message, contains('online connection'));
  });
}
