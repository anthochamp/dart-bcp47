// SPDX-FileCopyrightText: © 2023 - 2026 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:meta/meta.dart';

import 'bcp47_language_tag.dart';
import 'bcp47_language_tag_mixin.dart';
import 'bcp47_typedefs.dart';
import 'bcp47_validator.dart';

/// A single-character subtag used as the primary identifier of an extension
/// or private-use sequence (e.g. `'u'`, `'x'`).
typedef Bcp47Singleton = Bcp47Subtag;

/// A BCP-47 tag whose primary subtag is a single alphanumeric character
/// (a "singleton" in RFC 3066 / RFC 5646 terminology).
///
/// Subclassed by [Bcp47Extension] and [Bcp47PrivateUseTag]. Constructors
/// delegate validation to [bcp47ValidateSingletonTagSubtagsFormat].

@immutable
class Bcp47SingletonTag with Bcp47LanguageTagMixin implements Bcp47LanguageTag {
  /// The single-character primary subtag identifying this singleton sequence.
  final Bcp47Singleton singleton;

  /// The subtags that follow the [singleton], each at least [otherSubtagMinLength]
  /// characters.
  @override
  final Bcp47Subtags otherSubtags;

  Bcp47SingletonTag(
    Pattern singletonPattern,
    int otherSubtagMinLength, {
    required this.singleton,
    required this.otherSubtags,
  }) {
    bcp47ValidateSingletonTagSubtagsFormat(
      singletonPattern,
      otherSubtagMinLength,
      singleton: singleton,
      otherSubtags: otherSubtags,
    );
  }

  @override
  Bcp47Subtag get primarySubtag => singleton;
}
