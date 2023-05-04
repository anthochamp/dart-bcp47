// Copyright 2023, Anthony Champagne. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: member-ordering

import 'dart:math';

import 'package:ac_dart_essentials/ac_dart_essentials.dart';

import 'bcp47_basic_language_range.dart';
import 'bcp47_constants.dart';
import 'bcp47_extension.dart';
import 'bcp47_grandfathered_tag.dart';
import 'bcp47_lang_tag.dart';
import 'bcp47_private_use_tag.dart';
import 'bcp47_singleton_tag.dart';
import 'bcp47_typedefs.dart';

class Bcp47Parser {
  static const Pattern kPrimarySubtagPattern =
      '[a-z]{1,8}'; // RFC3066 primary-subtag (RFC5646 amends it and allows digits on the first character)
  static const kSubtagMinLength = 1;
  static const kSubtagMaxLength = 8;
  static Pattern composeSubtagSafeSuffixPattern({
    required Pattern separatorPattern,
  }) =>
      '(?:(?=$separatorPattern)|\$)';

  static Pattern composeSubtagPattern({
    required int minLength,
  }) =>
      '[a-z\\d]{${max(kSubtagMinLength, min(kSubtagMaxLength, minLength))},8}';

  static String composeLanguageSubtagsPattern({
    required Pattern primarySubtagPattern,
    required int subtagMinLength,
    required Pattern separatorPattern,
  }) {
    final subtagSuffixPattern =
        composeSubtagSafeSuffixPattern(separatorPattern: separatorPattern);

    final primarySubtagPattern_ = '$primarySubtagPattern$subtagSuffixPattern';

    final subtagsPattern =
        '(?:$separatorPattern${composeSubtagPattern(minLength: subtagMinLength)}$subtagSuffixPattern)+';

    return '${primarySubtagPattern_.namedCapture('primary')}${subtagsPattern.namedCapture('subtags')}';
  }

  static const Pattern kSingletonPattern = '[\\da-z]';
  static const kExtensionSubtagMinLength = 2;
  static const Pattern kExtensionSingletonPattern = '[\\da-wy-z]';
  static final Pattern kPrivateUseSingletonPattern =
      RegExp.escape(Bcp47PrivateUseTag.kSingleton);
  static const kPrivateUseSubtagMinLength = 1;
  static const Pattern kLangTagLanguagePattern = r'[a-z]{2,8}';
  static const int kLangTagPrimaryTagMinLength = 2;
  static const Pattern kLangTagPrimaryTagPattern23 =
      r'[a-z]{2,3}'; // pattern with extlangs
  static const Pattern kLangTagPrimaryTagPattern48 =
      r'[a-z]{4,8}'; // pattern without extlangs
  static const kLangTagExtLangMaxSubtags = 3;
  static const Pattern kLangTagExtlangPattern = r'[a-z]{3}';
  static Pattern composeLangTagLanguagePattern({
    required Pattern separatorPattern,
  }) {
    final subtagSuffixPattern =
        composeSubtagSafeSuffixPattern(separatorPattern: separatorPattern);

    final extlangsPattern =
        '(?:$separatorPattern$kLangTagExtlangPattern$subtagSuffixPattern){0,$kLangTagExtLangMaxSubtags}';

    final primaryTagPattern23 =
        '$kLangTagPrimaryTagPattern23$subtagSuffixPattern';
    final primaryTagPattern48 =
        '$kLangTagPrimaryTagPattern48$subtagSuffixPattern';

    final pattern1 =
        '${primaryTagPattern23.namedCapture('primary23')}${extlangsPattern.namedCapture('extlangs')}';
    final pattern2 = primaryTagPattern48.namedCapture('primary48');

    return '(?:$pattern1|$pattern2)';
  }

