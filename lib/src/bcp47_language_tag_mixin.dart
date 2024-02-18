// SPDX-FileCopyrightText: © 2023 - 2024 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'bcp47_formatter.dart';
import 'bcp47_language_tag.dart';
import 'bcp47_typedefs.dart';

abstract class Bcp47LanguageTagMixin implements Bcp47LanguageTag {
  @override
  Bcp47Subtags get subtags => [primarySubtag, ...otherSubtags];

  @override
  int get hashCode => subtags.map((e) => e.toLowerCase()).hashCode;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType && hashCode == other.hashCode);
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
