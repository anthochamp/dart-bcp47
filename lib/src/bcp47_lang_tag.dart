// SPDX-FileCopyrightText: © 2023 - 2026 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'package:ac_dart_essentials/ac_dart_essentials.dart';
import 'package:meta/meta.dart';

import 'bcp47_extension.dart';
import 'bcp47_formatter.dart';
import 'bcp47_language_tag.dart';
import 'bcp47_language_tag_mixin.dart';
import 'bcp47_parser.dart';
import 'bcp47_private_use_tag.dart';
import 'bcp47_typedefs.dart';
import 'bcp47_validator.dart';

// Sentinel used by copyWith to distinguish "not provided" from explicit null.
const _kAbsent = Object();

/// Identifies a field within a [Bcp47LangTag].
///
/// Used as a key in [Bcp47LangTag.get] and [Bcp47LangTag.replace].
enum Bcp47LangTagSubtag {
  /// Primary language subtag (e.g. `en`, `zh`).
  language,

  /// Extended language subtags (up to 3, e.g. `cmn` in `zh-cmn-Hans-CN`).
  extlang,

  /// Script subtag (e.g. `Latn`, `Hans`).
  script,

  /// Region subtag — ISO 3166-1 alpha-2 or UN M.49 (e.g. `US`, `419`).
  region,

  /// Variant subtags (e.g. `rozaj`, `1901`).
  variant,

  /// Extension subtags (singleton + subtags, e.g. `u-ca-gregory`).
  extension,

  /// Private-use subtag sequence (e.g. `x-phonebk`).
  privateUse,
}

/// A BCP-47 `langtag` as defined in RFC 5646 §2.1.
///
/// Represents the most common tag form: language (+ optional extlang, script,
/// region, variants, extensions, and private-use suffix).
///
/// All fields are validated in the constructor; only well-formed subtag values
/// are accepted (throws [ArgumentError] otherwise).
///
/// Example:
/// ```dart
/// final tag = Bcp47LangTag.parse('zh-cmn-Hans-CN');
/// print(tag.language);          // zh
/// print(tag.extlangs);          // [cmn]
/// print(tag.script);            // Hans
/// print(tag.region);            // CN
/// print(tag.format(caseNormalized: true)); // zh-cmn-Hans-CN
/// ```
@immutable
class Bcp47LangTag extends Bcp47LanguageTagMixin implements Bcp47LanguageTag {
  /// Primary language subtag (2–8 alpha characters, e.g. `'en'`, `'zh'`).
  final Bcp47Subtag language;

  /// Extended language subtags (0–3 items, each 3 alpha characters).
  final Bcp47Subtags extlangs;

  /// Script subtag (4 alpha characters, e.g. `'Latn'`, `'Hans'`), or `null`.
  final Bcp47Subtag? script;

  /// Region subtag (ISO 3166-1 alpha-2 or UN M.49 numeric, e.g. `'US'`,
  /// `'419'`), or `null`.
  final Bcp47Subtag? region;

  /// Variant subtags (each 5–8 alphanumeric or starting with a digit).
  final Bcp47Subtags variants;

  /// Extension sequences (singleton ≠ `x` followed by 2+ char subtags).
  final Iterable<Bcp47Extension> extensions;

  /// Private-use suffix (`x-...`), or `null`.
  final Bcp47PrivateUseTag? privateUse;

  Bcp47LangTag({
    required this.language,
    this.extlangs = const [],
    this.script,
    this.region,
    this.variants = const [],
    this.extensions = const [],
    this.privateUse,
  }) {
    Bcp47Validator.validateLangTagSubtagsFormat(
      language: language,
      extlangs: extlangs,
      script: script,
      region: region,
      variants: variants,
      extensions: extensions,
    );
  }

  /// Parses [string] as a `langtag`.
  ///
  /// Throws [ArgumentError] if [string] is not a well-formed `langtag`
  /// (use [Bcp47LanguageTag.parse] if the tag type is unknown).
  ///
  /// [separatorPattern] overrides the default `-` separator.
  factory Bcp47LangTag.parse(
    String string, {
    Pattern? separatorPattern,
  }) {
    final pointer = StringPointer(string);

    final instance = Bcp47Parser.parseLangTag(
      pointer,
      separatorPattern: separatorPattern,
    )!;

    if (pointer.value.isNotEmpty) {
      throw ArgumentError.value(string);
    }

    return instance;
  }

  @override
  Bcp47Subtag get primarySubtag => language;

  @override
  Bcp47Subtags get otherSubtags => [
        ...extlangs,
        if (script != null) script!,
        if (region != null) region!,
        ...variants,
        ...extensions.expand((element) => [
              element.primarySubtag,
              ...element.otherSubtags,
            ]),
        if (privateUse != null) ...[
          privateUse!.primarySubtag,
          ...privateUse!.otherSubtags,
        ],
      ];

