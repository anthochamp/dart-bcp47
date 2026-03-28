// SPDX-FileCopyrightText: © 2023 - 2026 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

// ignore_for_file: avoid-missing-enum-constant-in-map

import 'package:ac_dart_essentials/ac_dart_essentials.dart';
import 'package:collection/collection.dart';

import 'bcp47_extended_language_range.dart';
import 'bcp47_grandfathered_tag.dart';
import 'bcp47_iana_data.dart';
import 'bcp47_lang_tag.dart';
import 'bcp47_language_tag.dart';
import 'bcp47_typedefs.dart';

/// Implements the RFC 5646 §4.5 canonicalization algorithm for BCP-47
/// language tags.
///
/// All methods are static; this class is not intended to be instantiated.
///
/// The main entry point is [canonicalize]. Additional helpers:
/// - [suppressScript] — removes a script subtag when it equals the language's
///   IANA suppress-script value.
/// - [normalizeCasing] — applies RFC 5646 §2.1.1 case rules.
/// - [reorderVariants] — reorders variant subtags per RFC 5646 §4.1 rule 6.
// https://www.rfc-editor.org/rfc/rfc5646.html#section-4.5
class Bcp47Canonicalizer {
  /// Canonicalizes [languageTag] according to RFC 5646 §4.5.
  ///
  /// Steps applied in order:
  /// 1. Extension singletons are sorted lexicographically.
  /// 2. Grandfathered / redundant tags are replaced by their IANA
  ///    `Preferred-Value`.
  /// 3. Language, extlang, region, and variant subtags are replaced by their
  ///    IANA `Preferred-Value` (deprecated tags → preferred replacements).
  ///
  /// Optional steps (disabled by default):
  /// - [variantsReordered]: reorder variant subtags per RFC 5646 §4.1 rule 6.
  /// - [caseNormalized]: apply RFC 5646 §2.1.1 case rules after all other
  ///   steps (language→lower, script→Title, region→UPPER).
  /// - [extlangForm]: if the primary language subtag is also a known extlang,
  ///   prepend its IANA prefix and move the language to the extlang position.
  ///
  /// Example:
  /// ```dart
  /// final tag = Bcp47LanguageTag.parse('zh-cmn');
  /// final canonical = Bcp47Canonicalizer.canonicalize(tag);
  /// print(canonical); // cmn  (extlang preferred value replaces language)
  /// ```
  static Bcp47LanguageTag canonicalize(
    Bcp47LanguageTag languageTag, {
    bool variantsReordered = false,
    bool caseNormalized = false,
    bool extlangForm = false,
  }) {
    Bcp47LanguageTag canonicalized = languageTag;

    // 1. Extension sequences are ordered into case-insensitive ASCII order
    // by singleton subtag.
    //
    // + An extension MUST define any relationships that exist between the
    // various subtags in the extension and thus MAY define an alternate
    // canonicalization scheme for the extension's subtags.
    if (canonicalized is Bcp47LangTag) {
      canonicalized = canonicalized.copyWith(
        extensions: canonicalized.extensions
            .map((e) => e.canonicalized)
            .sorted((a, b) => a.singleton.compareToI(b.singleton)),
      );
    }

    // 2. Redundant or grandfathered tags are replaced by their 'Preferred-
    // Value', if there is one.
    if (canonicalized is Bcp47GrandfatheredTag) {
      for (final entry in kBcp47IanaGrandfatheredPreferredValue) {
        final range = entry.first as Bcp47ExtendedLanguageRange;
        final replacement = entry.last as String;

        if (!range.match(canonicalized)) {
          continue;
        }

        canonicalized = Bcp47LanguageTag.parse(replacement);
        break;
      }
    }

    if (canonicalized is Bcp47LangTag) {
      Bcp47LangTag canonicalizedLangTag = canonicalized;

      for (final entry in kBcp47IanaRedundantPreferredValue) {
        final range = entry.first as Bcp47ExtendedLanguageRange;
        final replacement = entry.last as String;

        if (!range.match(canonicalizedLangTag)) {
          continue;
        }

        canonicalizedLangTag =
            Bcp47LanguageTag.parse(canonicalizedLangTag.format().replaceFirst(
                  RegExp('^${range.format()}', caseSensitive: false),
                  replacement,
                )) as Bcp47LangTag;

        break;
      }

      // 3. Subtags are replaced by their 'Preferred-Value', if there is one.
      for (final entry in kBcp47IanaLanguagePreferredValue) {
        final from = entry.first;
        final replacement = entry.last;

        if (canonicalizedLangTag.language.compareToI(from) != 0) {
          continue;
        }

        canonicalizedLangTag = canonicalizedLangTag.copyWith(
          language: replacement,
        );
      }

      // For extlangs, the original primary language subtag is also
      // replaced if there is a primary language subtag in the 'Preferred-
      // Value'.
      for (final entry in kBcp47IanaExtlangPreferredValue) {
        final range = entry.first as Bcp47ExtendedLanguageRange;
        final from = entry[1] as String;
        final replacement = entry[2] as String;

        if (!range.match(canonicalizedLangTag)) {
          continue;
        }

        canonicalizedLangTag = canonicalizedLangTag.copyWith(
          language: replacement,
          extlangs: canonicalizedLangTag.extlangs.toList()
            ..removeWhere((e) => e.compareToI(from) == 0),
        );
      }

      for (final entry in kBcp47IanaRegionPreferredValue) {
        final from = entry.first;
        final replacement = entry.last;

        if (canonicalizedLangTag.region?.compareToI(from) != 0) {
          continue;
        }

        canonicalizedLangTag = canonicalizedLangTag.copyWith(
          region: replacement,
        );
      }

      for (final entry in kBcp47IanaVariantPreferredValue) {
        final range = entry.first as Bcp47ExtendedLanguageRange?;
        final from = entry[1] as String;
        final replacement = entry[2] as String;

        bool match;
        if (range == null) {
          match =
              canonicalizedLangTag.variants.any((e) => e.compareToI(from) == 0);
        } else {
          match = range.match(canonicalizedLangTag);
        }

        if (!match) {
          continue;
        }

        canonicalizedLangTag = canonicalizedLangTag.copyWith(
          variants: canonicalizedLangTag.variants.toList()
            ..removeWhere((e) => e.compareToI(from) == 0)
            ..add(replacement),
        );
      }

      if (variantsReordered) {
        // If more than one variant appears within a tag, processors MAY reorder
        // the variants to obtain better matching behavior or more consistent
        // presentation.
        canonicalizedLangTag = reorderVariants(canonicalizedLangTag);
      }

      if (extlangForm) {
        // If the language tag starts with a primary language subtag that is
        // also an extlangs subtag, then the language tag is prepended with
        // the extlangs's 'Prefix'.

        for (final entry in kBcp47IanaPrefix) {
          final subtag = entry.first as Bcp47LangTagSubtag;
          final value = entry[1] as String;
          final prefix = entry[2] as Bcp47ExtendedLanguageRange;

          if (subtag != Bcp47LangTagSubtag.extlang ||
              canonicalizedLangTag.language.compareToI(value) != 0) {
            continue;
          }

          final prefixBasicRange = prefix.toBasicLanguageRange();

          canonicalizedLangTag = canonicalizedLangTag.copyWith(
            language: prefixBasicRange.primarySubtag,
            extlangs: [
              ...prefixBasicRange.otherSubtags,
              value,
            ],
          );
        }
      }

      canonicalized = canonicalizedLangTag;
    }

    // When performing canonicalization of language tags, processors MAY
    // regularize the case of the subtags.
    if (caseNormalized) {
      canonicalized = normalizeCasing(canonicalized);
    }

    return canonicalized;
  }

