# Money Converter: notes for Claude

- Work on a branch and open a pull request; the owner validates and asks to merge.
- The app ships in 8 languages (en, fr, de, es, it, pl, ro, lt). Every user-facing text goes
  through `lib/l10n/app_strings.dart` with all 8 translations; English is the fallback.
- **Store listing is part of every user-facing change.** Before opening the PR:
  - write the release notes in `fastlane/metadata/android/<locale>/changelogs/default.txt`
    for the 8 languages (what changed for the user, 500 characters max);
  - update `full_description.txt` (and `short_description.txt` if needed) when a feature
    is added, changed or removed;
  - screenshots are regenerated automatically by `screenshots/screenshots_test.dart` on
    every publication: update that test when a screen changes;
  - run `python3 tool/check_store_metadata.py`.
- The README exists in the 8 languages (`README.md` in English, `README.<lang>.md` for the
  others), with a language bar at the top: change them all together.
- Play locales: en-US, fr-FR, de-DE, es-ES, it-IT, pl-PL, ro, lt.
