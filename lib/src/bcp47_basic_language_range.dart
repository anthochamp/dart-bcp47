import 'package:anthochamp_dart_essentials/dart_essentials.dart';
import 'package:meta/meta.dart';

import 'bcp47_constants.dart';
import 'bcp47_language_range.dart';
import 'bcp47_language_tag.dart';
import 'bcp47_language_tag_mixin.dart';
import 'bcp47_parser.dart';
import 'bcp47_typedefs.dart';
import 'bcp47_validator.dart';

/// A Basic Language Range as described in https://www.rfc-editor.org/rfc/rfc4647#section-2.1
@immutable
class Bcp47BasicLanguageRange
    with Bcp47LanguageTagMixin
    implements Bcp47LanguageRange, Bcp47LanguageTag {
  @override
  final Bcp47Subtags subtags;

  Bcp47BasicLanguageRange({
    this.subtags = const ['*'],
  }) {
    Bcp47Validator.validateBasicLanguageRangeSubtagsFormat(subtags: subtags);
  }

  factory Bcp47BasicLanguageRange.parse(
    String string, {
    Pattern? separatorPattern,
  }) {
    final pointer = StringPointer(string);

    final instance = Bcp47Parser.parseBasicLanguageRange(
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

  /// Basic Filtering as described in https://www.rfc-editor.org/rfc/rfc4647#section-3.3.1
  @override
  bool match(Bcp47LanguageTag languageTag) {
    if (subtags.length == 1 && subtags.first == '*') {
      return true;
    }

    final formatted = format(caseNormalized: true, separator: kBcp47Separator);
    final formattedLanguageTag =
        languageTag.format(caseNormalized: true, separator: kBcp47Separator);

    return formattedLanguageTag
        .startsWith(RegExp(RegExp.escape(formatted), caseSensitive: false));
  }
}
