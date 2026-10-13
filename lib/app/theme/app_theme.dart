import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: AppColors.gold,
      onPrimary: AppColors.navyDeep,
      primaryContainer: AppColors.goldTint,
      onPrimaryContainer: AppColors.navy,
      secondary: AppColors.surfaceRaised,
      onSecondary: AppColors.onNavy,
      secondaryContainer: AppColors.surface,
      onSecondaryContainer: AppColors.onNavy,
      tertiary: AppColors.muted,
      onTertiary: AppColors.navyDeep,
      error: Color(0xFFBA1A1A),
      onError: Colors.white,
      surface: AppColors.onNavy,
      onSurface: AppColors.navy,
      onSurfaceVariant: AppColors.muted,
      outline: AppColors.border,
      shadow: Colors.black26,
      scrim: Colors.black54,
      inverseSurface: AppColors.navy,
      onInverseSurface: AppColors.onNavy,
      inversePrimary: AppColors.gold,
      surfaceTint: AppColors.gold,
    );

    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.onNavy,
      useMaterial3: true,
      appBarTheme: const AppBarTheme(
        centerTitle: true,
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.onNavy,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.gold,
          foregroundColor: AppColors.navyDeep,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.gold, width: 2),
        ),
        labelStyle: const TextStyle(color: AppColors.muted),
      ),
      dividerColor: AppColors.border,
    );
  }
}
