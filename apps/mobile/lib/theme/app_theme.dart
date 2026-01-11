import 'package:flutter/material.dart';

/// App theme configuration with light and dark themes
class AppTheme {
  // Brand colors (matching existing design from settings_screen.dart)
  static const Color primaryColor = Color(0xFF154B2E);
  static const Color accentColor = Color(0xFF65FFF0);
  static const Color backgroundLight = Color(0xFFF6FBF6);
  static const Color mutedColor = Color(0xFF7A7A7A);

  /// Light theme
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accentColor,
          brightness: Brightness.light,
          primary: primaryColor,
          onPrimary: Colors.white,
          surface: Colors.white,
          onSurface: primaryColor,
        ),
        scaffoldBackgroundColor: backgroundLight,
        appBarTheme: const AppBarTheme(
          backgroundColor: backgroundLight,
          foregroundColor: primaryColor,
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primaryColor,
            side: BorderSide(color: primaryColor.withValues(alpha: 0.2)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: primaryColor,
          ),
        ),
        dialogTheme: DialogThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      );

  /// Dark theme
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF01F9C6),
          brightness: Brightness.dark,
          // Primary / High emphasis - Bright Teal (#01F9C6)
          // Used for: primary text, headings, icons, numbers, CTAs, active states
          primary: const Color(0xFF7FFFD4),
          // Text/icons on primary backgrounds
          onPrimary: const Color(0xFF0A0A0A),
          // Card/tile/dialog backgrounds
          surface: const Color(0xFF1E1E1E),
          // Primary readable text (near-white)
          onSurface: const Color(0xFFF5F5F5),
          // Secondary / Medium emphasis - Deep Sea (#3B9C9C)
          // Used for: descriptions, labels, helper text, secondary info
          onSurfaceVariant: const Color(0xFF3B9C9C),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF121212),
          elevation: 0,
          centerTitle: true,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF1E1E1E),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF01F9C6),
            foregroundColor: const Color(0xFF0A0A0A),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF01F9C6),
            side: BorderSide(color: const Color(0xFF01F9C6).withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF01F9C6),
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      );
}
