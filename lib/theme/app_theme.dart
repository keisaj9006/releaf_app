// FILE: lib/theme/app_theme.dart
import 'package:flutter/material.dart';

import 'releaf_design_tokens.dart';

abstract final class AppTheme {
  /// Existing application theme retained while premium slices migrate safely.
  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Poppins',
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF1E4D2B),
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: Color(0xFF1E4D2B),
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w700,
          fontSize: 20,
          color: Color(0xFF1E4D2B),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(18)),
        ),
      ),
    );
  }

  /// Premium dark theme used by migrated Releaf product surfaces.
  static ThemeData premiumDark() {
    final colorScheme = const ColorScheme.dark(
      primary: ReleafColors.sage,
      onPrimary: ReleafColors.background,
      secondary: ReleafColors.premium,
      onSecondary: ReleafColors.background,
      surface: ReleafColors.surface,
      onSurface: ReleafColors.textPrimary,
      outline: ReleafColors.border,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: ReleafColors.background,
      splashColor: ReleafColors.sage.withValues(alpha: 0.08),
      highlightColor: ReleafColors.sage.withValues(alpha: 0.04),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: ReleafColors.textPrimary,
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: ReleafColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(ReleafRadii.large),
          ),
          side: BorderSide(color: ReleafColors.borderSoft),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, ReleafControlSizes.prominent),
          backgroundColor: ReleafColors.sage,
          foregroundColor: ReleafColors.background,
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ReleafRadii.medium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, ReleafControlSizes.prominent),
          foregroundColor: ReleafColors.textPrimary,
          side: const BorderSide(color: ReleafColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ReleafRadii.medium),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ReleafColors.sage,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: ReleafColors.textPrimary,
          minimumSize: const Size.square(ReleafControlSizes.standard),
        ),
      ),
      dividerColor: ReleafColors.borderSoft,
    );
  }
}
