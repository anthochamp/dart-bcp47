// ignore_for_file: avoid_equals_and_hash_code_on_mutable_classes

import 'package:anthochamp_dart_essentials/dart_essentials.dart';

import 'bcp47_formatter.dart';
import 'bcp47_language_tag.dart';
import 'bcp47_typedefs.dart';

abstract class Bcp47LanguageTagMixin implements Bcp47LanguageTag {
  @override
  Bcp47Subtags get subtags => [primarySubtag, ...otherSubtags];

  @override
  int get hashCode => Object.hashAll(subtags.map((e) => e.toLowerCase()));

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (runtimeType == other.runtimeType &&
            subtags.toList().equalsI(other.subtags));
  }

  @override
  String format({
    bool? caseNormalized,
    String? separator,
  }) =>
      Bcp47Formatter.formatLanguageTagSubtags(
        subtags: subtags,
        caseNormalized: caseNormalized,
        separator: separator,
      );

  @override
  String toString() => format();
}