  /// Removes [langTag]'s script subtag if it equals the IANA
  /// `Suppress-Script` value for that language.
  ///
  /// Returns [langTag] unchanged if no script is set or if the script is not
  /// the suppress-script for the given language.
  ///
  /// Example:
  /// ```dart
  /// final tag = Bcp47LangTag.parse('en-Latn');
  /// print(Bcp47Canonicalizer.suppressScript(tag)); // en  (Latn is suppressed for 'en')
  /// ```
  static Bcp47LangTag suppressScript(Bcp47LangTag langTag) {
    if (langTag.script == null) {
      return langTag;
    }

    bool match = false;

    for (final entry in kBcp47IanaLanguageSuppressScript) {
      final language = entry.first;
      final script = entry.last;

      match = language.compareToI(langTag.language) == 0 &&
          script.compareToI(langTag.script!) == 0;
      if (match) break;
    }

    if (match) {
      return langTag.copyWith(script: null);
    }

    return langTag;
  }

  /// Returns [languageTag] re-parsed after applying RFC 5646 §2.1.1 casing.
  ///
  /// Equivalent to `Bcp47LanguageTag.parse(languageTag.format(caseNormalized: true))`.
  static Bcp47LanguageTag normalizeCasing(Bcp47LanguageTag languageTag) {
    return Bcp47LanguageTag.parse(languageTag.format(caseNormalized: true));
  }

