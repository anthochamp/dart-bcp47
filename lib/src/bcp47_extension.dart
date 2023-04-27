// Copyright 2023, Anthony Champagne. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:ac_dart_essentials/ac_dart_essentials.dart';
import 'package:meta/meta.dart';

import 'bcp47_parser.dart';
import 'bcp47_singleton_tag.dart';

/// BCP-47 Extension (from RFC 5646)
///
/// An extension is a Singleton tag (a RFC 3066 Language-Tag with a
/// Primary-subtag of length 1) with a singleton that is *NOT* 'x'.

@immutable
class Bcp47Extension extends Bcp47SingletonTag {
  Bcp47Extension({
    required super.singleton,
    required super.otherSubtags,
  }) : super(
          Bcp47Parser.kExtensionSingletonPattern,
          Bcp47Parser.kExtensionSubtagMinLength,
        );

  factory Bcp47Extension.parse(
    String string, {
    Pattern? separatorPattern,
  }) {
    final pointer = StringPointer(string);

    final instance = Bcp47Parser.parseExtension(
      pointer,
      singletonCharPattern: Bcp47Parser.kExtensionSingletonPattern,
      separatorPattern: separatorPattern,
    );

    if (pointer.value.isNotEmpty) {
      throw ArgumentError.value(string);
    }

    return instance!;
  }

  Bcp47Extension get canonicalized => this;
}
