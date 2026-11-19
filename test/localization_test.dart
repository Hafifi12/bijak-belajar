import 'package:flutter_test/flutter_test.dart';
import 'package:bijak_belajar/models/app_language.dart';
import 'package:bijak_belajar/utils/app_text.dart';

void main() {
  test('Indonesian shows Malay copy where a screen only has Malay text', () {
    expect(AppLanguage.malay.usesMalayCopy, isTrue);
    expect(AppLanguage.indonesian.usesMalayCopy, isTrue);
    expect(AppLanguage.english.usesMalayCopy, isFalse);
    expect(AppLanguage.mandarin.usesMalayCopy, isFalse);
    expect(AppLanguage.tamil.usesMalayCopy, isFalse);
  });

  test('every UI string has a translation in all five languages', () {
    final gaps = <String>[
      for (final key in AppText.uiKeys)
        if (AppText.missingLanguages(key).isNotEmpty)
          '$key: ${AppText.missingLanguages(key).map((l) => l.code).join(', ')}',
    ];

    expect(gaps, isEmpty, reason: 'Missing translations:\n${gaps.join('\n')}');
  });
}
