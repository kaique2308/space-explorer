import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palette
  static const Color background = Color(0xFF080B18);
  static const Color surface = Color(0xFF0F1629);
  static const Color card = Color(0xFF141C35);
  static const Color accent = Color(0xFF4D9DE0);
  static const Color accentGlow = Color(0xFF7BB8F0);
  static const Color gold = Color(0xFFFFD166);
  static const Color nebulaPink = Color(0xFFEF476F);
  static const Color nebulaGreen = Color(0xFF06D6A0);
  static const Color textPrimary = Color(0xFFF0F4FF);
  static const Color textSecondary = Color(0xFF8899BB);
  static const Color divider = Color(0xFF1E2A47);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: gold,
        surface: surface,
        background: background,
        error: nebulaPink,
      ),
      textTheme: GoogleFonts.spaceGroteskTextTheme(
        const TextTheme(
          displayLarge: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.5),
          displayMedium: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: textPrimary),
          titleLarge: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: textPrimary),
          titleMedium: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary),
          bodyLarge: TextStyle(
              fontSize: 15,
              color: textPrimary,
              height: 1.6),
          bodyMedium: TextStyle(
              fontSize: 13,
              color: textSecondary,
              height: 1.5),
          labelSmall: TextStyle(
              fontSize: 11,
              color: textSecondary,
              letterSpacing: 1.2),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        iconTheme: const IconThemeData(color: textPrimary),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: accent,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      cardTheme: CardTheme(
        color: card,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: divider, width: 1),
        ),
      ),
    );
  }
}
