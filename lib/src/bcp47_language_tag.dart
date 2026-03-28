// SPDX-FileCopyrightText: © 2023 - 2024 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'bcp47_grandfathered_tag.dart';
import 'bcp47_lang_tag.dart';
import 'bcp47_private_use_tag.dart';
import 'bcp47_typedefs.dart';

/// Abstract representation of a BCP-47 Language Tag as defined in
/// [RFC 5646](https://www.rfc-editor.org/rfc/rfc5646).
///
/// Use the [Bcp47LanguageTag.parse] factory to parse an unknown tag string.
/// It dispatches to the correct concrete type:
///
/// - [Bcp47GrandfatheredTag] — irregular/regular grandfathered tags
///   (e.g. `i-enochian`, `art-lojban`)
/// - [Bcp47PrivateUseTag] — private-use tags starting with `x-`
/// - [Bcp47LangTag] — normal language tags (e.g. `en-US`, `zh-Hans-CN`)
///
/// Example:
/// ```dart
/// final tag = Bcp47LanguageTag.parse('zh-Hans-CN');
/// if (tag is Bcp47LangTag) {
///   print(tag.language); // zh
///   print(tag.script);   // Hans
///   print(tag.region);   // CN
/// }
/// print(tag.format(caseNormalized: true)); // zh-Hans-CN
/// ```
abstract class Bcp47LanguageTag {
  /// Parses [string] into its concrete [Bcp47LanguageTag] subtype.
  ///
  /// Dispatch order: [Bcp47GrandfatheredTag], [Bcp47PrivateUseTag],
  /// [Bcp47LangTag]. Throws [ArgumentError] if the string is not a
  /// well-formed BCP-47 tag.
  ///
  /// [separatorPattern] overrides the default `-` separator. Pass `'_'`
  /// to accept CLDR-style tags.
  factory Bcp47LanguageTag.parse(
    String string, {
    Pattern? separatorPattern,
  }) {
    try {
      return Bcp47GrandfatheredTag.parse(
        string,
        separatorPattern: separatorPattern,
      );
    } catch (_) {}

    try {
      return Bcp47PrivateUseTag.parse(
        string,
        separatorPattern: separatorPattern,
      );
    } catch (_) {}

    return Bcp47LangTag.parse(
      string,
      separatorPattern: separatorPattern,
    );
  }

  /// The first subtag of the tag (RFC 3066 primary subtag).
  Bcp47Subtag get primarySubtag;

  /// All subtags after [primarySubtag].
  Bcp47Subtags get otherSubtags;

  /// All subtags in order: `[primarySubtag, ...otherSubtags]`.
  Bcp47Subtags get subtags;

  /// Formats the tag as a string joined by [separator] (default `-`).
  ///
  /// When [caseNormalized] is `true`, applies RFC 5646 §2.1.1 casing:
  /// language → lowercase, script → Title Case, region → UPPERCASE.
  String format({bool? caseNormalized, String? separator});
}
