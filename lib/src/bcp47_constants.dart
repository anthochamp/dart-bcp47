// SPDX-FileCopyrightText: © 2023 - 2024 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

/// The standard BCP-47 subtag separator character (`-`).
///
/// Use [kBcp47SeparatorPattern] when a [Pattern] is required (e.g. for
/// [RegExp]-based splitting).
const kBcp47Separator = '-';

/// Pattern matching the standard BCP-47 subtag separator (`-`).
///
/// Pass this as the `separatorPattern` argument wherever an alternative
/// separator (e.g. `_` for CLDR data) might be needed.
const Pattern kBcp47SeparatorPattern = '-';
