#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

command -v flutter >/dev/null 2>&1 || {
  echo "Flutter SDK is not available on PATH."
  exit 1
}

# Generate/update the native Flutter platform projects on the CI machine.
# This is intentionally invoked through `bash` from codemagic.yaml, so the
# executable bit is not required in the Git repository.
flutter create \
  --platforms=ios,android \
  --org com.workdaynoir \
  --project-name workday_noir \
  --ios-language swift \
  --android-language kotlin \
  .

# The signed workflow uses this explicit App ID. The generated Flutter
# template derives an ID from the package/project name, so normalize it.
if [[ -f ios/Runner.xcodeproj/project.pbxproj ]]; then
  python3 - <<'PY'
from pathlib import Path
p = Path('ios/Runner.xcodeproj/project.pbxproj')
s = p.read_text()
lines = []
for line in s.splitlines(True):
    if 'PRODUCT_BUNDLE_IDENTIFIER = ' in line:
        prefix, rest = line.split('PRODUCT_BUNDLE_IDENTIFIER = ', 1)
        value = rest.split(';', 1)[0]
        line = f'{prefix}PRODUCT_BUNDLE_IDENTIFIER = com.workdaynoir.app;\n'
    lines.append(line)
p.write_text(''.join(lines))
PY
fi

if [[ -f ios/Runner/Info.plist ]] && command -v /usr/libexec/PlistBuddy >/dev/null 2>&1; then
  /usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName Workday Noir" ios/Runner/Info.plist || true
fi

echo "Flutter platform scaffolding is ready."
