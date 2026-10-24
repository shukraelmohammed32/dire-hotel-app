import 'package:flutter/material.dart';

abstract final class AppColors {
  static const burgundy = Color(0xFF741E2D);
  static const deepBurgundy = Color(0xFF4C101D);
  static const wine = Color(0xFF9D3C4E);
  static const blush = Color(0xFFF7E7E7);
  static const canvas = Color(0xFFFCF9F6);
  static const ink = Color(0xFF2A2021);
  static const muted = Color(0xFF806F70);
  static const gold = Color(0xFFC89B5D);
  static const border = Color(0xFFECE2DE);
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.burgundy,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.burgundy,
      onPrimary: Colors.white,
      surface: AppColors.canvas,
      onSurface: AppColors.ink,
      secondary: AppColors.gold,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamily: 'sans',
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: AppColors.ink,
          fontSize: 36,
          fontWeight: FontWeight.w700,
          fontFamily: 'serif',
          height: 1.08,
        ),
        headlineSmall: TextStyle(
          color: AppColors.ink,
          fontSize: 25,
          fontWeight: FontWeight.w700,
          fontFamily: 'serif',
        ),
        titleLarge: TextStyle(
          color: AppColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: AppColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.ink,
          fontSize: 16,
          height: 1.45,
        ),
        bodyMedium: TextStyle(
          color: AppColors.muted,
          fontSize: 14,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: .2,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.canvas,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.burgundy,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.burgundy,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}
