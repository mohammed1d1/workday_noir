import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Color and type constants for the Noir visual identity.
///
/// Deliberately restrained: near-black background, white primary text,
/// muted gray secondary text, and two desaturated accent tones used
/// sparingly (never as large fills) to indicate worked/not-worked state.
/// There is no bright accent color anywhere in the app.
class NoirColors {
  const NoirColors._();

  static const Color background = Color(0xFF0A0A0B);
  static const Color surface = Color(0xFF141416);
  static const Color surfaceRaised = Color(0xFF1C1C1F);
  static const Color hairline = Color(0x1FFFFFFF); // subtle 12% white border

  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary = Color(0xFF5C5C60);

  // Desaturated, muted accents — used only for small indicators, never
  // as large button fills, to keep the palette calm and premium.
  static const Color workedAccent = Color(0xFF6FA37A);
  static const Color notWorkedAccent = Color(0xFF9C6B6B);
}

class NoirTypography {
  const NoirTypography._();

  static const String fontFamily = '.SF Pro Text';

  static const TextStyle largeTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: NoirColors.textPrimary,
    letterSpacing: 0.2,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: NoirColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w400,
    color: NoirColors.textPrimary,
  );

  static const TextStyle secondary = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: NoirColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: NoirColors.textTertiary,
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: NoirColors.textPrimary,
    letterSpacing: 0.3,
  );
}

ThemeData buildNoirTheme() {
  final ColorScheme scheme = const ColorScheme.dark(
    surface: NoirColors.background,
    primary: NoirColors.textPrimary,
    secondary: NoirColors.textSecondary,
    onSurface: NoirColors.textPrimary,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: NoirColors.background,
    colorScheme: scheme,
    fontFamily: NoirTypography.fontFamily,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    dividerColor: NoirColors.hairline,
    appBarTheme: const AppBarTheme(
      backgroundColor: NoirColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: NoirTypography.title,
      iconTheme: IconThemeData(color: NoirColors.textPrimary),
    ),
    textTheme: const TextTheme(
      headlineLarge: NoirTypography.largeTitle,
      titleLarge: NoirTypography.title,
      bodyLarge: NoirTypography.body,
      bodyMedium: NoirTypography.secondary,
      bodySmall: NoirTypography.caption,
    ),
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: <TargetPlatform, PageTransitionsBuilder>{
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
}
