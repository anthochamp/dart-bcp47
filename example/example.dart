// SPDX-FileCopyrightText: © 2026 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_print

import 'package:ac_bcp47/ac_bcp47.dart';

void main() {
  _parseExample();
  _formatExample();
  _filterExample();
  _lookupExample();
}

void _parseExample() {
  print('--- Parsing BCP 47 language tags ---');

  final tag = Bcp47LangTag.parse('zh-cmn-Hans-CN');
  print('language: ${tag.language}'); // zh
  print('extlangs: ${tag.extlangs}'); // [cmn]
  print('script:   ${tag.script}'); // Hans
  print('region:   ${tag.region}'); // CN

  final simple = Bcp47LangTag.parse('en-US');
  print('language: ${simple.language}'); // en
  print('region:   ${simple.region}'); // US
}

void _formatExample() {
  print('\n--- Formatting ---');

  final tag = Bcp47LangTag.parse('EN-us');
  print(tag.format()); // EN-us (as-is)
  print(tag.format(caseNormalized: true)); // en-US (case-normalised)
}

void _filterExample() {
  print('\n--- Basic filtering (RFC 4647 §3.3.1) ---');

  final tags = ['de-DE', 'de-AT', 'de-CH', 'en-US', 'fr-FR']
      .map(Bcp47LanguageTag.parse)
      .toList();

  final ranges = [Bcp47BasicLanguageRange.parse('de')];
  final germanTags = bcp47BasicFilter(ranges, tags);
  print(germanTags.map((t) => t.format()).toList()); // [de-DE, de-AT, de-CH]
}

void _lookupExample() {
  print('\n--- Lookup (RFC 4647 §3.4) ---');

  final available =
      ['en', 'de-DE', 'fr-FR'].map(Bcp47LanguageTag.parse).toList();

  // User prefers Swiss German, falls back through de-DE to de, lands on de-DE
  final ranges = [
    Bcp47BasicLanguageRange.parse('de-CH'),
    Bcp47BasicLanguageRange.parse('en'),
  ];
  final best = bcp47Lookup(ranges, available);
  print(best?.format()); // de-DE
}
