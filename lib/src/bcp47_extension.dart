// SPDX-FileCopyrightText: © 2023 - 2024 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:ac_dart_essentials/ac_dart_essentials.dart';
import 'package:meta/meta.dart';

import 'bcp47_parser.dart';
import 'bcp47_singleton_tag.dart';

/// A BCP-47 extension sequence as defined in RFC 5646 §2.2.6.
///
/// An extension consists of a single-character singleton (any alphanumeric
/// except `x`) followed by two or more subtags of at least 2 characters.
/// Multiple extensions may appear in a [Bcp47LangTag], each with a distinct
/// singleton, ordered lexicographically after canonicalization.
///
/// Example: `u-ca-gregory` (Unicode locale extension for Gregorian calendar)
///
/// ```dart
/// final ext = Bcp47Extension.parse('u-ca-gregory');
/// print(ext.singleton);    // u
/// print(ext.otherSubtags); // [ca, gregory]
/// ```

@immutable
class Bcp47Extension extends Bcp47SingletonTag {
  Bcp47Extension({
    required super.singleton,
    required super.otherSubtags,
  }) : super(
          Bcp47Parser.kExtensionSingletonPattern,
          Bcp47Parser.kExtensionSubtagMinLength,
        );

  /// Parses [string] as a standalone extension sequence.
  ///
  /// Throws [ArgumentError] if the string is not a valid extension.
  /// [separatorPattern] overrides the default `-` separator.
  factory Bcp47Extension.parse(
    String string, {
    Pattern? separatorPattern,
  }) {
    final pointer = StringPointer(string);

    final instance = Bcp47Parser.parseExtension(
      pointer,
      singletonCharPattern: Bcp47Parser.kExtensionSingletonPattern,
      separatorPattern: separatorPattern,
    );

    if (pointer.value.isNotEmpty) {
      throw ArgumentError.value(string);
    }

    return instance!;
  }

  /// Returns the canonicalized form of this extension.
  ///
  /// Extensions do not currently require subtag reordering, so this
  /// returns `this` unchanged. Reserved for future canonicalization rules.
  Bcp47Extension get canonicalized => this;
}
