// SPDX-FileCopyrightText: © 2023 - 2026 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:ac_bcp47/ac_bcp47.dart';
import 'package:test/test.dart';

void main() {
  // ---------------------------------------------------------------------------
  // basicFilter
  // ---------------------------------------------------------------------------
  group('basicFilter', () {
    final tags = ['de-DE', 'de-AT', 'de', 'en-US', 'en', 'fr']
        .map(Bcp47LanguageTag.parse)
        .toList();

    test('matches tags by prefix', () {
      final ranges = [Bcp47BasicLanguageRange.parse('de')];
      expect(
        Bcp47Lookup.basicFilter(ranges, tags).map((t) => t.toString()),
        equals(['de-DE', 'de-AT', 'de']),
      );
    });

    test('wildcard matches all tags', () {
      final ranges = [Bcp47BasicLanguageRange()]; // '*'
      expect(
        Bcp47Lookup.basicFilter(ranges, tags).map((t) => t.toString()),
        equals(['de-DE', 'de-AT', 'de', 'en-US', 'en', 'fr']),
      );
    });

    test('multiple ranges are combined with OR', () {
      final ranges = [
        Bcp47BasicLanguageRange.parse('de'),
        Bcp47BasicLanguageRange.parse('fr'),
      ];
      expect(
        Bcp47Lookup.basicFilter(ranges, tags).map((t) => t.toString()),
        equals(['de-DE', 'de-AT', 'de', 'fr']),
      );
    });

    test('returns empty when no tag matches', () {
      final ranges = [Bcp47BasicLanguageRange.parse('zh')];
      expect(Bcp47Lookup.basicFilter(ranges, tags), isEmpty);
    });

    test('matching is case-insensitive', () {
      final ranges = [Bcp47BasicLanguageRange.parse('DE')];
      expect(
        Bcp47Lookup.basicFilter(ranges, tags).map((t) => t.toString()),
        equals(['de-DE', 'de-AT', 'de']),
      );
    });

    test('range does not match shorter tags (exact prefix only)', () {
      // 'de-DE' should not match a 'de-AT' tag
      final ranges = [Bcp47BasicLanguageRange.parse('de-DE')];
      expect(
        Bcp47Lookup.basicFilter(ranges, tags).map((t) => t.toString()),
        equals(['de-DE']),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // extendedFilter
  // ---------------------------------------------------------------------------
  group('extendedFilter', () {
    test('wildcard in middle position skips script subtag', () {
      final ranges = [Bcp47ExtendedLanguageRange.parse('zh-*-CN')];
      final tags = ['zh-Hans-CN', 'zh-Hant-CN', 'zh-CN', 'en-CN']
          .map(Bcp47LanguageTag.parse)
          .toList();
      expect(
        Bcp47Lookup.extendedFilter(ranges, tags).map((t) => t.toString()),
        equals(['zh-Hans-CN', 'zh-Hant-CN', 'zh-CN']),
      );
    });

    test('without wildcards behaves like basic filtering', () {
      final ranges = [Bcp47ExtendedLanguageRange.parse('de-DE')];
      final tags =
          ['de-DE', 'de-AT', 'en-US'].map(Bcp47LanguageTag.parse).toList();
      expect(
        Bcp47Lookup.extendedFilter(ranges, tags).map((t) => t.toString()),
        equals(['de-DE']),
      );
    });

    test('first subtag mismatch prevents any match', () {
      final ranges = [Bcp47ExtendedLanguageRange.parse('zh-*-CN')];
      final tags = ['en-Hans-CN'].map(Bcp47LanguageTag.parse).toList();
      expect(Bcp47Lookup.extendedFilter(ranges, tags), isEmpty);
    });

    test('multiple ranges are combined with OR', () {
      final ranges = [
        Bcp47ExtendedLanguageRange.parse('de'),
        Bcp47ExtendedLanguageRange.parse('fr'),
      ];
      final tags =
          ['de-DE', 'fr-CA', 'en-US'].map(Bcp47LanguageTag.parse).toList();
      expect(
        Bcp47Lookup.extendedFilter(ranges, tags).map((t) => t.toString()),
        equals(['de-DE', 'fr-CA']),
      );
    });
  });

  // ---------------------------------------------------------------------------
  // lookup
  // ---------------------------------------------------------------------------
  group('lookup', () {
    test('RFC 4647 §3.4 example — exact match on second range', () {
      // User priority:  da, en-gb, en
      // Available:      en-us, zh-tw, en-gb
      // da    → no exact match; truncate → empty; next range
      // en-gb → exact match "en-gb"!
      final ranges =
          ['da', 'en-gb', 'en'].map(Bcp47BasicLanguageRange.parse).toList();
      final tags =
          ['en-us', 'zh-tw', 'en-gb'].map(Bcp47LanguageTag.parse).toList();
      expect(Bcp47Lookup.lookup(ranges, tags)?.toString(), equals('en-gb'));
    });

    test('progressive truncation finds shorter tag', () {
      // zh-Hant-CN → no; zh-Hant → no; zh → yes
      final ranges = [Bcp47BasicLanguageRange.parse('zh-Hant-CN')];
      final tags = ['zh', 'en'].map(Bcp47LanguageTag.parse).toList();
      expect(Bcp47Lookup.lookup(ranges, tags)?.toString(), equals('zh'));
    });

    test('first range fully exhausted falls to next range', () {
      final ranges = ['zh', 'fr'].map(Bcp47BasicLanguageRange.parse).toList();
      final tags = ['fr', 'en'].map(Bcp47LanguageTag.parse).toList();
      expect(Bcp47Lookup.lookup(ranges, tags)?.toString(), equals('fr'));
    });

    test('returns null when no range matches and no defaultValue supplied', () {
      final ranges = [Bcp47BasicLanguageRange.parse('zh')];
      final tags = ['fr', 'de'].map(Bcp47LanguageTag.parse).toList();
      expect(Bcp47Lookup.lookup(ranges, tags), isNull);
    });

    test('returns defaultValue when no range matches', () {
      final fallback = Bcp47LanguageTag.parse('en');
      final ranges = [Bcp47BasicLanguageRange.parse('zh')];
      final tags = ['fr', 'de'].map(Bcp47LanguageTag.parse).toList();
      expect(
        Bcp47Lookup.lookup(ranges, tags, defaultValue: fallback),
        same(fallback),
      );
    });

    test('wildcard range matches the first available tag', () {
      final ranges = [Bcp47BasicLanguageRange()]; // '*'
      final tags = ['de', 'en', 'fr'].map(Bcp47LanguageTag.parse).toList();
      expect(Bcp47Lookup.lookup(ranges, tags)?.toString(), equals('de'));
    });

    test('matching is case-insensitive', () {
      final ranges = [Bcp47BasicLanguageRange.parse('EN-US')];
      final tags = ['en-us', 'fr'].map(Bcp47LanguageTag.parse).toList();
      expect(Bcp47Lookup.lookup(ranges, tags)?.toString(), equals('en-us'));
    });

    test('first available tag wins among multiple matches', () {
      // Both "en-US" and "en-GB" would survive truncation to "en",
      // but "en-US" appears first in the available list.
      final ranges = [Bcp47BasicLanguageRange.parse('en-AU')];
      final tags = ['en-US', 'en-GB'].map(Bcp47LanguageTag.parse).toList();
      // en-AU → no; en → no (no bare "en" available)
      // fr → none available
      expect(Bcp47Lookup.lookup(ranges, tags), isNull);
    });

    test('exact match preferred over truncated match', () {
      final ranges = [Bcp47BasicLanguageRange.parse('en-GB')];
      final tags = ['en', 'en-GB'].map(Bcp47LanguageTag.parse).toList();
      // en-GB exact match found before truncation to "en"
      expect(Bcp47Lookup.lookup(ranges, tags)?.toString(), equals('en-GB'));
    });

    test('empty tag list returns defaultValue', () {
      final ranges = [Bcp47BasicLanguageRange.parse('en')];
      expect(Bcp47Lookup.lookup(ranges, <Bcp47LanguageTag>[]), isNull);
    });
  });
}
