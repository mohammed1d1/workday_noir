# Workday Noir

Premium offline-first Flutter iOS workday tracker.

## Codemagic

This repository is prepared for Codemagic YAML builds. The Dart/Flutter source is portable, and the native Flutter iOS/Android platform scaffolding can be generated automatically on the Codemagic macOS builder.

### CI / unsigned iOS build

Codemagic detects the root `codemagic.yaml` and can run the `ios_unsigned` workflow. It:

1. Generates `ios/` and `android/` with `flutter create` when the native platform files are not present.
2. Runs `flutter pub get`.
3. Runs `flutter analyze`.
4. Runs `flutter test`.
5. Installs CocoaPods dependencies.
6. Runs `flutter build ios --release --no-codesign`.
7. Uploads the resulting Runner.app and Xcode logs as artifacts.

### Signed iOS / App Store workflow

The `ios_release` workflow is configured for an App Store distribution build with bundle identifier:

```text
com.workdaynoir.app
```

Before using that workflow, create the matching App ID in Apple Developer/App Store Connect and configure an App Store Connect API integration in Codemagic. The workflow then uses Codemagic's iOS signing configuration and `xcode-project use-profiles` before building the IPA.

In `codemagic.yaml`, the signed workflow references the Codemagic App Store Connect integration by the placeholder name:

```text
workday_noir_app_store_connect
```

Create an App Store Connect integration in Codemagic and either name it exactly that, or replace the value under `integrations.app_store_connect` with your existing integration name.

### Important

The current source package intentionally does **not** contain generated Xcode project files. That is why the Codemagic preparation script runs `flutter create --platforms=ios,android .` before the build. This prevents the previous `Application not configured for iOS` failure on CI.

For a normal developer machine:

```bash
flutter pub get
flutter create --platforms=ios,android --org com.workdaynoir --project-name workday_noir .
flutter analyze
flutter test
flutter build ios --release --no-codesign
open ios/Runner.xcworkspace
```

## Architecture

- Flutter + Dart
- Riverpod state management
- SQLite via sqflite
- Local YYYY-MM-DD date keys
- Cupertino-first UI
- Native file sharing through `share_plus`
- Optional local notifications

## Native iOS source

`ios/Widgets/` contains Swift/SwiftUI source for the planned WidgetKit/App Intents integration. It should be added to a dedicated iOS Widget Extension target and configured with an App Group in Xcode/Codemagic before those system extensions are enabled in a signed production build.
