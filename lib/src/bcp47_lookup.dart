// SPDX-FileCopyrightText: © 2026 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:ac_dart_essentials/ac_dart_essentials.dart';
import 'package:collection/collection.dart';

import 'bcp47_basic_language_range.dart';
import 'bcp47_constants.dart';
import 'bcp47_extended_language_range.dart';
import 'bcp47_language_tag.dart';

/// RFC 4647 language tag filtering and lookup.
///
/// Three operations are provided, each corresponding to a section of
/// [RFC 4647](https://www.rfc-editor.org/rfc/rfc4647):
///
/// - [basicFilter] — Basic Filtering (§3.3.1): select every tag whose
///   formatted string starts with a given range string.
/// - [extendedFilter] — Extended Filtering (§3.3.2): select every tag that
///   matches a range which may contain wildcard (`*`) positions.
/// - [lookup] — Lookup (§3.4): find the single best-matching tag from a
///   priority-ordered list of ranges by progressive subtag truncation.
///
/// All methods are static; this class is not intended to be instantiated.
class Bcp47Lookup {
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
  /// Bcp47Lookup.basicFilter(ranges, tags); // [de-DE, de-AT]
  /// ```
  static Iterable<T> basicFilter<T extends Bcp47LanguageTag>(
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
  /// Bcp47Lookup.extendedFilter(ranges, tags); // [zh-Hans-CN, zh-Hant-CN, zh-CN]
  /// ```
  static Iterable<T> extendedFilter<T extends Bcp47LanguageTag>(
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
  /// Bcp47Lookup.lookup(ranges, tags); // en-gb
  /// ```
  static T? lookup<T extends Bcp47LanguageTag>(
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
}
