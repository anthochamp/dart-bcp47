// SPDX-FileCopyrightText: © 2023 - 2024 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:ac_dart_essentials/ac_dart_essentials.dart';
import 'package:meta/meta.dart';

import 'bcp47_parser.dart';
import 'bcp47_singleton_tag.dart';

/// A BCP-47 private-use tag as defined in RFC 5646 §2.2.7.
///
/// A private-use tag starts with the singleton `x` and is followed by one
/// or more subtags whose meaning is defined by private agreement between
/// parties. Subtags may be 1–8 alphanumeric characters.
///
/// Examples: `x-whatever`, `x-phonebk`, `x-AZE-derbend`.
///
/// Private-use tags may also appear as a suffix within a [Bcp47LangTag]
/// (accessible via [Bcp47LangTag.privateUse]).

@immutable
class Bcp47PrivateUseTag extends Bcp47SingletonTag {
  /// The singleton character that identifies all private-use tags (`'x'`).
  static const Bcp47Singleton kSingleton = 'x';

  Bcp47PrivateUseTag({
    /// singleton must be either 'x' or 'X'
    super.singleton = kSingleton,
    required super.otherSubtags,
  }) : super(
          Bcp47Parser.kPrivateUseSingletonPattern,
          Bcp47Parser.kPrivateUseSubtagMinLength,
        );

  /// Parses [string] as a private-use tag (must begin with `x-`).
  ///
  /// Throws [ArgumentError] if the string is not a well-formed private-use
  /// tag. [separatorPattern] overrides the default `-` separator.
  factory Bcp47PrivateUseTag.parse(
    String string, {
    Pattern? separatorPattern,
  }) {
    final pointer = StringPointer(string);

    final instance = Bcp47Parser.parsePrivateUseTag(
      pointer,
      separatorPattern: separatorPattern,
    );

    if (pointer.value.isNotEmpty) {
      throw ArgumentError.value(string);
    }

    return instance!;
  }
}
