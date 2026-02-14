import 'package:flutter/material.dart';

/// A color palette consisting of 9 shades from lightest to darkest.
/// Each template provides a harmonious set of colors for theming the app.
class AppColorPalette {
  final String id;
  final String name;
  final List<Color> shades;

  const AppColorPalette({
    required this.id,
    required this.name,
    required this.shades,
  }) : assert(shades.length == 9, 'AppColorPalette requires exactly 9 shades');

  // Semantic accessors (lightest → darkest)
  Color get lightest => shades[0];
  Color get veryLight => shades[1];
  Color get light => shades[2];
  Color get mediumLight => shades[3];
  Color get medium => shades[4];
  Color get mediumDark => shades[5];
  Color get dark => shades[6];
  Color get veryDark => shades[7];
  Color get darkest => shades[8];

  // Theme-mapping helpers
  Color get background => lightest;
  Color get surface => veryLight;
  Color get surfaceVariant => light;
  Color get primary => medium;
  Color get primaryContainer => mediumLight;
  Color get secondary => mediumDark;
  Color get onPrimary => lightest;
  Color get onBackground => darkest;
  Color get onSurface => veryDark;

  // ──────────────────────────────────────────────
  // Pre-built palette templates
  // ──────────────────────────────────────────────

  static const String defaultPaletteId = 'forest_green';

  static final List<AppColorPalette> templates = [
    forestGreen,
    oceanBlue,
    sunsetAmber,
    royalPurple,
    rosePink,
    midnightDark,
  ];

  /// 1 — Forest Green (default, from coolors URL)
  static final forestGreen = AppColorPalette(
    id: 'forest_green',
    name: 'Forest Green',
    shades: const [
      Color(0xFFD8F3DC),
      Color(0xFFB7E4C7),
      Color(0xFF95D5B2),
      Color(0xFF74C69D),
      Color(0xFF52B788),
      Color(0xFF40916C),
      Color(0xFF2D6A4F),
      Color(0xFF1B4332),
      Color(0xFF081C15),
    ],
  );

  /// 2 — Ocean Blue
  static final oceanBlue = AppColorPalette(
    id: 'ocean_blue',
    name: 'Ocean Blue',
    shades: const [
      Color(0xFFCAF0F8),
      Color(0xFFADE8F4),
      Color(0xFF90E0EF),
      Color(0xFF48CAE4),
      Color(0xFF00B4D8),
      Color(0xFF0096C7),
      Color(0xFF0077B6),
      Color(0xFF023E8A),
      Color(0xFF03045E),
    ],
  );

  /// 3 — Sunset Amber
  static final sunsetAmber = AppColorPalette(
    id: 'sunset_amber',
    name: 'Sunset Amber',
    shades: const [
      Color(0xFFFFF3E0),
      Color(0xFFFFE0B2),
      Color(0xFFFFCC80),
      Color(0xFFFFB74D),
      Color(0xFFFFA726),
      Color(0xFFFF9800),
      Color(0xFFF57C00),
      Color(0xFFE65100),
      Color(0xFF4E1600),
    ],
  );

  /// 4 — Royal Purple
  static final royalPurple = AppColorPalette(
    id: 'royal_purple',
    name: 'Royal Purple',
    shades: const [
      Color(0xFFF3E5F5),
      Color(0xFFE1BEE7),
      Color(0xFFCE93D8),
      Color(0xFFBA68C8),
      Color(0xFFAB47BC),
      Color(0xFF9C27B0),
      Color(0xFF7B1FA2),
      Color(0xFF4A148C),
      Color(0xFF1A0533),
    ],
  );

  /// 5 — Rose Pink
  static final rosePink = AppColorPalette(
    id: 'rose_pink',
    name: 'Rose Pink',
    shades: const [
      Color(0xFFFCE4EC),
      Color(0xFFF8BBD0),
      Color(0xFFF48FB1),
      Color(0xFFF06292),
      Color(0xFFEC407A),
      Color(0xFFE91E63),
      Color(0xFFC2185B),
      Color(0xFF880E4F),
      Color(0xFF2C0519),
    ],
  );

  /// 6 — Midnight Dark
  static final midnightDark = AppColorPalette(
    id: 'midnight_dark',
    name: 'Midnight Dark',
    shades: const [
      Color(0xFFE0E0E0),
      Color(0xFFBDBDBD),
      Color(0xFF9E9E9E),
      Color(0xFF757575),
      Color(0xFF616161),
      Color(0xFF424242),
      Color(0xFF303030),
      Color(0xFF212121),
      Color(0xFF0A0A0A),
    ],
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppColorPalette &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
