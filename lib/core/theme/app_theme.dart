import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const double wideWidth = 700;
  // Brand color scheme based on HSL tailoring
  static const Color darkCanvas = Color(
    0xFF0A0C10,
  ); // HSL(220, 30%, 5%) - Deep dark background
  static const Color darkSurface = Color(
    0xFF121620,
  ); // HSL(220, 20%, 10%) - Card surface
  static const Color darkSurfaceCard = Color(
    0xFF1A1F2C,
  ); // HSL(220, 18%, 14%) - Subcard / list tiles

  static const Color primaryMint = Color(
    0xFF00D1A0,
  ); // HSL(166, 100%, 41%) - Glowing teal highlight
  static const Color secondaryIndigo = Color(
    0xFF6366F1,
  ); // HSL(239, 84%, 66%) - Indigo accent

  static const Color textPrimary = Color(0xFFF3F4F6); // Soft white
  static const Color textSecondary = Color(0xFF9CA3AF); // Muted silver
  static const Color textDark = Color(
    0xFF111827,
  ); // Deep black-grey for light background if needed

  // Gradient configurations for the wow factor
  static const Gradient primaryGradient = LinearGradient(
    colors: [primaryMint, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient premiumCardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient glassGradient = LinearGradient(
    colors: [
      Color(0x1AFFFFFF), // Very faint transparent white
      Color(0x05FFFFFF),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkCanvas,
      primaryColor: primaryMint,
      colorScheme: const ColorScheme.dark(
        primary: primaryMint,
        secondary: secondaryIndigo,
        surface: darkSurface,
        onPrimary: darkCanvas,
        onSecondary: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFF232D3F), width: 1.5),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMint,
          foregroundColor: darkCanvas,
          elevation: 4,
          shadowColor: primaryMint.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryMint;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(darkCanvas),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF9FAFB),
      primaryColor: primaryMint,
      colorScheme: const ColorScheme.light(
        primary: primaryMint,
        secondary: secondaryIndigo,
        surface: Colors.white,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textDark),
        actionsIconTheme: IconThemeData(color: textDark),
      ),
      textTheme: GoogleFonts.outfitTextTheme().copyWith(
        displayLarge: GoogleFonts.outfit(
          color: textDark,
          fontSize: 32,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.w700,
        ),
        bodyLarge: GoogleFonts.outfit(
          color: textDark,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.outfit(
          color: const Color(0xFF4B5563),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryMint,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: primaryMint.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.outfit(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color>((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryMint;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
