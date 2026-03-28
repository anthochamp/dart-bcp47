// SPDX-FileCopyrightText: © 2023 - 2024 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:ac_dart_essentials/ac_dart_essentials.dart';

import 'bcp47_constants.dart';
import 'bcp47_extension.dart';
import 'bcp47_private_use_tag.dart';
import 'bcp47_typedefs.dart';

/// Internal formatter applying RFC 5646 §2.1.1 case normalization and
/// separator rules.
///
/// All methods are static; this class is not intended to be instantiated.
// normalization rules from :
// https://www.rfc-editor.org/rfc/rfc5646.html#section-2.1.1
class Bcp47Formatter {
  // this is the default language tag formatter, it shouldn't
  // be used if there's a specific formatter (ie. LangTag)

  /// Formats [subtags] joined by [separator] (default [kBcp47Separator]).
  ///
  /// When [caseNormalized] is `true`, all subtags are lowercased. Only use
  /// this method for tag types without explicit casing rules (i.e. not
  /// [Bcp47LangTag]); use [formatLangTagSubtags] for that.
  static String formatLanguageTagSubtags({
    required Bcp47Subtags subtags,
    bool? caseNormalized,
    String? separator,
  }) {
    return (caseNormalized == true
            ? subtags.map((e) => e.toLowerCase())
            : subtags)
        .join(separator ?? kBcp47Separator);
  }

  /// Formats a `langtag` from its constituent subtags, applying RFC 5646
  /// §2.1.1 case normalization when [caseNormalized] is `true`:
  ///
  /// - `language` / `extlangs` / `variants` → lowercase
  /// - `script` → Title Case
  /// - `region` → UPPERCASE
  ///
  /// Subtags are joined by [separator] (default [kBcp47Separator]).
  static String formatLangTagSubtags({
    Bcp47Subtag? language,
    Bcp47Subtags? extlangs,
    Bcp47Subtag? script,
    Bcp47Subtag? region,
    Bcp47Subtags? variants,
    Iterable<Bcp47Extension>? extensions,
    Bcp47PrivateUseTag? privateUse,
    bool? caseNormalized,
    String? separator,
  }) {
    // formatting rules from https://www.rfc-editor.org/rfc/rfc5646.html#section-2.1.1
    return [
      if (language != null)
        caseNormalized == true ? language.toLowerCase() : language,
      ...?(caseNormalized == true
          ? extlangs?.map((e) => e.toLowerCase())
          : extlangs),
      if (script != null)
        caseNormalized == true ? script.toTitleCase() : script,
      if (region != null)
        caseNormalized == true ? region.toUpperCase() : region,
      ...?(caseNormalized == true
          ? variants?.map((e) => e.toLowerCase())
          : variants),
      ...?extensions?.map((e) =>
          e.format(caseNormalized: caseNormalized, separator: separator)),
      if (privateUse != null)
        privateUse.format(caseNormalized: caseNormalized, separator: separator),
    ].join(separator ?? kBcp47Separator);
  }
}
