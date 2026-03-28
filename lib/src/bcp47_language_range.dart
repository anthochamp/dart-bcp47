// SPDX-FileCopyrightText: © 2023 - 2024 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'bcp47_language_tag.dart';

// https://www.rfc-editor.org/rfc/rfc4647

/// Abstract RFC 4647 Language Range — a pattern used to filter or match
/// [Bcp47LanguageTag] values.
///
/// Two concrete implementations are provided:
/// - [Bcp47BasicLanguageRange] — basic filtering (RFC 4647 §3.3.1)
/// - [Bcp47ExtendedLanguageRange] — extended filtering (RFC 4647 §3.3.2)
abstract class Bcp47LanguageRange {
  /// Returns `true` if [languageTag] matches this language range.
  bool match(Bcp47LanguageTag languageTag);

  /// Formats this range as a string joined by [separator] (default `-`).
  String format({String? separator});
}
