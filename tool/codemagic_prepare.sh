#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK is not available on PATH."
  exit 1
fi

# The repository intentionally keeps the Dart layer portable. Codemagic has
# the Flutter SDK installed, so generate the native Flutter project there if
# platform scaffolding is not committed yet.
if [[ ! -f ios/Runner.xcodeproj/project.pbxproj || ! -f android/app/build.gradle ]]; then
  flutter create \
    --platforms=ios,android \
    --org com.workdaynoir \
    --project-name workday_noir \
    .
fi

# Keep the generated iOS display name aligned with the product name.
if [[ -f ios/Runner/Info.plist ]] && command -v /usr/libexec/PlistBuddy >/dev/null 2>&1; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName Workday Noir" ios/Runner/Info.plist || true
fi

# Make sure CocoaPods is ready for Flutter plugins.
if [[ -f ios/Podfile ]]; then
  pod --version
fi

echo "Flutter platform scaffolding is ready."
