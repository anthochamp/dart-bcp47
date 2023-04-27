import 'package:test/test.dart';

import 'package:ac_bcp47/ac_bcp47.dart';

void main() {
  group('reorderVariants', () {
    const dataset = [
      ['aa-valencia-sotav-oxendict', 'aa-oxendict-sotav-valencia'],
      ['en-fonipa-scotland', 'en-scotland-fonipa'],
      ['sl-IT-1994-biske-rozaj', 'sl-IT-rozaj-biske-1994'],
      ['oc-grclass-aranes-auvern', 'oc-aranes-auvern-grclass'],
      ['ja-Latn-heploc-hepburn', 'ja-Latn-hepburn-heploc'],
    ];
    for (final data in dataset) {
      test('${data.first} -> ${data.last}', () {
        Bcp47LanguageTag languageTag = Bcp47LanguageTag.parse(data.first);

        if (languageTag is Bcp47LangTag) {
          languageTag = Bcp47Canonicalizer.reorderVariants(languageTag);
        }

        expect(languageTag.format(), data.last);
      });
    }
  });

  group('Suppress-Script', () {
    const dataset = [
      ['is-Latn', 'is'],
    ];

    for (final data in dataset) {
      test('${data.first} -> ${data.last}', () {
        Bcp47LanguageTag languageTag = Bcp47LanguageTag.parse(data.first);

        if (languageTag is Bcp47LangTag) {
          languageTag = Bcp47Canonicalizer.suppressScript(languageTag);
        }

        expect(languageTag.format(), data.last);
      });
    }
  });

  group('Misc tests', () {
    const dataset = [
      ['sgn-BE-FR', 'sfb'],
      ['no-nyn', 'nn'],
      ['i-klingon', 'tlh'],
      ['zh-hak', 'hak'],
      ['en-BU', 'en-MM'],
      ['iw', 'he'],
      ['en-ZR', 'en-CD'],
      ['zh-yue-Hant-HK', 'yue-Hant-HK'],
      ['ja-Latn-hepburn-heploc', 'ja-Latn-hepburn-alalc97'],
      ['en-b-warble-a-babble', 'en-a-babble-b-warble'],
      ['en-b-ccc-bbb-a-aaa-X-xyz', 'en-a-aaa-b-ccc-bbb-X-xyz'],
    ];

    for (final data in dataset) {
      test('${data.first} -> ${data.last}', () {
        final languageTag = Bcp47LanguageTag.parse(data.first);

        Bcp47LanguageTag canonicalized =
            Bcp47Canonicalizer.canonicalize(languageTag);

        expect(canonicalized.format(), data.last);
      });
    }
  });
}
