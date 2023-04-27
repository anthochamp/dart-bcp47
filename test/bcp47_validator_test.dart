void main() {
// https://web.archive.org/web/20210512041450/http://langtag.net/test-suites/invalid-tags.txt
  const kInvalidTags = [
    'ax-TZ', // Not in the registry, but well-formed
    'fra-Latn', // ISO 639 can be 3-letters
    'fra',
    'fra-FX',
    'abcd-Latn', // Language of 4 chars reserved for future use
    'AaBbCcDd-x-y-any-x', // Language of 5-8 chars, registered
    'zh-Latm-CN', // Typo
    'de-DE-1902', // Wrong variant
    'fr-shadok', // Variant
  ];

// https://web.archive.org/web/20210512051148/http://langtag.net/test-suites/valid-tags.txt
  const kValidTags = [
    'fr',
    'fr-Latn',
    'fr-fra', // Extended tag
    'fr-Latn-FR',
    'fr-Latn-419',
    'fr-FR',
    'fr-y-myext-myext2',
    'apa-Latn', // ISO 639 can be 3-letters
    'apa',
    'apa-CA',
    'i-klingon', // grandfathered with singleton
    'no-bok', // grandfathered without singleton
    'fr-Lat', // Extended
    'mn-Cyrl-MN',
    'mN-cYrL-Mn',
    'fr-Latn-CA',
    'en-US',
    'fr-Latn-CA',
    'i-enochian', // Grand fathered
    'x-fr-CH',
    'sr-Latn-CS',
    'es-419',
    'sl-nedis',
    'de-CH-1996',
    'de-Latg-1996',
    'sl-IT-nedis',
    'en-a-bbb-x-a-ccc',
    'de-a-value',
    'en-x-US',
    'az-Arab-x-AZE-derbend',
    'es-Latn-CO-x-private',
    'ab-x-abc-x-abc', // anything goes after x
    'ab-x-abc-a-a', // ditto
    'i-default', // grandfathered
    'i-klingon', // grandfathered
    'en',
    'de-AT',
    'es-419',
    'de-CH-1901',
    'sr-Cyrl',
    'sr-Cyrl-CS',
    'sl-Latn-IT-rozaj',
    'en-US-x-twain',
    'zh-cmn',
    'zh-cmn-Hant',
    'zh-cmn-Hant-HK',
    'zh-gan',
    'zh-yue-Hant-HK',
    'en-Latn-GB-boont-r-extended-sequence-x-private',
    'en-US-boont',
  ];
}
