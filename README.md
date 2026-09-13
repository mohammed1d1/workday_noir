# Workday Noir

A premium, offline-first work-day tracker for iOS, built with Flutter.
One question — **Did you work today?** — answered with a tap, saved
instantly, and organized into a simple monthly history.

---

## ⚠️ Before you build: read this

This project was written in a sandboxed Linux environment with **no
macOS/Xcode and no network access to Flutter's or pub.dev's
infrastructure**, so it could not be run through `flutter create`,
`flutter pub get`, `flutter analyze`, `flutter test`, or `flutter build
ios` during development. Every file below was written by hand to be
correct, idiomatic, current Flutter/Dart — but you should run the full
toolchain yourself before trusting it, starting with:

```bash
flutter create --platforms=ios --org com.yourname .
flutter pub get
flutter analyze
flutter test
```

See **[`ios_setup/README_IOS_SETUP.md`](ios_setup/README_IOS_SETUP.md)**
for exactly why the native `ios/` Xcode project isn't included here and
how to generate it in one command.

A couple of specific things worth double-checking once you can run
`flutter pub get`:

- **Package versions.** `pubspec.yaml` pins versions that were current
  and stable as of early-to-mid 2025 knowledge. Run `flutter pub outdated`
  after first fetching and bump anything that's since moved past a
  breaking change, especially `share_plus` and `flutter_local_notifications`
  (both evolve their APIs somewhat frequently).
- **`flutter_timezone` API.** `NotificationService` calls
  `FlutterTimezone.getLocalTimezone()`. If the installed version exposes a
  different method name, `flutter analyze` will catch it immediately —
  it's a one-line fix.

---

## What this app does

- **Home** — "Did you work today?" with YES/NO. Tapping either saves
  today's status immediately, with a light haptic and a small animation.
  Answering again the same day *updates* today's entry — it never creates
  a second one.
- **History** — entries grouped by month, newest month first, with a
  running "Total worked days" per month. Tap any day to flip its status.
- **Settings** — an optional daily local reminder notification, Export,
  and a couple of About rows. Notification permission is requested only
  the moment you turn the reminder on — never during onboarding or at
  launch.
- **Export** — turns your history into plain text and hands it to the
  native iOS Share Sheet.

Everything works fully offline. There's no account, no server, no
analytics, and no permissions requested beyond what a reminder itself
needs (and only if you enable one).

## Architecture

```
lib/
├── main.dart                     Entry point
├── app/
│   ├── app.dart                  Root widget; onboarding gate
│   ├── theme/noir_theme.dart     Colors, type, ThemeData
│   └── routing/app_shell.dart    Home/History/Settings tab shell
├── features/
│   ├── onboarding/                Three-screen first-launch intro
│   ├── home/                      "Did you work today?" screen
│   ├── history/                   Monthly history list
│   └── settings/                  Reminders, export, about
├── models/
│   └── work_entry.dart           Normalized-date work record
├── services/
│   ├── storage_service.dart      SQLite persistence (sqflite)
│   ├── preferences_service.dart  Onboarding flag + reminder settings
│   ├── notification_service.dart Local daily reminder
│   ├── export_service.dart       Plain-text export + Share Sheet
│   └── work_entries_controller.dart  ChangeNotifier app state
└── widgets/
    ├── work_status_button.dart   YES/NO button
    ├── work_entry_tile.dart      One history row
    └── month_section.dart        One month's header + rows + total
```

**Why no state-management package?** The app has one shared piece of
state (the list of work entries) and three screens. `WorkEntriesController`
is a plain `ChangeNotifier`, and screens rebuild via `AnimatedBuilder`.
Introducing `provider`, `riverpod`, or `bloc` for this would add a
dependency without adding real value — matching the "avoid unnecessary
dependencies" requirement this app was built against.

**Why SQLite instead of a simpler key-value store?** `date_key` (a
normalized `YYYY-MM-DD` string) is the primary key, so "one record per
calendar day" is enforced by the database itself via
`INSERT ... ON CONFLICT REPLACE`, not just by app-level logic. Every
save — whether it's today's first answer or the fifth time you've
flipped a past day between YES and NO — is the same upsert, and it's
impossible for it to produce a duplicate row.

## A note on date formatting

The spec's own examples aren't fully self-consistent about day/month
order (Section 10 reads as month/day, while the worked examples in
Sections 7 and 15 — the ones with an explicit "September 2026" header
above a run of consecutive dates — read as day/month). This build
standardizes on **day/month** (`8/9` = September 8th) everywhere, on-screen
and in exports, based on the two examples that include enough context to
disambiguate. If you'd prefer month/day, it's a one-line change in
`lib/widgets/work_entry_tile.dart` (`_compactDate`) and
`lib/services/export_service.dart` (`buildExportText`).

## Testing

```bash
flutter test
```

Covers: date normalization and key generation (`work_entry_test.dart`),
duplicate-prevention and update-in-place behavior against a real
in-memory SQLite database via `sqflite_common_ffi` (`storage_service_test.dart`),
and month/year grouping, totals, and today's-status logic in the
controller (`work_entries_controller_test.dart`), plus the export text
format.

## Changing the bundle identifier

Either pass `--org com.yourcompany` to `flutter create` the first time
you scaffold `ios/`, or change it later in Xcode under the Runner
target's Signing & Capabilities.

## Design

Deep near-black background, white primary text, muted gray secondary
text, thin hairline borders instead of shadows or cards-on-cards, and two
deliberately desaturated accent tones (muted green / muted red) used only
for small indicators — never as large fills. See
`lib/app/theme/noir_theme.dart` for the exact values.

## Future ideas (not built, architecture allows for them)

iCloud sync, a home screen widget, Apple Watch companion, Siri/Shortcuts
integration, work streaks, multiple work types, CSV/PDF export. None of
these are stubbed out with fake functionality — they're simply not
started, per the "no placeholder functionality pretending to work"
requirement.
