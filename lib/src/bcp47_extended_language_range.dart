import 'package:anthochamp_dart_essentials/dart_essentials.dart';

import 'bcp47_constants.dart';
import 'bcp47_language_range.dart';
import 'bcp47_language_tag.dart';
import 'bcp47_parser.dart';
import 'bcp47_basic_language_range.dart';
import 'bcp47_validator.dart';
import 'package:meta/meta.dart';

// https://www.rfc-editor.org/rfc/rfc4647#section-2.2

@immutable
class Bcp47ExtendedLanguageRange implements Bcp47LanguageRange {
  final Iterable<String> values;

  Bcp47ExtendedLanguageRange({
    required this.values,
  }) {
    Bcp47Validator.validateExtendedLanguageRangeValuesFormat(values: values);
  }

  factory Bcp47ExtendedLanguageRange.parse(
    String string, {
    Pattern? separatorPattern,
  }) {
    return Bcp47ExtendedLanguageRange(
      values: string.split(RegExp((separatorPattern ?? kBcp47Separator).toString(), caseSensitive: false)),
    );
  }

  @override
  bool match(Bcp47LanguageTag languageTag) {
    // https://www.rfc-editor.org/rfc/rfc4647#section-3.3.2

    final subtags = languageTag.subtags;

    // 2. Begin with the first subtag in each list. If the first subtag in
    // the range does not match the first subtag in the tag, the overall
    // match fails.  Otherwise, move to the next subtag in both the
    // range and the tag.
    if (values.first.compareToI(subtags.first) != 0) {
      return false;
    }

    int i = 1, j = 1;
    while (i < values.length) {
      final value = values.elementAt(i);

      // A. If the subtag currently being examined in the range is the
      // wildcard ('*'), move to the next subtag in the range and
      // continue with the loop.
      if (value == '*') {
        i++;
        continue;
      }

      // B. Else, if there are no more subtags in the language tag's list,
      // the match fails.
      if (j >= subtags.length) {
        return false;
      }

      final subtag = subtags.elementAt(j);

      // C. Else, if the current subtag in the range's list matches the
      // current subtag in the language tag's list, move to the next
      // subtag in both lists and continue with the loop.
      if (value.compareToI(subtag) == 0) {
        i++;
        j++;
        continue;
      }

      // D. Else, if the language tag's subtag is a "singleton" (a single
      // letter or digit, which includes the private-use subtag 'x')
      // the match fails.
      if (Bcp47Parser.kSingletonPattern.entireMatchI(subtag)) {
        return false;
      }

      // E. Else, move to the next subtag in the language tag's list and
      // continue with the loop.
      j++;
    }

    // 4. When the language range's list has no more subtags, the match
    // succeeds.
    return true;
  }

  @override
  String format({String? separator}) =>
      values.join(separator ?? kBcp47Separator);

  // https://www.rfc-editor.org/rfc/rfc4647#section-3.2
  Bcp47BasicLanguageRange toBasicLanguageRange() {
    if (values.first == '*') {
      return Bcp47BasicLanguageRange();
    }

    return Bcp47BasicLanguageRange(
      subtags: values.toList()..removeWhere((e) => e == '*'),
    );
  }

  @override
  String toString() => format();
}
