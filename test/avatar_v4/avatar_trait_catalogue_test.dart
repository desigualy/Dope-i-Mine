import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dope_i_mine/avatar_engine_v4/avatar_engine_v4.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Avatar Engine V4 trait catalogue asset is valid and inclusive',
      () async {
    final raw = await rootBundle.loadString(avatarTraitCatalogueAssetPath);
    final catalogue = AvatarTraitCatalogue.fromJson(jsonDecode(raw));

    expect(catalogue.traits.length, greaterThan(150));
    expect(catalogue.find('kiwi_new_zealander')?.category,
        AvatarTraitCategory.heritageIdentity);
    expect(catalogue.find('albinism_type_1')?.category,
        AvatarTraitCategory.skinTone);
    expect(catalogue.find('wheelchair')?.free, isTrue);
    expect(catalogue.find('hijab')?.free, isTrue);
    expect(catalogue.find('private_abstract')?.free, isTrue);

    for (final trait in catalogue.traits) {
      expect(trait.id, matches(RegExp(r'^[a-z0-9_]+$')));
      expect(trait.free, isTrue);
    }
  });
}
