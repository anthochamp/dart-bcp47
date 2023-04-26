// Based on tools/gen_locale.dart from Flutter Engine (modified)
// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: avoid_print, avoid-substring

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:anthochamp_dart_essentials/dart_essentials.dart';

const String registry =
    'https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry';

Map<String, List<String>> parseSection(String section) {
  final Map<String, List<String>> result = <String, List<String>>{};
  late List<String> lastHeading;

  for (final String line in section.split('\n')) {
    if (line.isEmpty) {
      continue;
    }

    if (line.startsWith('  ')) {
      lastHeading.last = '${lastHeading.last}${line.substring(1)}';
      continue;
    }

    final int colon = line.indexOf(':');
    if (colon == -1) {
      throw StateError('not sure how to deal with "$line"');
    }

    final String name = line.substring(0, colon);
    final String value = line.substring(colon + 2);

    lastHeading = result.putIfAbsent(name, () => <String>[])..add(value);
  }

  return result;
}

String formatDate(DateTime dateTime) {
  return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
}

Future<void> main() async {
  final HttpClient client = HttpClient();

  final String body =
      (await (await (await client.getUrl(Uri.parse(registry))).close())
              .transform(utf8.decoder)
              .toList())
          .join();

  final List<Map<String, List<String>>> sections =
      body.split('%%').map<Map<String, List<String>>>(parseSection).toList();

  final Map<String, List<String>> prefixLines = <String, List<String>>{};
  final Map<String, List<String>> suppressScriptLines =
      <String, List<String>>{};
  final Map<String, List<String>> preferredValuesLines =
      <String, List<String>>{};

  DateTime? fileDate;
  DateTime? maxAdded;
  for (final Map<String, List<String>> section in sections) {
    if (fileDate == null) {
      // first block should contain a File-Date metadata line.
      fileDate = DateTime.parse(section['File-Date']!.single);
      continue;
    }

    final type = section['Type']!.single;
    final descriptions = section['Description'] ?? [];
    final tag = section['Tag']?.single;
    final subtag = section['Subtag']?.single;
    final added = DateTime.parse(section['Added']!.single);

    final preferredValue = section['Preferred-Value']?.single;
    final suppressScript = section['Suppress-Script']?.single;

    final prefixes = section['Prefix'] ?? [];
    final comment = section['Comment']?.single;
    final deprecatedStr = section['Deprecated']?.single;
    final deprecated =
        deprecatedStr == null ? null : DateTime.parse(deprecatedStr);

    String entryComment =
        '${descriptions.join(", ")} (added ${formatDate(added)}${deprecated == null ? '' : ', deprecated ${formatDate(deprecated)}'})${comment == null ? '' : ' / NB. $comment'}';

    if (prefixes.isNotEmpty) {
      prefixLines[type] = prefixLines[type] ?? [];
      prefixLines[type]!.add('// $entryComment');

      for (final prefix in prefixes) {
        prefixLines[type]!.add(
          "[Bcp47LangTagSubtag.$type, '$subtag', Bcp47ExtendedLanguageRange.parse('$prefix')],",
        );
      }
    }

    if (suppressScript != null) {
      suppressScriptLines[type] = suppressScriptLines[type] ?? [];
      suppressScriptLines[type]!.add('// $entryComment');

      if (type == 'language') {
        suppressScriptLines[type]!.add(
          "['$subtag', '$suppressScript'],",
        );
      } else {
        // should only apply to extlang
        if (prefixes.isNotEmpty) {
          for (final prefix in prefixes) {
            suppressScriptLines[type]!.add(
              "[Bcp47ExtendedLanguageRange.parse('$prefix'), '$subtag', '$suppressScript'],",
            );
          }
        } else {
          suppressScriptLines[type]!.add(
            "[null, '$subtag', '$suppressScript'],",
          );
        }
      }

      maxAdded =
          maxAdded == null || added.compareTo(maxAdded) > 0 ? added : maxAdded;
    }

    if (preferredValue != null) {
      preferredValuesLines[type] = preferredValuesLines[type] ?? [];
      preferredValuesLines[type]!.add('// $entryComment');

      if (type == 'language' || type == 'script' || type == 'region') {
        preferredValuesLines[type]!.add(
          "['$subtag', '$preferredValue'],",
        );
      } else if (type == 'variant') {
        if (prefixes.isNotEmpty) {
          for (final prefix in prefixes) {
            preferredValuesLines[type]!.add(
              "[Bcp47ExtendedLanguageRange.parse('$prefix'), '$subtag', '$preferredValue'],",
            );
          }
        } else {
          preferredValuesLines[type]!.add(
            "[null, '$subtag', '$preferredValue'],",
          );
        }
      } else if (type == 'extlang') {
        // https://www.rfc-editor.org/rfc/rfc5646.html#section-4.5
        // The field-body of the 'Preferred-Value' for extlangs is an
        // "extended language range"

        for (final prefix in prefixes) {
          preferredValuesLines[type]!.add(
            "[Bcp47ExtendedLanguageRange.parse('$prefix-$subtag'), '$subtag', '$preferredValue'],",
          );
        }

        if (prefixes.isEmpty) {
          preferredValuesLines[type]!.add(
            "[Bcp47ExtendedLanguageRange.parse('$subtag'), '$subtag', '$preferredValue'],",
          );
        }
      } else {
        // https://www.rfc-editor.org/rfc/rfc5646.html#section-4.5
        // The field-body of the 'Preferred-Value' for grandfathered and
        // redundant tags is an "extended language range" [RFC4647] and
        // might consist of more than one subtag.
        preferredValuesLines[type]!.add(
          "[Bcp47ExtendedLanguageRange.parse('$tag'), '$preferredValue'],",
        );
      }

      maxAdded =
          maxAdded == null || added.compareTo(maxAdded) > 0 ? added : maxAdded;
    }
  }

  print(
    '// Generated from $registry.',
  );
  print(
    '// Generation date: ${formatDate(DateTime.now())}',
  );
  print(
    '// Registry date: ${formatDate(fileDate!)}',
  );
  print(
    '// Latest record of interest added date: ${formatDate(maxAdded!)}.',
  );

  print('\n// Subtags Prefix');
  print('final kBcp47IanaPrefix = [');
  for (final entry in prefixLines.entries) {
    if (prefixLines.entries.first.key != entry.key) {
      print('');
    }
    print('  // Prefix (type ${entry.key.toTitleCase()})');
    print('\n  ${entry.value.join('\n  ')}');
  }
  print('];');

  for (final entry in preferredValuesLines.entries) {
    print('\n// Preferred ${entry.key.toTitleCase()} values');
    print('final kBcp47Iana${entry.key.toTitleCase()}PreferredValue = [');
    print('  ${entry.value.join('\n  ')}');
    print('];');
  }

  for (final entry in suppressScriptLines.entries) {
    print('\n// Suppress-Script (type ${entry.key.toTitleCase()})');
    print('final kBcp47Iana${entry.key.toTitleCase()}SuppressScript = [');
    print('  ${entry.value.join('\n  ')}');
    print('];');
  }
}
