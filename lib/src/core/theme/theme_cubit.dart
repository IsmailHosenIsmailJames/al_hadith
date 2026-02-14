import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_color_palette.dart';
import 'app_theme.dart';

/// State emitted by [ThemeCubit].
class ThemeState {
  final AppColorPalette palette;
  final ThemeData themeData;

  const ThemeState({required this.palette, required this.themeData});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThemeState &&
          runtimeType == other.runtimeType &&
          palette == other.palette;

  @override
  int get hashCode => palette.hashCode;
}

/// Cubit that manages the active [AppColorPalette] and its generated
/// [ThemeData]. Call [changeTheme] with a palette id to switch templates.
class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
    : super(
        ThemeState(
          palette: AppColorPalette.forestGreen,
          themeData: AppTheme.fromPalette(AppColorPalette.forestGreen),
        ),
      );

  /// Switch the active theme to the template matching [paletteId].
  /// If no template matches, the call is ignored.
  void changeTheme(String paletteId) {
    final palette = AppColorPalette.templates.firstWhere(
      (t) => t.id == paletteId,
      orElse: () => state.palette,
    );

    if (palette.id == state.palette.id) return;

    emit(
      ThemeState(palette: palette, themeData: AppTheme.fromPalette(palette)),
    );
  }
}
