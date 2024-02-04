// SPDX-FileCopyrightText: © 2023 - 2024 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

import 'bcp47_language_tag.dart';

// https://www.rfc-editor.org/rfc/rfc4647

abstract class Bcp47LanguageRange {
  bool match(Bcp47LanguageTag languageTag);

  String format({String? separator});
}