  static const kLangTagScriptPattern = r'[a-z]{4}';
  static const kLangTagRegionPattern = r'(?:[a-z]{2}|\d{3})';
  static const kLangTagVariantPattern = r'(?:[a-z\d]{5,8}|\d[a-z\d]{3})';
  static Pattern composeLangTagPattern({
    required Pattern separatorPattern,
  }) {
    final subtagSuffixPattern =
        composeSubtagSafeSuffixPattern(separatorPattern: separatorPattern);

    final languagePattern =
        composeLangTagLanguagePattern(separatorPattern: separatorPattern);

    final scriptPattern =
        '(?:$separatorPattern${kLangTagScriptPattern.namedCapture('script')}$subtagSuffixPattern)?';
    final regionPattern =
        '(?:$separatorPattern${kLangTagRegionPattern.namedCapture('region')}$subtagSuffixPattern)?';
    final variantsPattern =
        '(?:$separatorPattern$kLangTagVariantPattern$subtagSuffixPattern)*'
            .namedCapture('variants');

    return '$languagePattern$scriptPattern$regionPattern$variantsPattern';
  }

  static Bcp47SingletonTag? parseSingleton(
    StringPointer pointer, {
    required Pattern singletonCharPattern,
    required int subtagMinLength,
    Pattern? separatorPattern,
  }) {
    final pattern = composeLanguageSubtagsPattern(
      primarySubtagPattern: singletonCharPattern,
      subtagMinLength: subtagMinLength,
      separatorPattern: separatorPattern ?? kBcp47SeparatorPattern,
    );

    final match = RegExp(
      '^$pattern',
      caseSensitive: false,
    ).firstMatch(pointer.value);

    if (match == null) {
      return null;
    }

    pointer += match.end;

    final Bcp47Singleton singleton = match.namedGroup('primary')!;

    final Bcp47Subtags otherSubtags = match
        .namedGroup('subtags')!
        .split(RegExp(
          (separatorPattern ?? kBcp47Separator).toString(),
          caseSensitive: false,
        ))
        .skip(1);

    return Bcp47SingletonTag(
      singletonCharPattern,
      subtagMinLength,
      singleton: singleton,
      otherSubtags: otherSubtags,
    );
  }

  static Bcp47Extension? parseExtension(
    StringPointer pointer, {
    required Pattern singletonCharPattern,
    Pattern? separatorPattern,
  }) {
    final base = parseSingleton(
      pointer,
      singletonCharPattern: singletonCharPattern,
      subtagMinLength: kExtensionSubtagMinLength,
      separatorPattern: separatorPattern,
    );

    return base == null
        ? null
        : Bcp47Extension(
            singleton: base.singleton,
            otherSubtags: base.otherSubtags,
          );
  }

  static Bcp47PrivateUseTag? parsePrivateUseTag(
    StringPointer pointer, {
    Pattern? separatorPattern,
  }) {
    final base = parseSingleton(
      pointer,
      singletonCharPattern: kPrivateUseSingletonPattern,
      subtagMinLength: kPrivateUseSubtagMinLength,
      separatorPattern: separatorPattern,
    );

    return base == null
        ? null
        : Bcp47PrivateUseTag(
            singleton: base.singleton,
            otherSubtags: base.otherSubtags,
          );
  }

  static Bcp47GrandfatheredTag? parseGrandfatheredTag(
    StringPointer pointer, {
    Pattern? separatorPattern,
  }) {
    final pattern = composeLanguageSubtagsPattern(
      primarySubtagPattern: kPrimarySubtagPattern,
      subtagMinLength: kSubtagMinLength,
      separatorPattern: separatorPattern ?? kBcp47SeparatorPattern,
    );

    final match = RegExp(
      '^$pattern',
      caseSensitive: false,
    ).firstMatch(pointer.value);

    if (match == null) {
      return null;
    }

    pointer += match.end;

    final subtags = [
      match.namedGroup('primary')!,
      ...match
          .namedGroup('subtags')!
          .split(RegExp(
            (separatorPattern ?? kBcp47Separator).toString(),
            caseSensitive: false,
          ))
          .skip(1),
    ];

    return Bcp47GrandfatheredTag(subtags: subtags);
  }

  static bool parseSeparator(
    StringPointer pointer, {
    Pattern? separatorPattern,
  }) {
    final match = RegExp(
      '^(?:${separatorPattern ?? kBcp47SeparatorPattern})',
      caseSensitive: false,
    ).firstMatch(pointer.value);

    if (match == null) {
      return false;
    }

    pointer += match.end;

    return true;
  }

