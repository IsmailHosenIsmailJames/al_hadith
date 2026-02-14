import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_color_palette.dart';

/// Generates a complete [ThemeData] from an [AppColorPalette].
class AppTheme {
  AppTheme._();

  static ThemeData fromPalette(AppColorPalette palette) {
    final colorScheme = ColorScheme(
      brightness: _brightness(palette),
      primary: palette.primary,
      onPrimary: palette.onPrimary,
      primaryContainer: palette.primaryContainer,
      onPrimaryContainer: palette.darkest,
      secondary: palette.secondary,
      onSecondary: palette.lightest,
      secondaryContainer: palette.light,
      onSecondaryContainer: palette.veryDark,
      surface: palette.surface,
      onSurface: palette.onSurface,
      error: const Color(0xFFB00020),
      onError: Colors.white,
      outline: palette.mediumLight,
      shadow: palette.darkest.withValues(alpha: 0.15),
    );

    final textTheme = GoogleFonts.interTextTheme(
      ThemeData(brightness: colorScheme.brightness).textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: palette.background,
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: palette.dark,
        foregroundColor: palette.lightest,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: palette.lightest,
        ),
      ),

      // ElevatedButton
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Card
      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),

      // InputDecoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: palette.lightest,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.mediumLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.mediumLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: palette.primary, width: 2),
        ),
      ),

      // Floating Action Button
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: palette.primary,
        foregroundColor: palette.onPrimary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),

      // Divider
      dividerTheme: DividerThemeData(color: palette.light, thickness: 1),

      // ListTile
      listTileTheme: ListTileThemeData(
        iconColor: palette.secondary,
        textColor: palette.onSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Bottom Navigation
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: palette.surface,
        selectedItemColor: palette.primary,
        unselectedItemColor: palette.mediumLight,
      ),
    );
  }

  /// Midnight Dark palette uses dark brightness; everything else is light.
  static Brightness _brightness(AppColorPalette palette) {
    return palette.id == 'midnight_dark' ? Brightness.dark : Brightness.light;
  }
}
