import 'package:dope_i_mine/domain/companion/dopei_mood.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps every Dope-i mood to the production avatar asset pack', () {
    expect(DopeiMood.neutral.assetPath, 'assets/avatar/dopey/neutral.png');
    expect(DopeiMood.happy.assetPath, 'assets/avatar/dopey/happy.png');
    expect(DopeiMood.focused.assetPath, 'assets/avatar/dopey/focused.png');
    expect(
      DopeiMood.overwhelmed.assetPath,
      'assets/avatar/dopey/overwhelmed.png',
    );
    expect(
      DopeiMood.encouraging.assetPath,
      'assets/avatar/dopey/encouraging.png',
    );
    expect(DopeiMood.proud.assetPath, 'assets/avatar/dopey/proud.png');
    expect(
      DopeiMood.celebration.assetPath,
      'assets/avatar/dopey/celebration.png',
    );
    expect(DopeiMood.calm.assetPath, 'assets/avatar/dopey/calm.png');

    expect(
      DopeiMood.values.map((mood) => mood.assetPath).toSet(),
      hasLength(DopeiMood.values.length),
    );
  });
}
