import 'package:anthochamp_dart_essentials/dart_essentials.dart';
import 'package:meta/meta.dart';

import 'bcp47_extension.dart';
import 'bcp47_formatter.dart';
import 'bcp47_language_tag.dart';
import 'bcp47_language_tag_mixin.dart';
import 'bcp47_parser.dart';
import 'bcp47_private_use_tag.dart';
import 'bcp47_typedefs.dart';
import 'bcp47_validator.dart';

enum Bcp47LangTagSubtag {
  language,
  extlang,
  script,
  region,
  variant,
  extension,
  privateUse,
}

@immutable
class Bcp47LangTag extends Bcp47LanguageTagMixin implements Bcp47LanguageTag {
  final Bcp47Subtag language;
  final Bcp47Subtags extlangs;
  final Bcp47Subtag? script;
  final Bcp47Subtag? region;
  final Bcp47Subtags variants;
  final Iterable<Bcp47Extension> extensions;
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

  Bcp47LangTag replace(Map<Bcp47LangTagSubtag, dynamic> values) {
    return Bcp47LangTag(
      language: values.containsKey(Bcp47LangTagSubtag.language)
          ? values[Bcp47LangTagSubtag.language]
          : language,
      extlangs: values.containsKey(Bcp47LangTagSubtag.extlang)
          ? values[Bcp47LangTagSubtag.extlang]
          : extlangs,
      script: values.containsKey(Bcp47LangTagSubtag.script)
          ? values[Bcp47LangTagSubtag.script]
          : script,
      region: values.containsKey(Bcp47LangTagSubtag.region)
          ? values[Bcp47LangTagSubtag.region]
          : region,
      variants: values.containsKey(Bcp47LangTagSubtag.variant)
          ? values[Bcp47LangTagSubtag.variant]
          : variants,
      extensions: values.containsKey(Bcp47LangTagSubtag.extension)
          ? values[Bcp47LangTagSubtag.extension]
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
