// SPDX-FileCopyrightText: © 2023 - 2026 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:ac_dart_essentials/ac_dart_essentials.dart';

import 'bcp47_extension.dart';
import 'bcp47_parser.dart';
import 'bcp47_singleton_tag.dart';
import 'bcp47_typedefs.dart';

/// Validates that [subtags] form a well-formed basic language range.
///
/// Accepts `['*']` (wildcard) or a list where the first element matches the
/// RFC 3066 primary-subtag pattern and subsequent elements match the general
/// subtag pattern. Throws [ArgumentError] otherwise.
void bcp47ValidateBasicLanguageRangeSubtagsFormat({
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

/// Validates that [values] form a well-formed extended language range.
///
/// The first value must be a valid primary subtag or `'*'`. Subsequent
/// values must be valid subtags or `'*'`. Throws [ArgumentError] otherwise.
void bcp47ValidateExtendedLanguageRangeValuesFormat({
  Iterable<String> values = const [],
}) {
  if (values.first != '*' &&
      !Bcp47Parser.kPrimarySubtagPattern.entireMatchI(values.first)) {
    throw ArgumentError.value(values.first);
  }

  final subtagPattern = Bcp47Parser.composeSubtagPattern(
    minLength: Bcp47Parser.kSubtagMinLength,
  );

  if (!values.skip(1).every((e) => e == '*' || subtagPattern.entireMatchI(e))) {
    throw ArgumentError.value(values);
  }
}

/// Validates the format of `langtag` constituent subtags.
///
/// Checks:
/// - `language`: 2–8 alpha characters.
/// - `extlangs`: at most 3 elements, each exactly 3 alpha characters.
/// - `script`: exactly 4 alpha characters (if present).
/// - `region`: 2 alpha or 3 digit characters (if present).
/// - `variants`: each 5–8 alphanumeric or starting with a digit + 3 chars;
///   no duplicates allowed.
/// - `extensions`: no two extensions may share the same singleton.
///
/// Throws [ArgumentError] on any violation.
void bcp47ValidateLangTagSubtagsFormat({
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
  if (variants.map((e) => e.toLowerCase()).toSet().length != variants.length) {
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

/// Validates that [singleton] matches [singletonPattern] and that all
/// [otherSubtags] are at least [otherSubtagMinLength] characters long
/// (and at most 8). Throws [ArgumentError] otherwise.
void bcp47ValidateSingletonTagSubtagsFormat(
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

/// Internal validation helpers used by constructors across the public API.
///
/// All methods forward to the corresponding top-level `bcp47Validate…`
/// functions. Prefer calling those directly.
@Deprecated('Use top-level bcp47Validate… functions instead.')
class Bcp47Validator {
  @Deprecated('Use bcp47ValidateBasicLanguageRangeSubtagsFormat instead.')
  static void validateBasicLanguageRangeSubtagsFormat({
    Bcp47Subtags subtags = const [],
  }) =>
      bcp47ValidateBasicLanguageRangeSubtagsFormat(subtags: subtags);

  @Deprecated('Use bcp47ValidateExtendedLanguageRangeValuesFormat instead.')
  static void validateExtendedLanguageRangeValuesFormat({
    Iterable<String> values = const [],
  }) =>
      bcp47ValidateExtendedLanguageRangeValuesFormat(values: values);

  @Deprecated('Use bcp47ValidateLangTagSubtagsFormat instead.')
  static void validateLangTagSubtagsFormat({
    required Bcp47Subtag language,
    Bcp47Subtags extlangs = const [],
    Bcp47Subtag? script,
    Bcp47Subtag? region,
    Bcp47Subtags variants = const [],
    Iterable<Bcp47Extension> extensions = const [],
  }) =>
      bcp47ValidateLangTagSubtagsFormat(
        language: language,
        extlangs: extlangs,
        script: script,
        region: region,
        variants: variants,
        extensions: extensions,
      );

  @Deprecated('Use bcp47ValidateSingletonTagSubtagsFormat instead.')
  static void validateSingletonTagSubtagsFormat(
    Pattern singletonPattern,
    int otherSubtagMinLength, {
    required Bcp47Singleton singleton,
    Bcp47Subtags otherSubtags = const [],
  }) =>
      bcp47ValidateSingletonTagSubtagsFormat(
        singletonPattern,
        otherSubtagMinLength,
        singleton: singleton,
        otherSubtags: otherSubtags,
      );
}
