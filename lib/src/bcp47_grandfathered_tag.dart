// SPDX-FileCopyrightText: © 2023 - 2024 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:ac_dart_essentials/ac_dart_essentials.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'bcp47_language_tag.dart';
import 'bcp47_language_tag_mixin.dart';
import 'bcp47_parser.dart';
import 'bcp47_typedefs.dart';

/// A BCP-47 grandfathered tag as defined in RFC 5646 §2.2.8.
///
/// Grandfathered tags are pre-RFC 5646 registrations that cannot be
/// represented in the normal `langtag` production. They come in two kinds:
///
/// - **Irregular** — tags with the `i-` prefix (e.g. `i-enochian`,
///   `i-klingon`) that do not match the `langtag` grammar.
/// - **Regular** — tags that do match the grammar but were registered as
///   grandfathered for historical reasons (e.g. `art-lojban`, `zh-guoyu`).
///
/// The constructor throws [ArgumentError] if [subtags] does not match any
/// known grandfathered tag. Use [Bcp47LanguageTag.parse] when the tag type
/// is unknown — it will delegate here automatically.
///
/// Example:
/// ```dart
/// final tag = Bcp47LanguageTag.parse('i-enochian') as Bcp47GrandfatheredTag;
/// print(tag.irregular); // true
/// print(tag.toString()); // i-enochian
/// ```
@immutable
class Bcp47GrandfatheredTag extends Bcp47LanguageTagMixin
    implements Bcp47LanguageTag {
  static final kIrregularTags = [
    'en GB oed',
    'i ami',
    'i bnn',
    'i default',
    'i enochian',
    'i hak',
    'i klingon',
    'i lux',
    'i mingo',
    'i navajo',
    'i pwn',
    'i tao',
    'i tay',
    'i tsu',
    'sgn BE FR',
    'sgn BE NL',
    'sgn CH DE',
  ].map((e) => e.split(' '));
  static final kRegularTags = [
    'art lojban',
    'cel gaulish',
    'no bok',
    'no nyn',
    'zh guoyu',
    'zh hakka',
    'zh min',
    'zh min nan',
    'zh xiang',
  ].map((e) => e.split(' '));

  @override
  final Bcp47Subtags subtags;

  /// Whether this is an irregular grandfathered tag (e.g. `i-enochian`).
  ///
  /// `false` means it is a regular grandfathered tag (e.g. `art-lojban`).
  late final bool irregular;

  Bcp47GrandfatheredTag({
    required this.subtags,
  }) {
    final regularTag = kRegularTags.firstWhereOrNull(
      (element) => element.equalsI(subtags.toList()),
    );

    if (regularTag == null) {
      final irregularTag = kIrregularTags.firstWhereOrNull(
        (element) => element.equalsI(subtags.toList()),
      );

      if (irregularTag == null) {
        throw ArgumentError.value(subtags);
      }

      irregular = true;
    } else {
      irregular = false;
    }
  }

  /// Parses [string] as a grandfathered tag.
  ///
  /// Throws [ArgumentError] if the string is not a recognized grandfathered
  /// tag. [separatorPattern] overrides the default `-` separator.
  factory Bcp47GrandfatheredTag.parse(
    String string, {
    Pattern? separatorPattern,
  }) {
    final pointer = StringPointer(string);

    final instance = Bcp47Parser.parseGrandfatheredTag(
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
  Bcp47Subtags get otherSubtags => subtags.skip(1);
}
