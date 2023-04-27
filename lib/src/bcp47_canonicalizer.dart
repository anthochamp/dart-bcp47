// ignore_for_file: avoid-missing-enum-constant-in-map

import 'package:anthochamp_dart_essentials/dart_essentials.dart';
import 'package:collection/collection.dart';

import 'bcp47_extended_language_range.dart';
import 'bcp47_grandfathered_tag.dart';
import 'bcp47_iana_data.dart';
import 'bcp47_lang_tag.dart';
import 'bcp47_language_tag.dart';
import 'bcp47_typedefs.dart';

// https://www.rfc-editor.org/rfc/rfc5646.html#section-4.5
class Bcp47Canonicalizer {
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
      canonicalized = canonicalized.replace({
        Bcp47LangTagSubtag.extension: canonicalized.extensions
            .map((e) => e.canonicalized)
            .sorted((a, b) => a.singleton.compareToI(b.singleton)),
      });
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

        canonicalizedLangTag = canonicalizedLangTag.replace({
          Bcp47LangTagSubtag.language: replacement,
        });
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

        canonicalizedLangTag = canonicalizedLangTag.replace({
          Bcp47LangTagSubtag.language: replacement,
          Bcp47LangTagSubtag.extlang: canonicalizedLangTag.extlangs.toList()
            ..removeWhere((e) => e.compareToI(from) == 0),
        });
      }

      for (final entry in kBcp47IanaRegionPreferredValue) {
        final from = entry.first;
        final replacement = entry.last;

        if (canonicalizedLangTag.region?.compareToI(from) != 0) {
          continue;
        }

        canonicalizedLangTag = canonicalizedLangTag.replace({
          Bcp47LangTagSubtag.region: replacement,
        });
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

        canonicalizedLangTag = canonicalizedLangTag.replace({
          Bcp47LangTagSubtag.variant: canonicalizedLangTag.variants.toList()
            ..removeWhere((e) => e.compareToI(from) == 0)
            ..add(replacement),
        });
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

          canonicalizedLangTag = canonicalizedLangTag.replace({
            Bcp47LangTagSubtag.language: prefixBasicRange.primarySubtag,
            Bcp47LangTagSubtag.extlang: [
              ...prefixBasicRange.otherSubtags,
              value,
            ],
          });
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
      return langTag.replace({
        Bcp47LangTagSubtag.script: null,
      });
    }

    return langTag;
  }

  static Bcp47LanguageTag normalizeCasing(Bcp47LanguageTag languageTag) {
    return Bcp47LanguageTag.parse(languageTag.format(caseNormalized: true));
  }

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
      currentLangTag = currentLangTag.replace({
        Bcp47LangTagSubtag.variant: [
          ...orderedVariants,
          ...orderedGeneralPurposedVariants,
        ],
      });

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
        variantsLangTag[variant] = currentLangTag.replace({
          Bcp47LangTagSubtag.variant: [
            ...currentLangTag.variants,
            variant,
          ],
        });
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
    currentLangTag = currentLangTag.replace({
      Bcp47LangTagSubtag.variant: [
        ...orderedVariants,
        ...[
          ...variantsPrefixes.keys,
          ...orderedGeneralPurposedVariants,
        ].sorted((a, b) => a.compareToI(b)),
      ],
    });

    return currentLangTag;
  }
}
