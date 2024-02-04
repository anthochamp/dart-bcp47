// SPDX-FileCopyrightText: © 2023 - 2024 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'bcp47_grandfathered_tag.dart';
import 'bcp47_lang_tag.dart';
import 'bcp47_private_use_tag.dart';
import 'bcp47_typedefs.dart';

/// BCP-47 Language Tag
/// https://www.rfc-editor.org/rfc/bcp/bcp47.txt
abstract class Bcp47LanguageTag {
  factory Bcp47LanguageTag.parse(
    String string, {
    Pattern? separatorPattern,
  }) {
    try {
      return Bcp47GrandfatheredTag.parse(
        string,
        separatorPattern: separatorPattern,
      );
    } catch (_) {}

    try {
      return Bcp47PrivateUseTag.parse(
        string,
        separatorPattern: separatorPattern,
      );
    } catch (_) {}

    return Bcp47LangTag.parse(
      string,
      separatorPattern: separatorPattern,
    );
  }

  Bcp47Subtag get primarySubtag;
  Bcp47Subtags get otherSubtags;

  Bcp47Subtags get subtags;

  String format({bool? caseNormalized, String? separator});
}
