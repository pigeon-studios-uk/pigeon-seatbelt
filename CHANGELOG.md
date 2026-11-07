# Changelog

All notable changes to Pigeon Seatbelt are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project uses [Semantic Versioning](https://semver.org/spec/v2.0.0.html):

- **Major** versions can need changes to your configuration or other resources. Read the **Upgrade notes**.
- **Minor** versions add features without breaking existing setups.
- **Patch** versions fix bugs only.

## [Unreleased]

### Added

- 22 more languages, so it now comes in 23: Czech, Danish, German, Spanish, Estonian, Finnish, French, Croatian, Hungarian, Indonesian, Italian, Dutch, Norwegian, Polish, Portuguese, Brazilian Portuguese, Romanian, Slovenian, Swedish, Turkish, and Simplified and Traditional Chinese.
- `Config.Locale = 'auto'`, the new default: it follows ox_lib's language (`setr ox:locale "de"` in `server.cfg`) and is English when that isn't set. A config that already says `'en'` stays in English.

## [1.0.0] - 2026-11-03

First release.

### Highlights

- Buckle up with one key, with a click
- Unbuckled players go through the windscreen in a hard crash
- A warning light and a chime while unbuckled
- A jolt, a blurred screen and a dazed walk after a hard crash
- A state bag and exports for HUDs and police checks

### Added

- Buckling and unbuckling with one key (B by default, which players can change in GTA's key bindings) or `/seatbelt`, with a click only the player hears.
- Unbuckled players thrown through the windscreen in a hard crash, by GTA's own crash physics, from a speed you set; buckled players stay in.
- What happens when a buckled player tries to get out: unbuckle first, blocked, or allowed.
- A seatbelt warning light on screen while unbuckled, from a speed you set, in any corner.
- A chime while unbuckled at speed, at a volume you set.
- After a hard crash, buckled or not: a camera jolt, a blurred screen and a dazed walk, stronger and longer the harder the crash.
- Vehicle classes and vehicles with no seatbelts, such as motorcycles and boats, where nothing happens.
- The replicated `seatbelt` state bag, the `pigeon-seatbelt:changed` client event, `IsBuckled` and `SetBuckled` client exports and an `IsBuckled` server export.
- Every message in `locales/`.
- Update checker from the Pigeon Studios version registry.

[Unreleased]: https://github.com/pigeon-studios-uk/pigeon-seatbelt/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/pigeon-studios-uk/pigeon-seatbelt/releases/tag/v1.0.0
