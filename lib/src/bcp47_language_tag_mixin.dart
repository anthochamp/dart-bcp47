// SPDX-FileCopyrightText: © 2023 - 2026 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:collection/collection.dart';

import 'bcp47_formatter.dart';
import 'bcp47_language_tag.dart';
import 'bcp47_typedefs.dart';

// Structural, case-insensitive equality used for hashCode / ==.
const _equality = ListEquality<String>(CaseInsensitiveEquality());

/// Shared implementation for all [Bcp47LanguageTag] concrete types.
///
/// Provides [subtags], [hashCode], [==], [format], and [toString] in terms
/// of the abstract [primarySubtag] / [otherSubtags] pair. Concrete classes
/// need only implement those two getters.
abstract class Bcp47LanguageTagMixin implements Bcp47LanguageTag {
  @override
  Bcp47Subtags get subtags => [primarySubtag, ...otherSubtags];

  @override
  int get hashCode => _equality.hash(subtags.toList());

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (runtimeType != other.runtimeType) return false;
    return _equality.equals(
      subtags.toList(),
      (other as Bcp47LanguageTag).subtags.toList(),
    );
  }

  @override
  String format({
    bool? caseNormalized,
    String? separator,
  }) =>
      Bcp47Formatter.formatLanguageTagSubtags(
        subtags: subtags,
        caseNormalized: caseNormalized,
        separator: separator,
      );

  @override
  String toString() => format();
}
