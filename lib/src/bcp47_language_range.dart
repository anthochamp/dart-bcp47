import 'bcp47_language_tag.dart';

// https://www.rfc-editor.org/rfc/rfc4647

abstract class Bcp47LanguageRange {
  bool match(Bcp47LanguageTag languageTag);

  String format({String? separator});
}
