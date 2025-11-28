import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light(Color accentColor) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: accentColor,
      surface: AppColors.background,
      brightness: Brightness.dark,
    );

    const baseTextTheme = Typography.whiteMountainView;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: baseTextTheme.copyWith(
          bodyLarge:
              baseTextTheme.bodyLarge?.copyWith(color: AppColors.primary),
          bodyMedium:
              baseTextTheme.bodyMedium?.copyWith(color: AppColors.primary),
          bodySmall: baseTextTheme.bodySmall
              ?.copyWith(color: AppColors.primaryMuted, fontSize: 10),
          titleMedium: baseTextTheme.titleMedium?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 16),
          titleLarge: baseTextTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              fontSize: 24)),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.transparent,
        centerTitle: true,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        titleTextStyle: TextStyle(
          color: AppColors.primary,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.seed,
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: AppColors.background,
      ),
      cardTheme: CardThemeData(
        color: AppColors.secondary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.background,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
        contentTextStyle: TextStyle(color: AppColors.primaryMuted),
      ),
    );
  }
}
