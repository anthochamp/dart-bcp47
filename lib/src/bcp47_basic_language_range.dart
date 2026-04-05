// SPDX-FileCopyrightText: © 2023 - 2026 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:ac_dart_essentials/ac_dart_essentials.dart';
import 'package:meta/meta.dart';

import 'bcp47_constants.dart';
import 'bcp47_language_range.dart';
import 'bcp47_language_tag.dart';
import 'bcp47_language_tag_mixin.dart';
import 'bcp47_parser.dart';
import 'bcp47_typedefs.dart';
import 'bcp47_validator.dart';

/// A Basic Language Range as defined in RFC 4647 §2.1.
///
/// A basic range is a BCP-47 tag or the wildcard `*`. The wildcard matches
/// every language tag. Other ranges match tags whose formatted string begins
/// with the range string (prefix match, case-insensitive).
///
/// Examples:
/// ```dart
/// Bcp47BasicLanguageRange.parse('de').match(Bcp47LanguageTag.parse('de-DE')); // true
/// Bcp47BasicLanguageRange.parse('de').match(Bcp47LanguageTag.parse('en'));    // false
/// Bcp47BasicLanguageRange().match(Bcp47LanguageTag.parse('anything'));        // true (*)
/// ```
///
/// See also [Bcp47ExtendedLanguageRange] for wildcard-subtag matching.
@immutable
class Bcp47BasicLanguageRange
    with Bcp47LanguageTagMixin
    implements Bcp47LanguageRange, Bcp47LanguageTag {
  @override
  final Bcp47Subtags subtags;

  Bcp47BasicLanguageRange({
    this.subtags = const ['*'],
  }) {
    bcp47ValidateBasicLanguageRangeSubtagsFormat(subtags: subtags);
  }

  /// Parses [string] as a basic language range (`*` or a BCP-47-like tag).
  ///
  /// Throws [ArgumentError] if [string] is not a valid basic language range.
  /// [separatorPattern] overrides the default `-` separator.
  factory Bcp47BasicLanguageRange.parse(
    String string, {
    Pattern? separatorPattern,
  }) {
    final pointer = StringPointer(string);

    final instance = Bcp47Parser.parseBasicLanguageRange(
      pointer,
      separatorPattern: separatorPattern,
    );

    if (pointer.value.isNotEmpty) {
      throw ArgumentError.value(string);
    }

    return instance!;
  }

  @override
  Bcp47Subtag get primarySubtag => subtags.first;

  @override
  Bcp47Subtags get otherSubtags => subtags.skip(1).toList();

  /// Returns `true` if [languageTag] matches this range using Basic Filtering
  /// (RFC 4647 §3.3.1).
  ///
  /// The wildcard `*` matches every tag. Otherwise, [languageTag] must start
  /// with this range's formatted string (prefix match, case-insensitive,
  /// followed by `-` or end of string).
  @override
  bool match(Bcp47LanguageTag languageTag) {
    if (subtags.length == 1 && subtags.first == '*') {
      return true;
    }

    final formatted = format(caseNormalized: true, separator: kBcp47Separator);
    final formattedLanguageTag =
        languageTag.format(caseNormalized: true, separator: kBcp47Separator);

    return formattedLanguageTag
        .startsWith(RegExp(RegExp.escape(formatted), caseSensitive: false));
  }
}