  /// Returns the value of the named [subtag] field.
  ///
  /// The return type depends on the subtag:
  /// - `language` → [Bcp47Subtag]
  /// - `extlang`, `variant` → [Bcp47Subtags]
  /// - `script`, `region` → `Bcp47Subtag?`
  /// - `extension` → `Iterable<Bcp47Extension>`
  /// - `privateUse` → `Bcp47PrivateUseTag?`
  dynamic get(Bcp47LangTagSubtag subtag) {
    switch (subtag) {
      case Bcp47LangTagSubtag.language:
        return language;
      case Bcp47LangTagSubtag.extlang:
        return extlangs;
      case Bcp47LangTagSubtag.script:
        return script;
      case Bcp47LangTagSubtag.region:
        return region;
      case Bcp47LangTagSubtag.variant:
        return variants;
      case Bcp47LangTagSubtag.extension:
        return extensions;
      case Bcp47LangTagSubtag.privateUse:
        return privateUse;
    }
  }

  /// Returns a copy of this tag with the specified fields replaced.
  ///
  /// Only named arguments that are explicitly provided are substituted; all
  /// other fields retain their current value.  For the nullable fields
  /// [script], [region], and [privateUse], pass `null` explicitly to clear
  /// them — omitting the argument leaves them unchanged.
  ///
  /// Example:
  /// ```dart
  /// final tag = Bcp47LangTag.parse('en-Latn-GB');
  /// tag.copyWith(region: 'US');   // en-Latn-US
  /// tag.copyWith(script: null);   // en-GB
  /// ```
  Bcp47LangTag copyWith({
    Bcp47Subtag? language,
    Bcp47Subtags? extlangs,
    Object? script = _kAbsent,
    Object? region = _kAbsent,
    Bcp47Subtags? variants,
    Iterable<Bcp47Extension>? extensions,
    Object? privateUse = _kAbsent,
  }) {
    return Bcp47LangTag(
      language: language ?? this.language,
      extlangs: extlangs ?? this.extlangs,
      script: identical(script, _kAbsent) ? this.script : script as Bcp47Subtag?,
      region: identical(region, _kAbsent) ? this.region : region as Bcp47Subtag?,
      variants: variants ?? this.variants,
      extensions: extensions ?? this.extensions,
      privateUse: identical(privateUse, _kAbsent)
          ? this.privateUse
          : privateUse as Bcp47PrivateUseTag?,
    );
  }

  /// Returns a copy of this tag with the given [values] substituted.
  ///
  /// Only the entries present in [values] are replaced; all other fields
  /// remain unchanged. Pass `null` for nullable fields (`script`, `region`,
  /// `privateUse`) to clear them.
  ///
  /// Prefer [copyWith] for type-safe field replacement.
  ///
  /// Example:
  /// ```dart
  /// final usTag = Bcp47LangTag.parse('en-GB').replace({
  ///   Bcp47LangTagSubtag.region: 'US',
  /// });
  /// print(usTag); // en-US
  /// ```
  @Deprecated('Use copyWith for type-safe field replacement.')
  Bcp47LangTag replace(Map<Bcp47LangTagSubtag, dynamic> values) {
    return Bcp47LangTag(
      language: values.containsKey(Bcp47LangTagSubtag.language)
          ? values[Bcp47LangTagSubtag.language]
          : language,
      extlangs: values.containsKey(Bcp47LangTagSubtag.extlang)
          ? values[Bcp47LangTagSubtag.extlang] ?? const []
          : extlangs,
      script: values.containsKey(Bcp47LangTagSubtag.script)
          ? values[Bcp47LangTagSubtag.script]
          : script,
      region: values.containsKey(Bcp47LangTagSubtag.region)
          ? values[Bcp47LangTagSubtag.region]
          : region,
      variants: values.containsKey(Bcp47LangTagSubtag.variant)
          ? values[Bcp47LangTagSubtag.variant] ?? const []
          : variants,
      extensions: values.containsKey(Bcp47LangTagSubtag.extension)
          ? values[Bcp47LangTagSubtag.extension] ?? const []
          : extensions,
      privateUse: values.containsKey(Bcp47LangTagSubtag.privateUse)
          ? values[Bcp47LangTagSubtag.privateUse]
          : privateUse,
    );
  }

  @override
  String format({bool? caseNormalized, String? separator}) =>
      Bcp47Formatter.formatLangTagSubtags(
        language: language,
        extlangs: extlangs,
        script: script,
        region: region,
        variants: variants,
        extensions: extensions,
        privateUse: privateUse,
        caseNormalized: caseNormalized,
        separator: separator,
      );
}
