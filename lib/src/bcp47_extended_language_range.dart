// SPDX-FileCopyrightText: © 2023 - 2024 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:ac_dart_essentials/ac_dart_essentials.dart';
import 'package:meta/meta.dart';

import 'bcp47_basic_language_range.dart';
import 'bcp47_constants.dart';
import 'bcp47_language_range.dart';
import 'bcp47_language_tag.dart';
import 'bcp47_parser.dart';
import 'bcp47_validator.dart';

// https://www.rfc-editor.org/rfc/rfc4647#section-2.2

/// An Extended Language Range as defined in RFC 4647 §2.2.
///
/// An extended range contains subtags and wildcard (`*`) positions.
/// The matching algorithm (RFC 4647 §3.3.2) skips unknown subtags in the
/// tag when looking for non-wildcard range subtags.
///
/// Examples:
/// ```dart
/// // Match any Chinese tag regardless of script
/// final range = Bcp47ExtendedLanguageRange.parse('zh-*-CN');
/// range.match(Bcp47LanguageTag.parse('zh-Hans-CN')); // true
/// range.match(Bcp47LanguageTag.parse('zh-Hant-CN')); // true
/// range.match(Bcp47LanguageTag.parse('zh-CN'));       // true (wildcard skips)
/// range.match(Bcp47LanguageTag.parse('en-CN'));       // false
/// ```
///
/// Convert to a [Bcp47BasicLanguageRange] via [toBasicLanguageRange] when
/// only prefix matching is needed.
@immutable
class Bcp47ExtendedLanguageRange implements Bcp47LanguageRange {
  /// The ordered list of subtag values and wildcards (`*`) making up this
  /// range.
  final Iterable<String> values;

  Bcp47ExtendedLanguageRange({
    required this.values,
  }) {
    Bcp47Validator.validateExtendedLanguageRangeValuesFormat(values: values);
  }

  /// Parses [string] as an extended language range.
  ///
  /// Subtags are split on [separatorPattern] (default `-`). Each subtag
  /// must be either `'*'` or a valid BCP-47 subtag.
  factory Bcp47ExtendedLanguageRange.parse(
    String string, {
    Pattern? separatorPattern,
  }) {
    return Bcp47ExtendedLanguageRange(
      values: string.split(RegExp(
        (separatorPattern ?? kBcp47Separator).toString(),
        caseSensitive: false,
      )),
    );
  }

  @override
  bool match(Bcp47LanguageTag languageTag) {
    // https://www.rfc-editor.org/rfc/rfc4647#section-3.3.2

    final subtags = languageTag.subtags;

    // 2. Begin with the first subtag in each list. If the first subtag in
    // the range does not match the first subtag in the tag, the overall
    // match fails.  Otherwise, move to the next subtag in both the
    // range and the tag.
    if (values.first.compareToI(subtags.first) != 0) {
      return false;
    }

    int i = 1, j = 1;
    while (i < values.length) {
      final value = values.elementAt(i);

      // A. If the subtag currently being examined in the range is the
      // wildcard ('*'), move to the next subtag in the range and
      // continue with the loop.
      if (value == '*') {
        i++;
        continue;
      }

      // B. Else, if there are no more subtags in the language tag's list,
      // the match fails.
      if (j >= subtags.length) {
        return false;
      }

      final subtag = subtags.elementAt(j);

      // C. Else, if the current subtag in the range's list matches the
      // current subtag in the language tag's list, move to the next
      // subtag in both lists and continue with the loop.
      if (value.compareToI(subtag) == 0) {
        i++;
        j++;
        continue;
      }

      // D. Else, if the language tag's subtag is a "singleton" (a single
      // letter or digit, which includes the private-use subtag 'x')
      // the match fails.
      if (Bcp47Parser.kSingletonPattern.entireMatchI(subtag)) {
        return false;
      }

      // E. Else, move to the next subtag in the language tag's list and
      // continue with the loop.
      j++;
    }

    // 4. When the language range's list has no more subtags, the match
    // succeeds.
    return true;
  }

  @override
  String format({String? separator}) =>
      values.join(separator ?? kBcp47Separator);

  /// Converts this extended range to a [Bcp47BasicLanguageRange] by
  /// dropping all wildcard (`*`) subtags (RFC 4647 §3.2).
  ///
  /// If the first value is `*`, returns the catch-all basic range.
  Bcp47BasicLanguageRange toBasicLanguageRange() {
    if (values.first == '*') {
      return Bcp47BasicLanguageRange();
    }

    return Bcp47BasicLanguageRange(
      subtags: values.toList()..removeWhere((e) => e == '*'),
    );
  }

  @override
  String toString() => format();
}
