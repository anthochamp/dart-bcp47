// SPDX-FileCopyrightText: © 2023 - 2026 Anthony Champagne <dev@anthonychampagne.fr>
//
// SPDX-License-Identifier: BSD-3-Clause

/// A single BCP-47 subtag value, e.g. `'en'`, `'Latn'`, `'US'`.
typedef Bcp47Subtag = String;

/// An ordered list of [Bcp47Subtag] values.
typedef Bcp47Subtags = List<Bcp47Subtag>;
