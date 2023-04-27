import 'package:meta/meta.dart';

import 'bcp47_language_tag.dart';
import 'bcp47_language_tag_mixin.dart';
import 'bcp47_typedefs.dart';
import 'bcp47_validator.dart';

typedef Bcp47Singleton = Bcp47Subtag;

/// BCP-47 Singleton Tag
///
/// A Singleton Tag is a RFC-3066 Language-Tag with a Primary-subtag of length 1.

@immutable
class Bcp47SingletonTag with Bcp47LanguageTagMixin implements Bcp47LanguageTag {
  final Bcp47Singleton singleton;

  @override
  final Bcp47Subtags otherSubtags;

  Bcp47SingletonTag(
    Pattern singletonPattern,
    int otherSubtagMinLength, {
    required this.singleton,
    required this.otherSubtags,
  }) {
    Bcp47Validator.validateSingletonTagSubtagsFormat(
      singletonPattern,
      otherSubtagMinLength,
      singleton: singleton,
      otherSubtags: otherSubtags,
    );
  }

  @override
  Bcp47Subtag get primarySubtag => singleton;
}
