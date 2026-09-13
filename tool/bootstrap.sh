#!/usr/bin/env bash
set -euo pipefail
flutter create --platforms=ios,android .
flutter pub get
flutter analyze
flutter test
printf '\nWorkday Noir Flutter project initialized. Open ios/Runner.xcworkspace in Xcode.\n'
