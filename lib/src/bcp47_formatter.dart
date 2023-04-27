// Copyright 2023, Anthony Champagne. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:ac_dart_essentials/ac_dart_essentials.dart';

import 'bcp47_constants.dart';
import 'bcp47_extension.dart';
import 'bcp47_private_use_tag.dart';
import 'bcp47_typedefs.dart';

// normalization rules from :
// https://www.rfc-editor.org/rfc/rfc5646.html#section-2.1.1
class Bcp47Formatter {
  // this is the default language tag formatter, it shouldn't
  // be used if there's a specific formatter (ie. LangTag)
  static String formatLanguageTagSubtags({
    required Bcp47Subtags subtags,
    bool? caseNormalized,
    String? separator,
  }) {
    return (caseNormalized == true
            ? subtags.map((e) => e.toLowerCase())
            : subtags)
        .join(separator ?? kBcp47Separator);
  }

  static String formatLangTagSubtags({
    Bcp47Subtag? language,
    Bcp47Subtags? extlangs,
    Bcp47Subtag? script,
    Bcp47Subtag? region,
    Bcp47Subtags? variants,
    Iterable<Bcp47Extension>? extensions,
    Bcp47PrivateUseTag? privateUse,
    bool? caseNormalized,
    String? separator,
  }) {
    // formatting rules from https://www.rfc-editor.org/rfc/rfc5646.html#section-2.1.1
    return [
      if (language != null)
        caseNormalized == true ? language.toLowerCase() : language,
      ...?(caseNormalized == true
          ? extlangs?.map((e) => e.toLowerCase())
          : extlangs),
      if (script != null)
        caseNormalized == true ? script.toTitleCase() : script,
      if (region != null)
        caseNormalized == true ? region.toUpperCase() : region,
      ...?(caseNormalized == true
          ? variants?.map((e) => e.toLowerCase())
          : variants),
      ...?extensions?.map((e) =>
          e.format(caseNormalized: caseNormalized, separator: separator)),
      if (privateUse != null)
        privateUse.format(caseNormalized: caseNormalized, separator: separator),
    ].join(separator ?? kBcp47Separator);
  }
}
