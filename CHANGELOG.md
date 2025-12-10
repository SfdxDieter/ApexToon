# Changelog

All notable changes to ApexToon will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.2.0] - 2025-11-27

### Added

- `ToonTypeHelper.isTabularArray()` method to detect if a value qualifies for tabular array encoding (non-empty list of uniform maps with primitive-only values)
- `ToonValueDecoder.parseListItemTabularField()` for parsing v3.0 nested tabular arrays in list items
- `ToonValueDecoder.parseListItemFieldsAtDepthPlusOne()` for parsing sibling fields after tabular arrays
- `ToonValueDecoder.findUnquotedDelimiter()` helper method for delimiter detection
- New encoding tests for v3.0 list-item tabular format
- New decoding tests for v3.0 list-item tabular format
- New round-trip tests for v3.0 patterns
- Unit tests for `ToonTypeHelper.isTabularArray()`

### Changed

- **BREAKING**: Updated to TOON Specification v3.0 (2025-11-24)
- `ToonArrayEncoder.encodeListItemObject()` now emits v3.0 canonical form when first field is a tabular array:
  - Tabular header on hyphen line: `- key[N]{fields}:`
  - Tabular rows at depth +2 relative to hyphen line
  - Other fields at depth +1 relative to hyphen line
- Empty list-item objects now output bare `-` instead of `- {}`
- `ToonValueDecoder.parseListItem()` updated to detect and handle v3.0 keyed tabular arrays
- Updated `COMPLIANCE.md` to reference v3.0 specification

### Removed

- **BREAKING**: Removed `lengthMarker` option from `EncodeOptions` (was `[#N]` syntax, removed in TOON spec v2.0)
- Removed `LENGTH_MARKER` constant from `ToonConstants`
- Removed length marker parameter from `ToonHeaderFormatter.format()` method

### Fixed

- List-item objects with tabular array as first field now encode/decode correctly per v3.0 spec

## [0.1.0] - 2025-11-19

### Added

- Initial release with full TOON v2.0 compliance
- Core encoding/decoding functionality via `ApexToon.encode()` and `ApexToon.decode()`
- Canonical number formatting (no exponent notation, no trailing zeros)
- Proper header delimiter handling (comma default, tab, pipe)
- Complete string escaping and quoting rules
- Support for inline arrays, tabular arrays, and list-item arrays
- SObject encoding support with `__type` metadata field
- Configurable encoding options (`EncodeOptions`)
- Configurable decoding options (`DecodeOptions`)
- Comprehensive test coverage (95 unit tests)

## [0.2.0]

### sfdx changes
- moved directories for sfdx structure
- created managed package without password
- only needed classes for interaction got global access
- fixing problems and adapting to new TOON 3.0 specification
- added new features for tabular arrays in list items
- updated README and CHANGELOG
- fixing unit tests
- code analyze and formatting
- Added @param and @return annotations