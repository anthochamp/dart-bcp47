import 'package:test/test.dart';

import 'package:ac_bcp47/ac_bcp47.dart';

void main() {
  group('default constructor', () {
    test('empty', () {
      final blr = Bcp47BasicLanguageRange();
      expect(blr.format(), '*');
    });

    test('*', () {
      final blr = Bcp47BasicLanguageRange(subtags: const ['*']);
      expect(blr.format(), '*');
    });

    test('aa-BB', () {
      final blr = Bcp47BasicLanguageRange(subtags: const ['aa', 'BB']);
      expect(blr.format(), 'aa-BB');
    });
  });

  group('parse', () {
    test('*', () {
      final blr = Bcp47BasicLanguageRange.parse('*');
      expect(blr.primarySubtag, '*');
      expect(blr.otherSubtags, equals([]));
    });

    test('aa-BB', () {
      final blr = Bcp47BasicLanguageRange.parse('aa-BB');
      expect(blr.primarySubtag, 'aa');
      expect(blr.otherSubtags, equals(['BB']));
    });
  });

  group('match', () {
    test('*', () {
      final blr = Bcp47BasicLanguageRange();
      expect(blr.match(Bcp47LanguageTag.parse('en')), equals(true));
      expect(blr.match(Bcp47LanguageTag.parse('en-US')), equals(true));
      expect(blr.match(Bcp47LanguageTag.parse('en-Latn-US')), equals(true));
    });

    test('en-US', () {
      final blr = Bcp47BasicLanguageRange(subtags: const ['en', 'US']);
      expect(blr.match(Bcp47LanguageTag.parse('en')), equals(false));
      expect(blr.match(Bcp47LanguageTag.parse('en-US')), equals(true));
      expect(blr.match(Bcp47LanguageTag.parse('en-Latn-US')), equals(false));
      expect(blr.match(Bcp47LanguageTag.parse('en-US-x-xxx')), equals(true));
    });
  });
}
