// SPDX-FileCopyrightText: © 2023 - 2024 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:ac_dart_essentials/ac_dart_essentials.dart';

import 'bcp47_extension.dart';
import 'bcp47_parser.dart';
import 'bcp47_singleton_tag.dart';
import 'bcp47_typedefs.dart';

class Bcp47Validator {
  static void validateBasicLanguageRangeSubtagsFormat({
    Bcp47Subtags subtags = const [],
  }) {
    if (subtags.length == 1 && subtags.first == '*') {
      return;
    }

    if (!Bcp47Parser.kPrimarySubtagPattern.entireMatchI(subtags.first)) {
      throw ArgumentError.value(subtags.first);
    }

    final subtagPattern = Bcp47Parser.composeSubtagPattern(
      minLength: Bcp47Parser.kSubtagMinLength,
    );

    if (!subtags.skip(1).every(subtagPattern.entireMatchI)) {
      throw ArgumentError.value(subtags.skip(1));
    }
  }

  static void validateExtendedLanguageRangeValuesFormat({
    Iterable<String> values = const [],
  }) {
    if (values.first != '*' &&
        !Bcp47Parser.kPrimarySubtagPattern.entireMatchI(values.first)) {
      throw ArgumentError.value(values.first);
    }

    final subtagPattern = Bcp47Parser.composeSubtagPattern(
      minLength: Bcp47Parser.kSubtagMinLength,
    );

    if (!values
        .skip(1)
        .every((e) => e == '*' || subtagPattern.entireMatchI(e))) {
      throw ArgumentError.value(values);
    }
  }

  static void validateLangTagSubtagsFormat({
    required Bcp47Subtag language,
    Bcp47Subtags extlangs = const [],
    Bcp47Subtag? script,
    Bcp47Subtag? region,
    Bcp47Subtags variants = const [],
    Iterable<Bcp47Extension> extensions = const [],
  }) {
    if (!Bcp47Parser.kLangTagLanguagePattern.entireMatchI(language)) {
      throw ArgumentError.value(language, 'language');
    }

    if (extlangs.length > Bcp47Parser.kLangTagExtLangMaxSubtags) {
      throw ArgumentError('Too many elements', 'extlangs');
    }

    if (!extlangs.every(Bcp47Parser.kLangTagExtlangPattern.entireMatchI)) {
      throw ArgumentError.value(
        extlangs,
        'extlangs',
        'One of the element is invalid',
      );
    }

    if (script != null &&
        !Bcp47Parser.kLangTagScriptPattern.entireMatchI(script)) {
      throw ArgumentError.value(script, 'script');
    }

    if (region != null &&
        !Bcp47Parser.kLangTagRegionPattern.entireMatchI(region)) {
      throw ArgumentError.value(region, 'region');
    }

    if (!variants.every(Bcp47Parser.kLangTagVariantPattern.entireMatchI)) {
      throw ArgumentError.value(
        variants,
        'variants',
        'One of the element is invalid',
      );
    }

    // asserts no variants are the same
    // https://www.rfc-editor.org/rfc/rfc5646.html#section-2.2.5
    if (variants.map((e) => e.toLowerCase()).toSet().length !=
        variants.length) {
      throw ArgumentError.value(
        variants,
        'variants',
        'Variant subtags must be unique',
      );
    }

    // asserts no two extensions prefix are the same
    // https://www.rfc-editor.org/rfc/rfc5646.html#section-2.2.6
    if (extensions.map((e) => e.singleton.toLowerCase()).toSet().length !=
        extensions.length) {
      throw ArgumentError.value(
        extensions,
        'extensions',
        'Only one instance of a particular singleton is allowed',
      );
    }
  }

  static void validateSingletonTagSubtagsFormat(
    Pattern singletonPattern,
    int otherSubtagMinLength, {
    required Bcp47Singleton singleton,
    Bcp47Subtags otherSubtags = const [],
  }) {
    if (!singletonPattern.entireMatchI(singleton)) {
      throw ArgumentError.value(singleton);
    }

    final subtagPattern = Bcp47Parser.composeSubtagPattern(
      minLength: otherSubtagMinLength,
    );

    if (!otherSubtags.every(subtagPattern.entireMatchI)) {
      throw ArgumentError.value(otherSubtags);
    }
  }
}