  static Iterable<Bcp47Extension> parseExtensions(
    StringPointer pointer, {
    Pattern? separatorPattern,
  }) {
    final extensions = <Bcp47Extension>[];

    int lastOffset = pointer.offset;

    do {
      final extension = parseExtension(
        pointer,
        singletonCharPattern: kExtensionSingletonPattern,
        separatorPattern: separatorPattern,
      );

      if (extension == null) {
        pointer.offset = lastOffset;
        break;
      }

      lastOffset = pointer.offset;

      extensions.add(extension);
    } while (parseSeparator(pointer, separatorPattern: separatorPattern));

    return extensions;
  }

  static Bcp47LangTag? parseLangTag(
    StringPointer pointer, {
    Pattern? separatorPattern,
    bool withExtensionsAndPrivateUse = true,
  }) {
    final pattern = composeLangTagPattern(
      separatorPattern: separatorPattern ?? kBcp47SeparatorPattern,
    );

    final match = RegExp(
      '^$pattern',
      caseSensitive: false,
    ).firstMatch(pointer.value);

    pointer += match?.end ?? 0;

    Bcp47Subtag? language =
        match?.namedGroup('primary23') ?? match?.namedGroup('primary48');
    final extlangs = match
        ?.namedGroup('extlangs')
        ?.split(RegExp(
          (separatorPattern ?? kBcp47Separator).toString(),
          caseSensitive: false,
        ))
        .skip(1);
    Bcp47Subtag? script = match?.namedGroup('script');
    Bcp47Subtag? region = match?.namedGroup('region');
    final variants = match
        ?.namedGroup('variants')
        ?.split(RegExp(
          (separatorPattern ?? kBcp47Separator).toString(),
          caseSensitive: false,
        ))
        .skip(1);

    if (language == null) {
      return null;
    }

    Iterable<Bcp47Extension>? extensions;
    Bcp47PrivateUseTag? privateUse;

    if (withExtensionsAndPrivateUse) {
      int lastOffset = pointer.offset;

      if (parseSeparator(pointer, separatorPattern: separatorPattern)) {
        extensions = parseExtensions(
          pointer,
          separatorPattern: separatorPattern,
        );

        if (extensions.isEmpty) {
          pointer.offset = lastOffset;
        }
      }

      lastOffset = pointer.offset;

      if (parseSeparator(pointer, separatorPattern: separatorPattern)) {
        privateUse = parsePrivateUseTag(
          pointer,
          separatorPattern: separatorPattern,
        );

        if (privateUse == null) {
          pointer.offset = lastOffset;
        }
      }
    }

    return Bcp47LangTag(
      language: language,
      extlangs: extlangs ?? const [],
      script: script,
      region: region,
      variants: variants ?? const [],
      extensions: extensions ?? const [],
      privateUse: privateUse,
    );
  }

  static Bcp47BasicLanguageRange? parseBasicLanguageRange(
    StringPointer pointer, {
    Pattern? separatorPattern,
  }) {
    if (pointer.value.startsWith('*')) {
      pointer++;

      return Bcp47BasicLanguageRange();
    }

    final pattern = composeLanguageSubtagsPattern(
      primarySubtagPattern: kPrimarySubtagPattern,
      subtagMinLength: kSubtagMinLength,
      separatorPattern: separatorPattern ?? kBcp47SeparatorPattern,
    );

    final match = RegExp(
      '^$pattern',
      caseSensitive: false,
    ).firstMatch(pointer.value);

    if (match == null) {
      return null;
    }

    pointer += match.end;

    final Bcp47Subtag primarySubtag = match.namedGroup('primary')!;

    final Bcp47Subtags otherSubtags = match
        .namedGroup('subtags')!
        .split(RegExp(
          (separatorPattern ?? kBcp47Separator).toString(),
          caseSensitive: false,
        ))
        .skip(1);

    return Bcp47BasicLanguageRange(
      subtags: [
        primarySubtag,
        ...otherSubtags,
      ],
    );
  }
}
