import 'package:anthochamp_dart_essentials/dart_essentials.dart';
import 'package:meta/meta.dart';

import 'bcp47_parser.dart';
import 'bcp47_singleton_tag.dart';

/// BCP-47 Private-Use tag (from RFC 5646)
///
/// A Private-Use tag is a RFC 3066 Language-Tag with a Primary-subtag
/// equals to 'x'.

@immutable
class Bcp47PrivateUseTag extends Bcp47SingletonTag {
  static const Bcp47Singleton kSingleton = 'x';

  Bcp47PrivateUseTag({
    /// singleton must be either 'x' or 'X'
    super.singleton = kSingleton,
    required super.otherSubtags,
  }) : super(
          Bcp47Parser.kPrivateUseSingletonPattern,
          Bcp47Parser.kPrivateUseSubtagMinLength,
        );

  factory Bcp47PrivateUseTag.parse(
    String string, {
    Pattern? separatorPattern,
  }) {
    final pointer = StringPointer(string);

    final instance = Bcp47Parser.parsePrivateUseTag(
      pointer,
      separatorPattern: separatorPattern,
    );

    if (pointer.value.isNotEmpty) {
      throw ArgumentError.value(string);
    }

    return instance!;
  }
}
