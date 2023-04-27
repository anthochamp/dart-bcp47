// Copyright 2023, Anthony Champagne. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'bcp47_language_tag.dart';

// https://www.rfc-editor.org/rfc/rfc4647

abstract class Bcp47LanguageRange {
  bool match(Bcp47LanguageTag languageTag);

  String format({String? separator});
}