  /// Reorders variant subtags in [langTag] according to RFC 5646 §4.1 rule 6.
  ///
  /// General-purpose variants (no `Prefix` in IANA registry) are placed last.
  /// Prefixed variants are ordered by dependency (more specific prefixes first).
  /// Ties are broken alphabetically. Returns [langTag] unchanged when fewer
  /// than two variants are present.
  static Bcp47LangTag reorderVariants(Bcp47LangTag langTag) {
    // From 6) of https://www.rfc-editor.org/rfc/rfc5646.html#section-4.1
    //
    // General purpose variants (those with no 'Prefix' fields
    // at all) SHOULD appear after any other variant subtags. Order any
    // remaining variants by placing the most significant subtag first.
    // If none of the subtags is more significant or no relationship can
    // be determined, alphabetize the subtags.
    //
    // For example:
    //
    // * The tag "en-scotland-fonipa" (English, Scottish dialect, IPA
    // phonetic transcription) is correctly ordered because
    // 'scotland' has a 'Prefix' of "en", while 'fonipa' has no
    // 'Prefix' field.
    //
    // * The tag "sl-IT-rozaj-biske-1994" is correctly ordered: 'rozaj'
    // lists "sl" as its sole 'Prefix'; 'biske' lists "sl-rozaj" as
    // its sole 'Prefix'.  The subtag '1994' has several prefixes,
    // including "sl-rozaj".  However, it follows both 'rozaj' and
    // 'biske' because one of its 'Prefix' fields is "sl-rozaj-
    // biske".

    if (langTag.variants.length <= 1) {
      return langTag;
    }

    final variantsPrefixes =
        <Bcp47Subtag, Iterable<Bcp47ExtendedLanguageRange>>{};
    final generalPurposedVariants = <Bcp47Subtag>[];

    for (final variant in langTag.variants) {
      final prefixes = <Bcp47ExtendedLanguageRange>[];

      for (final entry in kBcp47IanaPrefix) {
        final subtag = entry.first as Bcp47LangTagSubtag;
        final value = entry[1] as String;
        final prefix = entry[2] as Bcp47ExtendedLanguageRange;

        if (subtag == Bcp47LangTagSubtag.variant &&
            variant.compareToI(value) == 0) {
          prefixes.add(prefix);
        }
      }

      if (prefixes.isEmpty) {
        generalPurposedVariants.add(variant);
      } else {
        variantsPrefixes[variant] = prefixes;
      }
    }

    final orderedGeneralPurposedVariants =
        generalPurposedVariants.sorted((a, b) => a.compareToI(b));

    Bcp47LangTag currentLangTag = langTag;
    final orderedVariants = <Bcp47Subtag>[];

    do {
      currentLangTag = currentLangTag.copyWith(
        variants: [
          ...orderedVariants,
          ...orderedGeneralPurposedVariants,
        ],
      );

      final matchingVariantsPrefixes =
          <Bcp47Subtag, List<Bcp47ExtendedLanguageRange>>{};

      for (final variantPrefixesEntry in variantsPrefixes.entries) {
        for (final variantPrefix in variantPrefixesEntry.value) {
          if (variantPrefix.match(currentLangTag)) {
            matchingVariantsPrefixes[variantPrefixesEntry.key] ??= [];
            matchingVariantsPrefixes[variantPrefixesEntry.key]!
                .add(variantPrefix);
          }
        }
      }

      // if no more variants prefixes is matching currentLangTag, stop.
      // Leftovers will be sorted alphabetically with the general purposed
      // variants.
      if (matchingVariantsPrefixes.isEmpty) {
        break;
      }

      final variantsLangTag = <Bcp47Subtag, Bcp47LangTag>{};
      for (final variant in variantsPrefixes.keys) {
        variantsLangTag[variant] = currentLangTag.copyWith(
          variants: [
            ...currentLangTag.variants,
            variant,
          ],
        );
      }

      final variantsMatchOtherVariants = <Bcp47Subtag, bool>{};
      for (final variant in matchingVariantsPrefixes.keys) {
        bool match = false;

        for (final variantPrefix in variantsPrefixes[variant]!) {
          if (matchingVariantsPrefixes[variant]!.any(
            (element) => element == variantPrefix,
          )) {
            continue;
          }

          for (final variantLangTagEntry in variantsLangTag.entries) {
            if (variantLangTagEntry.key == variant) {
              continue;
            }

            match = variantPrefix.match(variantLangTagEntry.value);
            if (match) {
              break;
            }
          }

          if (match) {
            break;
          }
        }

        variantsMatchOtherVariants[variant] = match;
      }

      Bcp47Subtag? bestMatchingVariant;
      int? bestMatchingVariantPrefixBLRLength;

      for (final matchingVariantPrefixesEntry
          in matchingVariantsPrefixes.entries) {
        // if variant does not match any other variants, it has priority.
        if (variantsMatchOtherVariants[matchingVariantPrefixesEntry.key] !=
            true) {
          bestMatchingVariant = matchingVariantPrefixesEntry.key;
          break;
        }

        // else select the variant with the longest matching prefix
        final maxBLRLengthPrefix = maxBy(
          matchingVariantPrefixesEntry.value,
          (e) => e.toBasicLanguageRange().toString().length,
        );
        final prefixMaxBLRLength =
            maxBLRLengthPrefix!.toBasicLanguageRange().toString().length;

        if (bestMatchingVariant == null ||
            bestMatchingVariantPrefixBLRLength! < prefixMaxBLRLength) {
          bestMatchingVariant = matchingVariantPrefixesEntry.key;
          bestMatchingVariantPrefixBLRLength = prefixMaxBLRLength;
        }
      }

      orderedVariants.add(bestMatchingVariant!);

      variantsPrefixes.remove(bestMatchingVariant);
    } while (variantsPrefixes.isNotEmpty);

    // finalize by adding the last orderedVariants added and
    // leftovers to the sorted general purposed variants.
    currentLangTag = currentLangTag.copyWith(
      variants: [
        ...orderedVariants,
        ...[
          ...variantsPrefixes.keys,
          ...orderedGeneralPurposedVariants,
        ].sorted((a, b) => a.compareToI(b)),
      ],
    );

    return currentLangTag;
  }
}
