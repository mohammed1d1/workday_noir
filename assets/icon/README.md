# App icon

`icon_1024.png` is a placeholder concept: black background, a single thin
ring (one tracked day) with a bold minimal checkmark, no text, no
gradients. It reads clearly at small sizes and matches the app's Noir
palette exactly (background `#0A0A0B`, mark `#F5F5F7`).

## Turning this into real App Store assets

1. Design or refine the final 1024×1024 icon (this file is a strong
   starting point, not a final asset).
2. Generate the full iOS icon set from it — either via Xcode's own
   `Assets.xcassets` editor (drag the 1024×1024 PNG into the App Icon slot
   and let Xcode fill single-size modern icon sets), or a generator like
   https://appicon.co.
3. Replace `ios/Runner/Assets.xcassets/AppIcon.appiconset` with the result.

Do not use this PNG directly as `Contents.json`-backed multi-size assets —
generate the proper size set first.
