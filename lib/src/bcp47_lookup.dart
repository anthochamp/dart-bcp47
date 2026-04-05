// SPDX-FileCopyrightText: © 2026 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:ac_dart_essentials/ac_dart_essentials.dart';
import 'package:collection/collection.dart';

import 'bcp47_basic_language_range.dart';
import 'bcp47_constants.dart';
import 'bcp47_extended_language_range.dart';
import 'bcp47_language_tag.dart';

/// Returns every tag in [tags] that matches at least one range in [ranges]
/// using Basic Filtering (RFC 4647 §3.3.1).
///
/// A tag matches a basic range when the range is `*` (wildcard), or when
/// the tag's formatted string starts with the range string
/// (case-insensitive prefix match). The order of [tags] is preserved.
///
/// Example:
/// ```dart
/// final ranges = [Bcp47BasicLanguageRange.parse('de')];
/// final tags = ['de-DE', 'de-AT', 'en-US']
///     .map(Bcp47LanguageTag.parse)
///     .toList();
/// bcp47BasicFilter(ranges, tags); // [de-DE, de-AT]
/// ```
Iterable<T> bcp47BasicFilter<T extends Bcp47LanguageTag>(
  Iterable<Bcp47BasicLanguageRange> ranges,
  Iterable<T> tags,
) =>
    tags.where((tag) => ranges.any((range) => range.match(tag)));

/// Returns every tag in [tags] that matches at least one range in [ranges]
/// using Extended Filtering (RFC 4647 §3.3.2).
///
/// A wildcard (`*`) in a range position skips any subtag in the tag at
/// that position. The order of [tags] is preserved.
///
/// Example:
/// ```dart
/// final ranges = [Bcp47ExtendedLanguageRange.parse('zh-*-CN')];
/// final tags = ['zh-Hans-CN', 'zh-Hant-CN', 'zh-CN', 'en-CN']
///     .map(Bcp47LanguageTag.parse)
///     .toList();
/// bcp47ExtendedFilter(ranges, tags); // [zh-Hans-CN, zh-Hant-CN, zh-CN]
/// ```
Iterable<T> bcp47ExtendedFilter<T extends Bcp47LanguageTag>(
  Iterable<Bcp47ExtendedLanguageRange> ranges,
  Iterable<T> tags,
) =>
    tags.where((tag) => ranges.any((range) => range.match(tag)));

/// Returns the best-matching tag from [tags] for the priority-ordered
/// [ranges] using the Lookup scheme (RFC 4647 §3.4).
///
/// For each range (highest priority first) the algorithm progressively
/// removes the last subtag and checks for a case-insensitive exact match
/// among [tags]. The first match found is returned.
///
/// A wildcard `*` range matches the first available tag immediately.
///
/// Returns [defaultValue] (`null` by default) when no match is found for
/// any range.
///
/// Example:
/// ```dart
/// // RFC 4647 §3.4 example
/// final ranges = ['da', 'en-gb', 'en']
///     .map(Bcp47BasicLanguageRange.parse)
///     .toList();
/// final tags = ['en-us', 'zh-tw', 'en-gb']
///     .map(Bcp47LanguageTag.parse)
///     .toList();
/// bcp47Lookup(ranges, tags); // en-gb
/// ```
T? bcp47Lookup<T extends Bcp47LanguageTag>(
  Iterable<Bcp47BasicLanguageRange> ranges,
  Iterable<T> tags, {
  T? defaultValue,
}) {
  for (final range in ranges) {
    var current = range.subtags.toList();

    // Wildcard matches the first available tag immediately.
    if (current.length == 1 && current.first == '*') {
      final first = tags.firstOrNull;
      if (first != null) return first;
      continue;
    }

    while (current.isNotEmpty) {
      final rangeStr = current.join(kBcp47Separator);
      final match = tags.firstWhereOrNull(
        (tag) =>
            tag
                .format(caseNormalized: true, separator: kBcp47Separator)
                .compareToI(rangeStr) ==
            0,
      );
      if (match != null) return match;
      current = current.sublist(0, current.length - 1);
    }
  }

  return defaultValue;
}

/// RFC 4647 language tag filtering and lookup.
///
/// All methods forward to the corresponding top-level `bcp47…` functions.
/// Prefer calling those directly.
@Deprecated(
    'Use top-level bcp47BasicFilter, bcp47ExtendedFilter, and bcp47Lookup instead.')
class Bcp47Lookup {
  @Deprecated('Use bcp47BasicFilter instead.')
  static Iterable<T> basicFilter<T extends Bcp47LanguageTag>(
    Iterable<Bcp47BasicLanguageRange> ranges,
    Iterable<T> tags,
  ) =>
      bcp47BasicFilter(ranges, tags);

  @Deprecated('Use bcp47ExtendedFilter instead.')
  static Iterable<T> extendedFilter<T extends Bcp47LanguageTag>(
    Iterable<Bcp47ExtendedLanguageRange> ranges,
    Iterable<T> tags,
  ) =>
      bcp47ExtendedFilter(ranges, tags);

  @Deprecated('Use bcp47Lookup instead.')
  static T? lookup<T extends Bcp47LanguageTag>(
    Iterable<Bcp47BasicLanguageRange> ranges,
    Iterable<T> tags, {
    T? defaultValue,
  }) =>
      bcp47Lookup(ranges, tags, defaultValue: defaultValue);
}
