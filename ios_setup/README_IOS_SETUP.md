# iOS project setup

This folder is **not** a live `ios/` directory — it can't be, since building
the real Xcode project (`Runner.xcworkspace`, `project.pbxproj`, storyboards,
`Podfile`, etc.) requires the Flutter SDK and CocoaPods running on macOS,
neither of which this environment has. Handwriting an Xcode project file
byte-for-byte is also exactly the kind of thing that silently corrupts and
won't open — so instead, this folder gives you the one file worth
customizing by hand, plus the exact commands to generate everything else
correctly.

## 1. Generate the native project

From the root of this project (where `pubspec.yaml` lives), with the
Flutter SDK installed:

```bash
flutter create --platforms=ios --org com.yourname .
```

This scaffolds `ios/Runner.xcodeproj`, `ios/Runner.xcworkspace`,
`ios/Podfile`, storyboards, and `ios/Runner/Info.plist` — all wired up to
your `pubspec.yaml` and `lib/` code, which are untouched by this command.

To rename the bundle identifier later, change it in Xcode
(Runner target → Signing & Capabilities → Bundle Identifier), or re-run
`flutter create` with a different `--org`.

## 2. Merge in `Info.plist`

Replace the generated `ios/Runner/Info.plist` with the one in this folder
(`ios_setup/Info.plist`), which adds:

- `CFBundleDisplayName` = "Workday Noir"
- `UIUserInterfaceStyle` = Dark (matches the Noir design)
- Portrait-first orientation (landscape enabled on iPad)
- No unnecessary permission keys — no location, contacts, microphone,
  camera, or photo library usage descriptions, since the app never asks
  for them

## 3. Install dependencies and build

```bash
flutter pub get
flutter analyze
flutter test
cd ios && pod install && cd ..
flutter build ios
```

Then open `ios/Runner.xcworkspace` (not `.xcodeproj`) in Xcode, select your
Apple Developer team under Signing & Capabilities, and run on a device or
simulator.

## 4. App icon

Replace `ios/Runner/Assets.xcassets/AppIcon.appiconset` with your final
icon set. A placeholder 1024×1024 concept is included at
`assets/icon/icon_1024.png` — see `assets/icon/README.md`. The
[App Icon Generator](https://appicon.co) or Xcode's own asset catalog
editor can expand a single 1024×1024 PNG into the full required size set.
