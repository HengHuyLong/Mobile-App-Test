import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // 🎨 Minimal Modern Palette
  static const Color background = Color(0xFFFAFAFA); // soft off-white
  static const Color surface = Colors.white;
  static const Color primaryText = Color(0xFF1C1C1E); // near-black
  static const Color secondaryText = Color(0xFF8E8E93); // iOS-like gray
  static const Color accent = Color(0xFF2C2C2E); // neutral dark (modern)

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,

    scaffoldBackgroundColor: background,

    colorScheme: const ColorScheme.light(
      background: background,
      surface: surface,
      primary: accent,
      onPrimary: Colors.white,
      onSurface: primaryText,
    ),

    textTheme: GoogleFonts.interTextTheme(
      const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w700,
          height: 1.2,
        ),
        headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        bodySmall: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
      ),
    ).apply(bodyColor: primaryText, displayColor: primaryText),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      foregroundColor: primaryText,
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: accent,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero, // matches your login style
        ),
        minimumSize: const Size.fromHeight(48),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: primaryText),
    ),
  );
}
