import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_color_palette.dart';
import 'theme_cubit.dart';

/// A reusable, non-fullscreen widget that displays all available color
/// palettes and lets the user tap one to switch the app theme.
///
/// Drop this widget into any screen (e.g. a settings page):
/// ```dart
/// const ThemePickerWidget()
/// ```
class ThemePickerWidget extends StatelessWidget {
  const ThemePickerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final activePaletteId = themeState.palette.id;
        final templates = AppColorPalette.templates;

        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Color Theme',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: templates.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final palette = templates[index];
                  final isActive = palette.id == activePaletteId;

                  return _PaletteCard(
                    palette: palette,
                    isActive: isActive,
                    onTap: () {
                      context.read<ThemeCubit>().changeTheme(palette.id);
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PaletteCard extends StatelessWidget {
  final AppColorPalette palette;
  final bool isActive;
  final VoidCallback onTap;

  const _PaletteCard({
    required this.palette,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        width: 90,
        decoration: BoxDecoration(
          color: palette.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive ? palette.primary : palette.light,
            width: isActive ? 2.5 : 1,
          ),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: palette.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Color swatch row (shows 5 key shades)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final i in [0, 2, 4, 6, 8])
                  Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: palette.shades[i],
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            // Palette name
            Text(
              palette.name,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: palette.darkest,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Active check
            if (isActive)
              Icon(Icons.check_circle_rounded, size: 18, color: palette.primary)
            else
              const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }
}
