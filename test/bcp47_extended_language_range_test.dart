import 'package:bcp47/bcp47.dart';
import 'package:test/test.dart';

void main() {
  const dataset = {
    'de-*-DE': [
      ['de-DE', true], // (German, as used in Germany)
      ['de-de', true], // (German, as used in Germany)
      ['de-Latn-DE', true], // (Latin script)
      ['de-Latf-DE', true], // (Fraktur variant of Latin script)
      ['de-DE-x-goethe', true], // (private-use subtag)
      ['de-Latn-DE-1996', true], // (orthography of 1996)
      ['de-Deva-DE', true], // (Devanagari script)
      ['de', false], // (missing 'DE')
      ['de-x-DE', false], // (singleton 'x' occurs before 'DE')
      ['de-Deva', false], // ('Deva' not equal to 'DE')
    ],
  };

  for (final data in dataset.entries) {
    for (final value in data.value) {
      test('test "${data.key}" against "${value.first}"', () {
        final extendedLanguageRange =
            Bcp47ExtendedLanguageRange.parse(data.key);

        final languageTag = Bcp47LanguageTag.parse(value.first as String);

        expect(extendedLanguageRange.match(languageTag), equals(value[1]));
      });
    }
  }
}
