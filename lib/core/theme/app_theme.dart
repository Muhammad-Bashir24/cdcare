import 'package:flutter/material.dart';

/// Centralized application theme adhering to a restrained blue/navy and white palette.
/// Provides consistent typography, component styles, and accessible touch targets.
class AppTheme {
  AppTheme._();

  // Color Palette
  static const Color primaryNavy = Color(0xFF0F2851);
  static const Color accentBlue = Color(0xFF1E56A0);
  static const Color lightBlue = Color(0xFFE8EEF5);
  static const Color backgroundLight = Color(0xFFF6F8FB);
  static const Color surfaceWhite = Color(0xFFFFFFFF);
  static const Color borderGrey = Color(0xFFDCE3ED);
  static const Color textPrimary = Color(0xFF102A43);
  static const Color textSecondary = Color(0xFF486581);
  static const Color textMuted = Color(0xFF829AB1);
  static const Color errorRed = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color successGreen = Color(0xFF1B5E20);
  static const Color successContainer = Color(0xFFE8F5E9);
  static const Color warningAmber = Color(0xFFB76E00);
  static const Color warningContainer = Color(0xFFFFF3E0);

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: primaryNavy,
      onPrimary: Colors.white,
      primaryContainer: lightBlue,
      onPrimaryContainer: primaryNavy,
      secondary: accentBlue,
      onSecondary: Colors.white,
      surface: surfaceWhite,
      onSurface: textPrimary,
      error: errorRed,
      onError: Colors.white,
      errorContainer: errorContainer,
      onErrorContainer: errorRed,
      outline: borderGrey,
      outlineVariant: borderGrey.withValues(alpha: 0.5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: backgroundLight,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceWhite,
        foregroundColor: primaryNavy,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: primaryNavy,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: IconThemeData(color: primaryNavy),
      ),
      cardTheme: CardThemeData(
        color: surfaceWhite,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: borderGrey, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceWhite,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: borderGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryNavy, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(color: textMuted, fontSize: 14),
        errorStyle: const TextStyle(
          color: errorRed,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryNavy,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(double.infinity, 50),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryNavy,
          minimumSize: const Size(double.infinity, 50),
          side: const BorderSide(color: primaryNavy, width: 1.2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: borderGrey,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
