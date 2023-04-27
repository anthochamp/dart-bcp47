# BCP-47

BCP-47 related types with parsing, formatting, canonicalization and format validation.

## Features

The following types are implemented :
- [RFC 5646](https://datatracker.ietf.org/doc/html/rfc5646) Language-Tag (langtag, grandfathered, privateuse), 
- [RFC 4647](https://datatracker.ietf.org/doc/html/rfc4647) [Basic](https://datatracker.ietf.org/doc/html/rfc4647#section-2.1) and [Extended](https://datatracker.ietf.org/doc/html/rfc4647#section-2.2) Language Range.

What it implements : 
- **Parsing** and **formatting** (with letter case normalisation),
- **Validation** of well-formed Language-Tag / Language Range,
- **Canonicalization** of Language-Tag with [IANA Language Subtag Registry](https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry),
- Basic and Extended **filtering** (cf. [RFC 4647 section 3.3](https://datatracker.ietf.org/doc/html/rfc4647#section-3.3))
- Support for alternative subtags separator (like the underscore in CLDR data).

What it does NOT implement:
- Validation of Language-Tag subtags against IANA registry data (except for grandfathered tags).

## Usage

### Language-Tag 

If you're unsure what type of Language-Tag you're parsing, use `Bcp47LanguageTag.parse` :

```dart
const strings = [
  'en',
  'i-unknown',
  'x-private',
];

for (final string in strings) {
    const languageTag = Bcp47LanguageTag.parse(string);

    // print primary and other subtags separately (RFC-3066 format)
    print(languageTag.primarySubtag);
    print(languageTag.otherSubtags);
    
    // print all the subtags
    print(languageTag.subtags);

    if (languageTag is Bcp47LangTag) {
        print(langTag.language);
        print(langTag.extlangs);
        print(langTag.script);
        print(langTag.region);
        print(langTag.extensions);
        print(langTag.privateUse);
    } else if (languageTag is Bcp47GrandfatheredTag) {
        print(languageTag.irregular);
    } else if (languageTag is Bcp47PrivateUseTag) {
        print(languageTag.singleton);
    }

    // print a case-normalized version of the tag
    print(languageTag.format(caseNormalized: true));
}
```

else you can use directly the correct type :

```dart 
const langTagString = 'en-US';

const langTag = Bcp47LangTag.parse(langTagString);
```

### Basic Language Range

```dart

final range = Bcp47BasicLanguageRange.parse('en');

final enUs = Bcp47LanguageTag.parse('en-US');
final frFr = Bcp47LanguageTag.parse('fr-FR');

// true
print(range.match(enUs));

// false
print(range.match(frFr));
```

### Extended Language Range

```dart

final range = Bcp47ExtendedLanguageRange.parse('en-*-US');

final enUs = Bcp47LanguageTag.parse('en-US');
final enLatnUs = Bcp47LanguageTag.parse('en-Latn-US');
final enLatnCa = Bcp47LanguageTag.parse('en-Latn-CA');

// true
print(range.match(enUs));

// true
print(range.match(enLatnUs));

// false
print(range.match(enLatnCa));
```


