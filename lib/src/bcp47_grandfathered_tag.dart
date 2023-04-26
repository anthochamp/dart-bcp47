import 'package:anthochamp_dart_essentials/dart_essentials.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'bcp47_language_tag.dart';
import 'bcp47_language_tag_mixin.dart';
import 'bcp47_parser.dart';
import 'bcp47_typedefs.dart';

/// BCP-47 Grandfathered tag (from RFC 5646)

@immutable
class Bcp47GrandfatheredTag extends Bcp47LanguageTagMixin
    implements Bcp47LanguageTag {
  static final kIrregularTags = [
    'en GB oed',
    'i ami',
    'i bnn',
    'i default',
    'i enochian',
    'i hak',
    'i klingon',
    'i lux',
    'i mingo',
    'i navajo',
    'i pwn',
    'i tao',
    'i tay',
    'i tsu',
    'sgn BE FR',
    'sgn BE NL',
    'sgn CH DE',
  ].map((e) => e.split(' '));
  static final kRegularTags = [
    'art lojban',
    'cel gaulish',
    'no bok',
    'no nyn',
    'zh guoyu',
    'zh hakka',
    'zh min',
    'zh min nan',
    'zh xiang',
  ].map((e) => e.split(' '));

  @override
  final Bcp47Subtags subtags;

  /// Is the grandfathered tag irregular?
  late final bool irregular;

  Bcp47GrandfatheredTag({
    required this.subtags,
  }) {
    final regularTag = kRegularTags.firstWhereOrNull(
      (element) => element.equalsI(subtags.toList()),
    );

    if (regularTag == null) {
      final irregularTag = kIrregularTags.firstWhereOrNull(
        (element) => element.equalsI(subtags.toList()),
      );

      if (irregularTag == null) {
        throw ArgumentError.value(subtags);
      }

      irregular = true;
    } else {
      irregular = false;
    }
  }

  factory Bcp47GrandfatheredTag.parse(
    String string, {
    Pattern? separatorPattern,
  }) {
    final pointer = StringPointer(string);

    final instance = Bcp47Parser.parseGrandfatheredTag(
      pointer,
      separatorPattern: separatorPattern,
    );

    if (pointer.value.isNotEmpty) {
      throw ArgumentError.value(string);
    }

    return instance!;
  }

  @override
  Bcp47Subtag get primarySubtag => subtags.first;

  @override
  Bcp47Subtags get otherSubtags => subtags.skip(1);
}
