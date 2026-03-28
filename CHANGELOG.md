# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Fixed

- Fix `==` and `hashCode` in `Bcp47LanguageTagMixin` to use structural, case-insensitive comparison (was identity-based, causing map/set lookups to fail).
- Fix `Bcp47BasicLanguageRange.parse` to accept single-subtag ranges (e.g. `'en'`, `'de'`).

### Changed

- Update IANA registry data (registry date 2025-08-25, latest record 2024-12-12).

### Added

- Add `Bcp47Lookup` with `basicFilter`, `extendedFilter`, and `lookup` (RFC 4647 §3.3 and §3.4).
- Add `Bcp47LangTag.copyWith` for type-safe field replacement.
- Add `///` doc comments to all public API members.

## [0.2.3]

- Upgrade ac_lints package to 0.4.0

## [0.2.2]

- Upgrade ac_lints package to 0.3.0

## [0.2.1]

- Update LICENSE's copyright to include contributors
- Widen SDK environment requirement to include Dart 3 versions
- Upgrade ac_essentials package to 0.2.1
- Upgrade ac_lints package to 0.2.0

## [0.2.0]

- Minor changes

## [0.1.0]

- Initial release
